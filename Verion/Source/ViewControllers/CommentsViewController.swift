//
//  CommentsViewController.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CommentsViewController: UITableViewController {
    
    
    // Cell configuration
    let COMMENT_CELL_REUSE_ID = "CommentCell"
    let SUBMISSION_TITLE_CELL_REUSE_ID = "SubmissionTitleCell"
    let SUBMISSION_TEXT_CELL_REUSE_ID = "SubmissionTextCell"
    let SUBMISSION_LINK_CELL_REUSE_ID = "SubmissionLinkCell"
    let SUBMISSION_IMAGE_CELL_REUSE_ID = "SubmissionImageCell"
    
    let ACTIVITY_INDICATOR_CELL_REUSE_ID = "ActivityIndicatorCell"
    let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    let LOAD_MORE_COMMENTS_CELL_REUSE_ID = "LoadMoreComments"
    let SORTED_BY_CELL_REUSE_ID = "SortByCell"
    private let CELL_SPACING: CGFloat = 10.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private var numOfCellsToDisplay = 0
    
    var submissionDataModel: SubmissionDataModelProtocol?
    
    // View Models
    var submissionMediaType: SubmissionMediaType = .none
    var submissionTitleVm: SubmissionTitleCellViewModel?
    var submissionImageContentVm: SubmissionImageCellViewModel?
    var submissionTextContentVm: SubmissionTextCellViewModel?
    var submissionLinkContentVm: SubmissionLinkCellViewModel?
    var commentsSortByVm: CommentsSortByCellViewModel?
    
    var commentsViewModels: [CommentCellViewModel] = []
    
    
    // Navigation Bar items
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    private var activityIndicatorCell: ActivityIndicatorCell?
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
        // TODO: Comment View Controller main functions
        // Load Refresh Control
        
        // Load Submission Post
        // the SubmissionDataModel will have been loaded pre-segue
        // Bind the model to stuff
        
        DispatchQueue.global(qos: .background).async {
            self.loadSubmissionInfo() {
                // On completed, reload table animated
                DispatchQueue.main.async {
                    self.reloadTableAnimated()
                }
            }
        }
        
        self.loadCommentCells()
        self.tableView.reloadData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // TODO: Reload the table
    func reloadTableAnimated() {
        
    }
    
    func loadSubmissionInfo(completion: @escaping ()->()) {
        
        self.loadSubmissionTitle(submissionDataModel: self.submissionDataModel!, dataProvider: self.dataProvider)
        self.loadContent(submissionDataModel: self.submissionDataModel!, dataProvider: self.dataProvider)
        self.loadSortedByBar()
        
        completion()
    }
    
    func loadSubmissionTitle(submissionDataModel: SubmissionDataModelProtocol, dataProvider: DataProviderType?) {
        // Bind the submission data model to a new submission title cell view model
        let submissionTitleCellViewModel = SubmissionTitleCellViewModel()
        dataProvider?.bind(subTitleViewModel: submissionTitleCellViewModel, dataModel: submissionDataModel)
        
        self.submissionTitleVm = submissionTitleCellViewModel
    }
    
    func loadContent(submissionDataModel: SubmissionDataModelProtocol, dataProvider: DataProviderType?) {
        // Determine the content type
        self.submissionMediaType = (dataProvider?.getSubmissionMediaType(submissionDataModel: submissionDataModel))!
        
        // Hook up the view models with the data provider based on content type
        switch self.submissionMediaType {
        case .text:
            // Bind the text view model using data provider
            self.submissionTextContentVm = SubmissionTextCellViewModel(text: "")
            dataProvider?.bind(subTextCellViewModel: self.submissionTextContentVm!, dataModel: submissionDataModel)
        case .link:
            self.submissionLinkContentVm = SubmissionLinkCellViewModel()
            dataProvider?.bind(subLinkCellViewModel: self.submissionLinkContentVm!, dataModel: submissionDataModel)
        case .image:
            self.submissionImageContentVm = SubmissionImageCellViewModel.init(imageLink: "")
            dataProvider?.bind(subImageCellViewModel: self.submissionImageContentVm!, dataModel: submissionDataModel)
        default:
            // TODO: Default case is a "Link" type, no matter the media content
            self.submissionLinkContentVm = SubmissionLinkCellViewModel()
            dataProvider?.bind(subLinkCellViewModel: self.submissionLinkContentVm!, dataModel: submissionDataModel)
            break
        }
    }
    
    
    // TODO: Load sortBy cell
    func loadSortedByBar() {
        self.commentsSortByVm = CommentsSortByCellViewModel()
    }
    
    // TODO: load comments from data provider
    func loadCommentCells() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        }
        
        guard self.areCommentsLoaded() != false else {
            return 1
        }
        
        return 100
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            // If first row, Title Cell
            if indexPath.row == 0 {
                
                let titleCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_TITLE_CELL_REUSE_ID, for: indexPath) as! SubmissionTitleCell
                titleCell.bind(toViewModel: self.submissionTitleVm!)
                
                return titleCell
                
            } else if indexPath.row == 1 {
                
                // If second row, Content Cell
                switch self.submissionMediaType {
                case .text:
                    let textCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_TEXT_CELL_REUSE_ID, for: indexPath) as! SubmissionTextCell
                    textCell.bind(toViewModel: self.submissionTextContentVm!)
                    
                    return textCell
                case .image:
                    let imageCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_IMAGE_CELL_REUSE_ID, for: indexPath) as! SubmissionImageCell
                    
                    DispatchQueue.global(qos: .background).async {
                        self.submissionImageContentVm?.downloadImage()
                        
                        DispatchQueue.main.async {
                            imageCell.bindImage(fromViewModel: self.submissionImageContentVm!)
                        }
                    }
                    
                    return imageCell
                case .link:
                    let linkCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_LINK_CELL_REUSE_ID, for: indexPath) as! SubmissionLinkCell
                    linkCell.bind(toViewModel: self.submissionLinkContentVm!)
                    
                    DispatchQueue.global(qos: .background).async {
                        self.submissionLinkContentVm?.downloadThumbnail()
                        
                        DispatchQueue.main.async {
                            linkCell.bindThumbnailImage(fromViewModel: self.submissionLinkContentVm!)
                        }
                    }
                    
                    return linkCell
                    
                default:
                    let linkCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_LINK_CELL_REUSE_ID, for: indexPath)
                    
                    return linkCell
                }
            } else {
                // If third row, SortedBy Cell
                let sortByCell = tableView.dequeueReusableCell(withIdentifier: self.SORTED_BY_CELL_REUSE_ID, for: indexPath) as! CommentsSortByCell
                sortByCell.bind(toViewModel: self.commentsSortByVm!)
                sortByCell.navigationController = self.navigationController
                
                return sortByCell
            }
        }
        
        // Loading Cell
        if self.areCommentsLoaded() == false {
            
            // Activity Indicator
            if self.activityIndicatorCell != nil {
                self.activityIndicatorCell?.removeActivityIndicator()
            }
            
            self.activityIndicatorCell = tableView.dequeueReusableCell(withIdentifier: self.ACTIVITY_INDICATOR_CELL_REUSE_ID) as! ActivityIndicatorCell?
            self.activityIndicatorCell?.loadActivityIndicator(length: self.ACTIVITY_INDICATOR_LENGTH)
            self.activityIndicatorCell?.showActivityIndicator()
            return self.activityIndicatorCell!
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.COMMENT_CELL_REUSE_ID, for: indexPath)

        // Configure the cell...

        return cell
    }
    
    // TODO: detect that comments are loaded
    func areCommentsLoaded() -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // For detecting rotations beginning and finishing.
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        self.activityIndicatorCell?.hideActivityIndicator()
        
        if UIDevice.current.orientation.isLandscape {
            
            #if DEBUG
                print("Landscape")
            #endif
            
        } else {
            
            #if DEBUG
                print("Portrait")
            #endif
        }
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            // Reset activity indicator cell position
            self.activityIndicatorCell?.reloadPosition()
            self.activityIndicatorCell?.showActivityIndicator()
        })
    }


}
