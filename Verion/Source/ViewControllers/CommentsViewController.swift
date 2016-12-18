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
    
    // Display formatting
    private let BGCOLOR: UIColor = UIColor(colorLiteralRed: 0.8, green: 0.4, blue: 0.4, alpha: 1.0)
    private let CELL_SPACING: CGFloat = 10.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let LOADING_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private var numOfCellsToDisplay = 0
    
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
    
    
    var submissionDataModel: SubmissionDataModelProtocol?
    
    // View Models
    var submissionMediaType: SubmissionMediaType = .none
    var submissionTitleVm: SubmissionTitleCellViewModel?
    var submissionImageContentVm: SubmissionImageCellViewModel?
    var submissionTextContentVm: SubmissionTextCellViewModel?
    var submissionLinkContentVm: SubmissionLinkCellViewModel?
    var commentsSortByVm: CommentsSortByCellViewModel?
    
    var commentsViewModels: [CommentCellViewModel] = []
    var commentDataModels: [CommentDataModelProtocol] = []
    var areCommentsLoaded = false
    
    // Navigation Bar items
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    private var activityIndicatorCell: ActivityIndicatorCell?
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = self.BGCOLOR
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
        // TODO: Comment View Controller main functions
        // Load Refresh Control
        
        // Load Submission Post
        // the SubmissionDataModel will have been loaded pre-segue
        // Bind the model to stuff
        
        
        self.loadSubmissionInfo {
            self.loadCommentCells {
                
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // TODO: Reload the table
    func reloadTableAnimated() {
        self.reloadTableAnimated(forTableView: self.tableView, startingIndexInclusive: 1, endingIndexExclusive: self.commentsViewModels.count+1, animation: .automatic)
    }
    
    private func reloadTableAnimated(forTableView tableView: UITableView, startingIndexInclusive: Int, endingIndexExclusive:
        Int, animation: UITableViewRowAnimation) {
        
        tableView.reloadData()
        let range = Range.init(uncheckedBounds: (lower: startingIndexInclusive, upper: endingIndexExclusive))
        let indexSet = IndexSet.init(integersIn: range)
        tableView.reloadSections(indexSet, with: animation)
    }
    
    func loadSubmissionInfo(completion: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            self.loadSubmissionTitle(submissionDataModel: self.submissionDataModel!, dataProvider: self.dataProvider)
            self.loadContent(submissionDataModel: self.submissionDataModel!, dataProvider: self.dataProvider)
            self.loadSortedByBar()
            
            DispatchQueue.main.async {
                self.reloadTableAnimated()
                
                completion()
            }
        }
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
    func loadCommentCells(completion: @escaping ()->()) {
        self.dataProvider?.requestComments(submissionId: (self.submissionDataModel?.id)!, completion: { (commentDataModels, error) in
            
            DispatchQueue.global(qos: .background).async {
                
                // Clear all current data
                self.commentsViewModels.removeAll()
                self.commentDataModels = commentDataModels
                
                for i in 0..<commentDataModels.count {
                    let commentViewModel = CommentCellViewModel()
                    self.commentsViewModels.append(commentViewModel)
                    
                    let dataModel = commentDataModels[i]
                    
                    self.dataProvider?.bind(commentCellViewModel: commentViewModel, dataModel: dataModel)
                }
                
                self.areCommentsLoaded = true
                
                DispatchQueue.main.async {
                    self.reloadTableAnimated()
                    
                    completion()
                }
                
            }
        })
        
        completion()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let numOfSections: Int
        
        if self.areCommentsLoaded == false {
            numOfSections = 2
        }
        else {
            numOfSections = self.commentsViewModels.count + 1 // 1 extra section for submission cells
        }
        
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Submission Cells
        if section == 0 {
            // View Models must be initialized
            if self.areSubmissionViewModelsLoaded() == true {
                return 3
            }
            else {
                return 0
            }
        } else {
            
            // Always 1 row per comments
            return 1
        }
        
        
    }
    
    // Background
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // No header for first cell
        if section == 0 {
            return 0
        }
        
        return self.CELL_SPACING
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.areSubmissionViewModelsLoaded() != false else {
            return 0
        }
        
        if indexPath.section == 0 {
            // Title row
            if indexPath.row == 0 {
                let submissionTitleCellVm = self.submissionTitleVm!
                
                return submissionTitleCellVm.cellHeight
            }
            // Content row
            else if indexPath.row == 1 {
                switch self.submissionMediaType {
                case .text:
                    let submissionTextCellVm = self.submissionTextContentVm!
                    return submissionTextCellVm.cellHeight
                case .link:
                    let submissionLinkCellVm = self.submissionLinkContentVm!
                    return submissionLinkCellVm.cellHeight
                case .image:
                    let submissionImageCellVm = self.submissionImageContentVm!
                    return submissionImageCellVm.cellHeight
                default:
                    return 0
                }
            }
            // Sort By row
            else if indexPath.row == 2 {
                let sortByCellVm = self.commentsSortByVm!
                return sortByCellVm.cellHeight
            }
        }
        
        guard self.areCommentsLoaded != false else {
            return self.LOADING_CELL_HEIGHT
        }
        
        if self.commentsViewModels.count > 0 {
            // Comment Cell Height
            let commentCellVm = self.commentsViewModels[indexPath.section-1]
            let cellHeight = commentCellVm.cellHeight
            
            return cellHeight
        }
        
        // This should never be reached
        let defaultHeight: CGFloat = 50.0
        
        return defaultHeight
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
                        self.submissionImageContentVm?.downloadImage() {
                            DispatchQueue.main.async {
                                imageCell.bindImage(fromViewModel: self.submissionImageContentVm!)
                                self.reloadTableAnimated()
                            }
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
                self.sfxManager?.applyShadow(view: sortByCell)
                
                return sortByCell
            }
        }
        
        // Loading Comment Cell
        if self.areCommentsLoaded == false {
            
            // Activity Indicator for a 'Loading' cell
            if self.activityIndicatorCell != nil {
                self.activityIndicatorCell?.removeActivityIndicator()
            }
            
            self.activityIndicatorCell = tableView.dequeueReusableCell(withIdentifier: self.ACTIVITY_INDICATOR_CELL_REUSE_ID, for: indexPath) as? ActivityIndicatorCell
            self.activityIndicatorCell?.loadActivityIndicator(length: self.ACTIVITY_INDICATOR_LENGTH)
            self.activityIndicatorCell?.showActivityIndicator()
            return self.activityIndicatorCell!
        }
        else {
            // Comment cells
            
            let commentCell = tableView.dequeueReusableCell(withIdentifier: self.COMMENT_CELL_REUSE_ID, for: indexPath) as! CommentCell
            let commentCellViewModel = self.commentsViewModels[indexPath.section-1]
            commentCell.delegate = self
            commentCell.bind(toViewModel: commentCellViewModel)
            
            
            self.sfxManager?.applyShadow(view: commentCell)
            
            return commentCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // If touched sorted By bar, trigger the segue
        if indexPath.section == 0 && indexPath.row == 2 {
            let sortByCell = tableView.cellForRow(at: indexPath) as! CommentsSortByCell
            sortByCell.sortByTouched(self)
        }
        // TODO: Launch link from content cell
        
        
        // Minimize comment cell
        if indexPath.section >= 1 {
            let commentCellVm = self.commentsViewModels[indexPath.section-1]
            commentCellVm.toggleMinimized()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Forces redraw of shadows right before transition
        self.tableView.reloadData()
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

    func areSubmissionViewModelsLoaded() -> Bool {
        // The commentsSortByViewModel should be the last one to be loaded
        if self.commentsSortByVm != nil {
            return true
        }
        
        return false
    }
}

extension CommentsViewController: CommentCellDelegate {
    func commentCellDidChange(commentCell: CommentCell) {
        // Get the index, reload table row
        if let indexPath = self.tableView.indexPath(for: commentCell) {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        
    }
}
