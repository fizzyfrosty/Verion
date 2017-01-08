//
//  CommentsViewController.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices

class CommentsViewController: UITableViewController, UITextViewDelegate, CommentsSortByCellDelegate {
    
    var backgroundColor = UIColor.white
    
    // Display formatting
    private let CELL_SPACING: CGFloat = 10.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private var numOfCellsToDisplay = 0
    
    // Cell configuration
    let COMMENT_CELL_REUSE_ID = "CommentCell"
    let SUBMISSION_TITLE_CELL_REUSE_ID = "SubmissionTitleCell"
    let SUBMISSION_TEXT_CELL_REUSE_ID = "SubmissionTextCell"
    let SUBMISSION_LINK_CELL_REUSE_ID = "SubmissionLinkCell"
    let SUBMISSION_IMAGE_CELL_REUSE_ID = "SubmissionImageCell"
    let PROGRESS_INDICATOR_CELL_REUSE_ID = "ProgressIndicatorCell"
    
    let ACTIVITY_INDICATOR_CELL_REUSE_ID = "ActivityIndicatorCell"
    let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    let LOAD_MORE_COMMENTS_CELL_REUSE_ID = "LoadMoreComments"
    let SORTED_BY_CELL_REUSE_ID = "SortByCell"
    
    let WEBVIEW_SEGUE_ID = "WebViewSegue"
    
    var submissionDataModel: SubmissionDataModelProtocol?
    
    // View Models
    var submissionMediaType: SubmissionMediaType = .undetermined
    var submissionTitleVm: SubmissionTitleCellViewModel?
    var submissionImageContentVm: SubmissionImageCellViewModel = SubmissionImageCellViewModel()
    var submissionTextContentVm: SubmissionTextCellViewModel = SubmissionTextCellViewModel()
    var submissionLinkContentVm: SubmissionLinkCellViewModel = SubmissionLinkCellViewModel()
    var commentsSortByVm: CommentsSortByCellViewModel?
    var progressCellVm: ProgressIndicatorCellViewModel = ProgressIndicatorCellViewModel()
    
    var commentsViewModels: [CommentCellViewModel] = []
    var areCommentsLoaded = false
    var loadMoreParentCommentsIndex = 0
    
    // Navigation Bar items
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    private var activityIndicatorCell: ActivityIndicatorCell?
    
    // Web View Controller 
    var linkString = ""
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType?
    var analyticsManager: AnalyticsManagerProtocol?
    var adManager: AdManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = self.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        self.loadSubmissionInfo {
            
            self.loadCommentCells {
                
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func reloadTableCommentsAnimated() {
        self.reloadTableAnimated(startingIndexInclusive: 1, endingIndexExclusive: self.commentsViewModels.count+1, animation: .automatic)
    }
    
    private func reloadTableAnimated(startingIndexInclusive: Int, endingIndexExclusive:
        Int, animation: UITableViewRowAnimation) {
        
        self.tableView.reloadData()
        let range = Range.init(uncheckedBounds: (lower: startingIndexInclusive, upper: endingIndexExclusive))
        let indexSet = IndexSet.init(integersIn: range)
        self.tableView.reloadSections(indexSet, with: animation)
    }
    
    private func loadSubmissionInfo(completion: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            self.loadSubmissionTitle(submissionDataModel: self.submissionDataModel!, dataProvider: self.dataProvider)
            self.loadContent(submissionDataModel: self.submissionDataModel!, dataProvider: self.dataProvider) {
                
                // Analytics - place this here because media type isn't finished loading until content is retrieved
                let params = AnalyticsEvents.getCommentsControllerViewingParams(subverseName: self.submissionDataModel!.subverseName, mediaType: self.submissionMediaType)
                self.analyticsManager?.logEvent(name: AnalyticsEvents.commentsControllerViewing, params: params, timed: false)
                
            }
            
            // This is required to complete table cell generation
            self.loadSortedByBar()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let titleIndexPath = IndexPath.init(row: 0, section: 0)
                let contentIndexPath = IndexPath.init(row: 1, section: 0)
                let sortByCellIndexPath = IndexPath.init(row: 2, section: 0)
                self.tableView.reloadRows(at: [titleIndexPath, contentIndexPath, sortByCellIndexPath], with: .fade)
                
                completion()
            }
        }
    }
    
    private func loadSubmissionTitle(submissionDataModel: SubmissionDataModelProtocol, dataProvider: DataProviderType?) {
        // Bind the submission data model to a new submission title cell view model
        let submissionTitleCellViewModel = SubmissionTitleCellViewModel()
        dataProvider?.bind(subTitleViewModel: submissionTitleCellViewModel, dataModel: submissionDataModel)
        
        self.submissionTitleVm = submissionTitleCellViewModel
    }
    
    // This loads the middle cell, the Content Cell of the first section
    private func loadContent(submissionDataModel: SubmissionDataModelProtocol, dataProvider: DataProviderType?, completion: @escaping ()->()) {
        // Determine the content type
        self.submissionMediaType = (dataProvider?.getSubmissionMediaType(submissionDataModel: submissionDataModel))!
        
        // Hook up the view models with the data provider based on content type
        switch self.submissionMediaType {
        case .text:
            // Bind the text view model using data provider
            self.submissionTextContentVm = SubmissionTextCellViewModel(text: "")
            dataProvider?.bind(subTextCellViewModel: self.submissionTextContentVm, dataModel: submissionDataModel)
            completion()
        default:
            // If not text, either link or image. Make a request to further determine content type
            
            // Request
            self.dataProvider?.requestContent(submissionDataModel: self.submissionDataModel!, downloadProgress: { progress in
                self.progressCellVm.progress.value = progress
                
            }, completion: { (data, mediaType, isGif, error) in
                
                // Reupdate media type and the (correct) content view model
                self.submissionMediaType = mediaType
                
                if self.submissionMediaType == SubmissionMediaType.image {
                    // An image
                    self.submissionImageContentVm = SubmissionImageCellViewModel.init(imageData: data!, isGif: isGif)
                    dataProvider?.bind(subImageCellViewModel: self.submissionImageContentVm, dataModel: submissionDataModel)
                }
                else {
                    // A link
                    self.submissionLinkContentVm = SubmissionLinkCellViewModel()
                    dataProvider?.bind(subLinkCellViewModel: self.submissionLinkContentVm, dataModel: submissionDataModel)
                }
                
                // When finished downloading, reload the Content Cell
                DispatchQueue.main.async {
                    // Reload just the image/content cell
                    self.tableView.reloadData()
                    let imageCellIndexPath = IndexPath.init(row: 1, section: 0)
                    self.tableView.reloadRows(at: [imageCellIndexPath], with: .fade)
                }
                
                completion()
            })
            
            break;
        }
    }
    
    
    private func loadSortedByBar() {
        self.commentsSortByVm = CommentsSortByCellViewModel()
    }
    
    private func requestChildComments(subverse: String, submissionId: Int64, parentId: Int64, startingIndex: Int, completion: @escaping ([CommentCellViewModel])->()) {
        
        self.dataProvider?.requestChildComments(subverse: subverse, submissionId: submissionId, parentId: parentId, startingIndex: startingIndex) { commentDataModels, commentDataSegment, error in
            
            DispatchQueue.global(qos: .background).async {
                
                // Turn dataModels into cell view models
                var topLevelCommentVms = self.getTopLevelCommentViewModels(fromDataModels: commentDataModels)
                
                // Load More cell
                if commentDataSegment != nil {
                    if commentDataSegment!.hasMore {
                        // Add to toplevel comments
                        let loadMoreCommentsViewModel = self.getLoadMoreCellViewModel(numOfComments: commentDataSegment!.remainingCount, lastCommentIndex: commentDataSegment!.endingIndex)
                        topLevelCommentVms.append(loadMoreCommentsViewModel)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(topLevelCommentVms)
                }
            }
        }
    }
    
    // Load Comments from Data Provider
    private func loadCommentCells(completion: @escaping ()->()) {
        self.dataProvider?.requestComments(subverse:self.submissionDataModel!.subverseName, submissionId: self.submissionDataModel!.id, completion: { (commentDataModels, commentDataSegment, error) in
            
            DispatchQueue.global(qos: .background).async {
                
                var topLevelCommentVms = self.getTopLevelCommentViewModels(fromDataModels: commentDataModels)
                
                // Load More cell
                if commentDataSegment != nil {
                    if commentDataSegment!.hasMore {
                        // Add to toplevel comments
                        let loadMoreCommentsViewModel = self.getLoadMoreCellViewModel(numOfComments: commentDataSegment!.remainingCount, lastCommentIndex: commentDataSegment!.endingIndex)
                        topLevelCommentVms.append(loadMoreCommentsViewModel)
                    }
                }
                
                
                // Put all comment cells, and children, into a single array
                let allCommentViewModelsLinearArray = self.getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels: topLevelCommentVms)
                self.commentsViewModels.append(contentsOf: allCommentViewModelsLinearArray)
                
                self.setAllCommentViewModelChildDepthIndexes(topLevelViewModels: topLevelCommentVms, startingDepthIndex: 0)
                
                self.areCommentsLoaded = true
                
                
                DispatchQueue.main.async {
                    self.reloadTableCommentsAnimated()
                    
                    completion()
                }
                
            }
        })
        
        completion()
    }
    
    private func getTopLevelCommentViewModels(fromDataModels dataModels: [CommentDataModelProtocol]) -> [CommentCellViewModel] {
        
        var topLevelComments: [CommentCellViewModel] = []
        
        // Load top level comment cell view models
        for i in 0..<dataModels.count {
            let commentViewModel = CommentCellViewModel()
            topLevelComments.append(commentViewModel)
            
            let dataModel = dataModels[i]
            self.dataProvider?.bind(commentCellViewModel: commentViewModel, dataModel: dataModel)
        }
        
        return topLevelComments
    }
    
    private func getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels topLevelViewModels: [CommentCellViewModel]) -> [CommentCellViewModel] {
        var commentCellViewModelsAll: [CommentCellViewModel] = []
        
        for viewModel in topLevelViewModels {
            // Append each view model, reguardless if collapsed or not
            commentCellViewModelsAll.append(viewModel)
            
            // Then append its children only if THIS viewmodel is visible
            if viewModel.isMinimized.value == false {
                
                // Load More Comments
                // If hasMore children that were not yet fetched by latest request, create a model for "load more"
                if viewModel.hasMoreUnloadedChildren == true {
                    if let loadMoreCommentCellViewModel = self.getLoadMoreCellViewModel(withParentViewModel: viewModel) {
                        // Add it as a child of current view model
                        viewModel.addChild(viewModel: loadMoreCommentCellViewModel)
                        
                        // Turn off once appended
                        viewModel.hasMoreUnloadedChildren = false
                    }
                }
                
                
                let childrenViewModels = self.getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels: viewModel.children)
                
                
                commentCellViewModelsAll.append(contentsOf: childrenViewModels)
            }
        }
        
        return commentCellViewModelsAll
    }
    
    private func getLoadMoreCellViewModel(numOfComments: Int, lastCommentIndex: Int) -> CommentCellViewModel {
        let loadMoreCommentCellViewModel = CommentCellViewModel()
        let loadMoreCommentCellVmInitData = self.getLoadMoreCommentCellVmInitData(numOfComments: numOfComments, lastCommentIndex: lastCommentIndex)
        
        loadMoreCommentCellViewModel.loadInitData(initData: loadMoreCommentCellVmInitData)
        loadMoreCommentCellViewModel.isLoadMoreCell = true
        loadMoreCommentCellViewModel.childDepthIndex = 0 // top level comment
        
        return loadMoreCommentCellViewModel
    }
    
    private func getLoadMoreCellViewModel(withParentViewModel parentViewModel: CommentCellViewModel?) -> CommentCellViewModel? {
        
        // If no parent view model
        guard parentViewModel != nil else {
            return nil
        }
        
        let loadMoreCommentCellViewModel = CommentCellViewModel()
        let loadMoreCommentCellVmInitData = self.getLoadMoreCommentCellVmInitData(fromParentViewModel: parentViewModel!)
        loadMoreCommentCellViewModel.loadInitData(initData: loadMoreCommentCellVmInitData!)
        loadMoreCommentCellViewModel.isLoadMoreCell = true
        loadMoreCommentCellViewModel.childDepthIndex = parentViewModel!.childDepthIndex+1
        
        return loadMoreCommentCellViewModel
    }
    
    private func getLoadMoreCommentCellVmInitData(fromParentViewModel parentViewModel: CommentCellViewModel?) -> CommentCellViewModelInitData? {
        
        guard parentViewModel != nil else {
            return nil
        }
        
        var loadMoreCommentCellVmInitData = CommentCellViewModelInitData()
        loadMoreCommentCellVmInitData.isMinimized = true
        loadMoreCommentCellVmInitData.usernameString = "Load More Comments (\(parentViewModel!.remainingChildrenCount) more)"
        loadMoreCommentCellVmInitData.parentId = parentViewModel!.id
        loadMoreCommentCellVmInitData.latestChildIndex = parentViewModel!.latestChildIndex
        
        return loadMoreCommentCellVmInitData
    }
    
    private func getLoadMoreCommentCellVmInitData(numOfComments: Int, lastCommentIndex: Int) -> CommentCellViewModelInitData {
        var loadMoreCommentCellVmInitData = CommentCellViewModelInitData()
        loadMoreCommentCellVmInitData.isMinimized = true
        loadMoreCommentCellVmInitData.usernameString = "Load More Comments (\(numOfComments) more)"
        loadMoreCommentCellVmInitData.latestChildIndex = lastCommentIndex // top level comment
        loadMoreCommentCellVmInitData.parentId = -1 // This is required for top level comment retrieval
        return loadMoreCommentCellVmInitData

    }
    
    private func setAllCommentViewModelChildDepthIndexes(topLevelViewModels: [CommentCellViewModel], startingDepthIndex: Int) {
        
        for viewModel in topLevelViewModels {
            viewModel.childDepthIndex = startingDepthIndex
            
            self.setAllCommentViewModelChildDepthIndexes(topLevelViewModels: viewModel.children, startingDepthIndex: startingDepthIndex + 1)
        }
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
        
        // We don't do an exclusion of .count (count-1) because the first section are submission cells
        guard self.commentsViewModels.count >= section else {
            return self.CELL_SPACING
        }
        // Only separate top level comments
        let commentCellIndex = section - 1
        if self.commentsViewModels[commentCellIndex].childDepthIndex == 0 {
            return self.CELL_SPACING
        }
        
        // This should be for all cells that are not top level
        return 0
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
                    let submissionTextCellVm = self.submissionTextContentVm
                    return submissionTextCellVm.cellHeight
                case .link:
                    let submissionLinkCellVm = self.submissionLinkContentVm
                    return submissionLinkCellVm.cellHeight
                case .image:
                    let submissionImageCellVm = self.submissionImageContentVm
                    return submissionImageCellVm.cellHeight
                case .undetermined:
                    return self.progressCellVm.cellHeight
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
            let sampleActivityIndicatorVm = ActivityIndicatorCellViewModel()
            return sampleActivityIndicatorVm.cellHeight
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
                    textCell.bind(toViewModel: self.submissionTextContentVm)
                    textCell.textView.delegate = self
                    return textCell
                    
                case .image:
                    let imageCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_IMAGE_CELL_REUSE_ID, for: indexPath) as! SubmissionImageCell
                    imageCell.bindImage(fromViewModel: self.submissionImageContentVm)
                    
                    return imageCell
                    
                case .link:
                    let linkCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_LINK_CELL_REUSE_ID, for: indexPath) as! SubmissionLinkCell
                    linkCell.bind(toViewModel: self.submissionLinkContentVm)
                    
                    DispatchQueue.global(qos: .background).async {
                        self.submissionLinkContentVm.downloadThumbnail()
                        DispatchQueue.main.async {
                            linkCell.bindThumbnailImage(fromViewModel: self.submissionLinkContentVm)
                        }
                    }
                    return linkCell
                    
                case .undetermined:
                    // No submission type determined, is probably loading
                    let progressIndicatorCell = tableView.dequeueReusableCell(withIdentifier: self.PROGRESS_INDICATOR_CELL_REUSE_ID, for: indexPath) as! ProgressIndicatorCell
                    progressIndicatorCell.bind(toViewModel: self.progressCellVm)
                    
                    return progressIndicatorCell
                    
                default:
                    // Default to a link cell with no bindings
                    let linkCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_LINK_CELL_REUSE_ID, for: indexPath) as! SubmissionLinkCell
                    
                    return linkCell
                }
            } else {
                // If third row, SortedBy Cell
                let sortByCell = tableView.dequeueReusableCell(withIdentifier: self.SORTED_BY_CELL_REUSE_ID, for: indexPath) as! CommentsSortByCell
                sortByCell.bind(toViewModel: self.commentsSortByVm!)
                sortByCell.navigationController = self.navigationController
                sortByCell.delegate = self
                //self.sfxManager?.applyShadow(view: sortByCell)
                
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
            let commentCellViewModelIndex = indexPath.section - 1
            let commentCellViewModel = self.commentsViewModels[commentCellViewModelIndex]
            commentCell.delegate = self
            commentCell.bind(toViewModel: commentCellViewModel)
            commentCell.textView.delegate = self
            
            
            return commentCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // If touched sorted By bar, trigger the segue
        /* TODO: Disabled sortby right now
        if indexPath.section == 0 && indexPath.row == 2 {
            let sortByCell = tableView.cellForRow(at: indexPath) as! CommentsSortByCell
            sortByCell.sortByTouched(sortByCell.sortByButton)
        }
 */
        
        // Open Content
        // If is a content cell, launch link
        if indexPath.section == 0 && indexPath.row == 1 {
            if self.submissionMediaType != .text {
                switch self.submissionMediaType {
                case .link:
                    self.openSafariViewController(link: self.submissionLinkContentVm.link)
                case .image:
                    self.openSafariViewController(link: self.submissionImageContentVm.imageLink)
                default:
                    break;
                }
                
            }
        }
        
        // Minimize and Maximize comment cell
        if indexPath.section >= 1 {
            let viewModelIndex = indexPath.section-1
            let commentCellVm = self.commentsViewModels[viewModelIndex]
            commentCellVm.toggleMinimized()
            
            // Find out of minimized or maximized
            // If minimized
            if commentCellVm.isMinimized.value == true {
                self.minimizeCommentCell(forViewModel: commentCellVm, indexPath: indexPath)
            }
            else {
                
                // If cell is a "load more"
                if commentCellVm.isLoadMoreCell {
                    
                    self.requestChildComments(subverse: self.submissionDataModel!.subverseName, submissionId: self.submissionDataModel!.id, parentId: commentCellVm.parentId, startingIndex: commentCellVm.latestChildIndex+1) { commentCellViewModels in
                        
                        self.insertCommentsIntoLoadMore(loadMoreCellViewModel:commentCellVm, atIndex: viewModelIndex, commentCellViewModels: commentCellViewModels)
                        
                    }
                } else {
                    self.maximizeCommentCell(forViewModel: commentCellVm, indexPath: indexPath)
                }
            }
        }
    }
    
    private func insertCommentsIntoLoadMore(loadMoreCellViewModel: CommentCellViewModel, atIndex viewModelIndex: Int, commentCellViewModels: [CommentCellViewModel]) {
        
        // Guard against the parent not existing if the loadMoreCell is a top level comment
        if loadMoreCellViewModel.childDepthIndex != 0 {
            
            // Remove child from parent, add new cells to parent
            if let parentCommentCellViewModel = loadMoreCellViewModel.parent {
                if parentCommentCellViewModel.children.count > 0 {
                    parentCommentCellViewModel.removeLastChild()
                }
                
                for viewModel in commentCellViewModels {
                    parentCommentCellViewModel.addChild(viewModel: viewModel)
                }
            }
        }
        
        // Set the child depth indexes
        self.setAllCommentViewModelChildDepthIndexes(topLevelViewModels: commentCellViewModels, startingDepthIndex: loadMoreCellViewModel.childDepthIndex)
        
        // Get uncollapsed tree from children
        let commentCellViewModelsLinearArray = self.getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels: commentCellViewModels)
        
        // Replace LoadMoreCell with contents of first view model
        self.commentsViewModels.remove(at: viewModelIndex)
        self.commentsViewModels.insert(contentsOf: commentCellViewModelsLinearArray, at: viewModelIndex)
        
        // reload table
        // The viewModelIndex is always indexPath.section-1, so we have to add 1 to animate the location of section
        let startingIndex = viewModelIndex + 1
        let endingIndexExclusive = startingIndex + commentCellViewModelsLinearArray.count
        self.reloadTableAnimated(startingIndexInclusive: startingIndex, endingIndexExclusive: endingIndexExclusive, animation: .fade)
    }
    
    private func minimizeCommentCell(forViewModel viewModel: CommentCellViewModel, indexPath: IndexPath) {
        tableView.beginUpdates()
        
        // Get the total number of child cells removed
        let numOfChildCellsToRemove = viewModel.numOfVisibleChildren
        
        // Remove them from the array
        let indexOfCommentCellVm = indexPath.section - 1
        let lowerBound = indexOfCommentCellVm + 1
        let upperBound = lowerBound + numOfChildCellsToRemove
        let rangeToRemove = Range.init(uncheckedBounds: (lower: lowerBound, upper: upperBound))
        self.commentsViewModels.removeSubrange(rangeToRemove)
        
        // The rangetoUpdate has to account for cells start at IndexPath.section+1
        let rangeToUpdate = Range.init(uncheckedBounds: (lower: lowerBound+1, upper: upperBound+1))
        
        let indexSet = IndexSet.init(integersIn: rangeToUpdate)
        tableView.deleteSections(indexSet, with: .fade)
        
        tableView.endUpdates()
    }
    
    private func maximizeCommentCell(forViewModel viewModel: CommentCellViewModel, indexPath: IndexPath) {
        
        
        // If maximized
        // Get the total number of child cells shown
        // Insert them into the array
        let currentIndex = indexPath.section - 1
        
        var childrenVmToAdd = self.getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels: [viewModel])
        // Remove the first child, which is the top node
        childrenVmToAdd.remove(at: 0)
        
        self.commentsViewModels.insert(contentsOf: childrenVmToAdd, at: currentIndex+1)
        
        // Account for sections of cells start at indexPath.section + 1
        self.animateInsertComments(startingIndex: indexPath.section+1, numOfObjects: childrenVmToAdd.count)
    }
    
    private func animateInsertComments(startingIndex: Int, numOfObjects: Int) {
        tableView.beginUpdates()
        
        let lowerBoundToInsert = startingIndex
        let upperBoundToInsert = lowerBoundToInsert + numOfObjects
        let rangeToInsert = Range.init(uncheckedBounds: (lower: lowerBoundToInsert, upper: upperBoundToInsert))
        let indexSet = IndexSet.init(integersIn: rangeToInsert)
        
        tableView.insertSections(indexSet, with: .fade)
        
        // Update the table for those rows
        tableView.endUpdates()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Forces redraw of shadows right before transition
        self.tableView.reloadData()
    }

    

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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let linkString = URL.absoluteString
        self.openSafariViewController(link: linkString)
        
        return false
    }
    
    // delegate callback
    func commentsSortByCell(cell: CommentsSortByCell, didSortBy sortType: SortTypeComments) {
        // Sort the comment cells
        
        // By New - ComparisonResult.orderedDescending
        if sortType == SortTypeComments.new {
            self.commentsViewModels.sort { (commentVmA, commentVmB) -> Bool in
                return commentVmA.date?.compare(commentVmB.date!) == ComparisonResult.orderedDescending
            }
        }
        // By Top
        else if sortType == SortTypeComments.top {
            self.commentsViewModels.sort(by: { (commentVmA, commentVmB) -> Bool in
                return commentVmA.voteCountTotal.value >= commentVmB.voteCountTotal.value
            })
        }
        
        // Reload the Comments
        self.reloadTableCommentsAnimated()
    }
    
    private func isCellLastInGroup(inViewModels viewModels: [CommentCellViewModel], index: Int) -> Bool{
        // Check next cell
        let nextIndex = index+1
        
        guard nextIndex <= viewModels.count-1 else {
            return true
        }
        
        // If next cell is a new top-level comment, this one is a last in group
        let nextCellViewModel = viewModels[nextIndex]
        if nextCellViewModel.childDepthIndex == 0 {
            return true
        }
        
        return false
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        
        #if DEBUG
        print ("Deallocated Comments View Controller")
        #endif
    }
}

extension CommentsViewController: SFSafariViewControllerDelegate {
    fileprivate func openSafariViewController(link: String) {
        
        // Analytics
        let params = AnalyticsEvents.getCommentsControllerOpenContentParams(subverseName: self.submissionDataModel!.subverseName, mediaType: self.submissionMediaType)
        self.analyticsManager?.logEvent(name: AnalyticsEvents.commentsControllerOpenContent, params: params, timed: false)
        
        var formattedLink = link
        if link.lowercased().hasPrefix("http://")==false && link.lowercased().hasPrefix("https://") == false {
            formattedLink = "http://" + link
        }
        
        let safariController = SFSafariViewController(url: URL(string: formattedLink)!, entersReaderIfAvailable: false)
        safariController.delegate = self
        self.present(safariController, animated: true, completion: {
            
            UIApplication.shared.statusBarStyle = .default
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension CommentsViewController: CommentCellDelegate{
    func commentCellDidChange(commentCell: CommentCell) {
        // Get the index, reload table row
        if let indexPath = self.tableView.indexPath(for: commentCell) {
            
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Share
    func commentsSortByCell(cell: CommentsSortByCell, didPressShare: Any) {
        
        // Analytics
        let params = AnalyticsEvents.getCommentsControllerShareParams(subverseName: self.submissionDataModel!.subverseName, mediaType: self.submissionMediaType)
        self.analyticsManager?.logEvent(name: AnalyticsEvents.commentsControllerShare, params: params, timed: false)
        
        self.shareActivities()
    }
    
    private func getTextLink(dataModel: SubmissionDataModelProtocol) -> String {
        let link = "https://voat.co/v/\(dataModel.subverseName)/\(dataModel.id)"
        return link
    }
    
    private func shareActivities() {
        
        DispatchQueue.global(qos: .background).async {
            var activityItems: [Any] = []
            switch self.submissionMediaType {
            case .text:
                activityItems.append(self.getTextLink(dataModel: self.submissionDataModel!))
            case .image:
                activityItems.append(self.submissionImageContentVm.imageLink)
            case .link:
                activityItems.append(self.submissionLinkContentVm.link)
            default:
                activityItems.append(self.submissionLinkContentVm.link)
            }
            let activityViewController = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
            
            DispatchQueue.main.async {
                self.navigationController?.present(activityViewController, animated: true, completion: {
                    
                })
            }
        }
    }
}
