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
import SwinjectStoryboard

class CommentsViewController: UITableViewController, UITextViewDelegate, CommentsSortByCellDelegate {
    
    var backgroundColor = UIColor.white
    // Sections
    
    var numOfSectionsBeforeComments: Int = 0
    let DISABLED_SECTION_NUMBER = -1
    
    var submissionSectionNumber = 0
    var adSectionNumber = 1
    var commentsSectionNumber = 2
    
    // Display formatting
    private let CELL_SPACING: CGFloat = 10.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private var numOfCellsToDisplay = 0
    private let BOTTOM_INSET: CGFloat = 50.0
    fileprivate let BLOCK_USER_ACTIVITY_INDICATOR_DELAY: Float = 1.0
    
    // Cell configuration
    let COMMENT_CELL_REUSE_ID = "CommentCell"
    let SUBMISSION_TITLE_CELL_REUSE_ID = "SubmissionTitleCell"
    let SUBMISSION_TEXT_CELL_REUSE_ID = "SubmissionTextCell"
    let SUBMISSION_LINK_CELL_REUSE_ID = "SubmissionLinkCell"
    let SUBMISSION_IMAGE_CELL_REUSE_ID = "SubmissionImageCell"
    let PROGRESS_INDICATOR_CELL_REUSE_ID = "ProgressIndicatorCell"
    let AD_CELL_REUSE_ID = "AdCell"
    
    let ACTIVITY_INDICATOR_CELL_REUSE_ID = "ActivityIndicatorCell"
    let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    let LOAD_MORE_COMMENTS_CELL_REUSE_ID = "LoadMoreComments"
    let SORTED_BY_CELL_REUSE_ID = "SortByCell"
    
    let WEBVIEW_SEGUE_ID = "WebViewSegue"
    
    var submissionDataModel: SubmissionDataModelProtocol?
    var verionDataModel: VerionDataModel?
    
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
    fileprivate var submittedComments: [CommentCellViewModel] = []
    
    let BLOCKED_USER_TEXT = "(This user is blocked)"
    
    // Navigation Bar items
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    private var activityIndicatorCell: ActivityIndicatorCell?
    
    // Web View Controller 
    var linkString = ""
    
    // Compose Comment
    fileprivate var composeCommentVc: ComposeCommentViewController?
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType?
    var analyticsManager: AnalyticsManagerProtocol?
    var adManager: AdManager?
    var dataManager: DataManagerProtocol?
    var loginScreen: LoginScreenProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = self.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.setBottomInset()
        self.loadData()
        self.loadSubmissionInfo {
            
            self.loadCommentCells {
                
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func loadData() {
        self.verionDataModel = self.dataManager?.getSavedData()
        
        // Configure sections based on whether or not ads were removed
        self.submissionSectionNumber = 0 // Always 0
        
        if self.adManager?.isRemoveAdsPurchased() == true {
            // Ads are removed
            self.adSectionNumber = self.DISABLED_SECTION_NUMBER
            self.commentsSectionNumber = self.submissionSectionNumber + 1
            self.numOfSectionsBeforeComments = 1
        } else {
            // Ads are not removed, will be put in
            self.adSectionNumber = 1
            self.commentsSectionNumber = self.adSectionNumber + 1
            self.numOfSectionsBeforeComments = 2
            
            // Pre-emptively Load the banner ad
            _ = self.adManager?.getBannerAd(rootViewController: self)
        }
    }
    
    fileprivate func saveData() {
        self.dataManager?.saveData(dataModel: self.verionDataModel!)
    }
    
    private func setBottomInset() {
        // Set bottom content Inset for possible ad-placement
        let topDefaultInset = self.tableView.contentInset.top
        let bottomInset = self.BOTTOM_INSET
        self.tableView.contentInset = UIEdgeInsets(top: topDefaultInset, left: 0, bottom: bottomInset, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func reloadTableCommentsAnimated() {
        self.reloadTableAnimated(startingIndexInclusive: self.numOfSectionsBeforeComments, endingIndexExclusive: self.commentsViewModels.count+self.numOfSectionsBeforeComments, animation: .automatic)
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
                
                // Load More cell - create
                if commentDataSegment != nil {
                    if commentDataSegment!.hasMore {
                        // Add to toplevel comments
                        let loadMoreCommentsViewModel = self.getLoadMoreCellViewModel(numOfComments: commentDataSegment!.remainingCount, lastCommentIndex: commentDataSegment!.endingIndex)
                        topLevelCommentVms.append(loadMoreCommentsViewModel)
                    }
                }
                
                // Filter posts retrieved that were created by App submitting it in the first place
                let filteredTopLevelCommentsNoSubmittedComments = self.filterComments(sourceComments: topLevelCommentVms, withCommentsToExclude: self.submittedComments)
                
                let filteredNoDuplicates = self.filterComments(sourceComments: filteredTopLevelCommentsNoSubmittedComments, withCommentsToExclude: self.commentsViewModels)
                
                DispatchQueue.main.async {
                    completion(filteredNoDuplicates)
                }
            }
        }
    }
    
    private func filterComments(sourceComments: [CommentCellViewModel], withCommentsToExclude excludedComments: [CommentCellViewModel]) -> [CommentCellViewModel] {
        
        let filteredComments = sourceComments.filter { (commentCellViewModel) -> Bool in
            var areCommentsDifferent = true
            for commentToExclude in excludedComments {
                if commentCellViewModel.id == commentToExclude.id {
                    areCommentsDifferent = false
                    break
                }
            }
            
            return areCommentsDifferent
        }
        
        return filteredComments
    }
    
    // Load Comments from Data Provider
    fileprivate func loadCommentCells(completion: @escaping ()->()) {
        self.dataProvider?.requestComments(subverse:self.submissionDataModel!.subverseName, submissionId: self.submissionDataModel!.id, completion: { (commentDataModels, commentDataSegment, error) in
            
            guard error == nil else {
                // Failure
                
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                
                // Reset comment cells
                self.commentsViewModels.removeAll()
                
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
                
                // Bind events
                self.bindCommentCellViewModelsToDataProvider(viewModels: allCommentViewModelsLinearArray)
                
                self.blockUsersFromList(commentCellViewModels: allCommentViewModelsLinearArray)
                
                self.commentsViewModels.append(contentsOf: allCommentViewModelsLinearArray)
                
                self.areCommentsLoaded = true
                
                
                DispatchQueue.main.async {
                    self.reloadTableCommentsAnimated()
                    
                    completion()
                }
                
            }
        })
        
        completion()
    }
    
    private func blockUsersFromList(commentCellViewModels: [CommentCellViewModel]) {
        
        for viewModel in commentCellViewModels {
            if self.verionDataModel!.blockedUsers!.contains(viewModel.usernameString) {
                self.setUserAsBlocked(forViewModel: viewModel)
            }
        }
    }
    
    
    private func setUserAsBlocked(forViewModel viewModel: CommentCellViewModel){
        viewModel.attributedTextString = NSAttributedString.init(string: self.BLOCKED_USER_TEXT)
        viewModel.isBlocked = true
    }
    
    private func getTopLevelCommentViewModels(fromDataModels dataModels: [CommentDataModelProtocol]) -> [CommentCellViewModel] {
        
        var topLevelComments: [CommentCellViewModel] = []
        
        // Load top level comment cell view models
        for i in 0..<dataModels.count {
            let commentViewModel = CommentCellViewModel()
            topLevelComments.append(commentViewModel)
            
            let dataModel = dataModels[i]
            self.dataProvider?.bindTopLevelCommentViewModel(commentCellViewModel: commentViewModel, dataModel: dataModel)
        }
        
        return topLevelComments
    }
    
    private func getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels topLevelViewModels: [CommentCellViewModel]) -> [CommentCellViewModel] {
        var commentCellViewModelsAll: [CommentCellViewModel] = []
        
        for i in 0..<topLevelViewModels.count {
            let viewModel = topLevelViewModels[i]
            
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
    
    private func bindCommentCellViewModelsToDataProvider(viewModels: [CommentCellViewModel]) {
        for viewModel in viewModels {
            self.dataProvider?.bind(commentCellViewModel: viewModel, viewController: self)
        }
    }
    
    private func isUserBlocked(forViewModel viewModel: CommentCellViewModel) -> Bool {
        if self.verionDataModel!.blockedUsers!.contains(viewModel.usernameString) {
            return true
        }
        
        return false
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let numOfSections: Int
        
        if self.areCommentsLoaded == false {
            numOfSections = 3
        }
        else {
            numOfSections = self.commentsViewModels.count + self.numOfSectionsBeforeComments // 1 extra section for submission cells
        }
        
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Submission Cells
        if section == self.submissionSectionNumber {
            // View Models must be initialized
            if self.areSubmissionViewModelsLoaded() == true {
                return 3
            }
            else {
                return 0
            }
        } else {
            
            // Always 1 row per comments/ads
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
        if section == self.submissionSectionNumber {
            return 0
        } else if section == self.adSectionNumber {
            return self.CELL_SPACING
        } else {
            guard section <= self.commentsViewModels.count-1 + self.numOfSectionsBeforeComments else {
                // Perhaps this should never be reached
                return self.CELL_SPACING
            }
            
            
            // Only separate top level comments
            let commentCellIndex = section - self.numOfSectionsBeforeComments
            if self.commentsViewModels[commentCellIndex].childDepthIndex == 0 {
                return self.CELL_SPACING
            }
            
            // This should be for all cells that are not top level
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.areSubmissionViewModelsLoaded() != false else {
            return 0
        }
        
        if indexPath.section == self.submissionSectionNumber {
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
        } else if indexPath.section == self.adSectionNumber {
            
            let advertisementTitleHeight: CGFloat = 20.0
            let adCellHeight = advertisementTitleHeight + self.adManager!.getBannerAdHeight()
            
            return adCellHeight
            
        } else {
            guard self.areCommentsLoaded != false else {
                let sampleActivityIndicatorVm = ActivityIndicatorCellViewModel()
                return sampleActivityIndicatorVm.cellHeight
            }
            
            if self.commentsViewModels.count > 0 {
                // Comment Cell Height
                let commentCellVm = self.commentsViewModels[indexPath.section-self.numOfSectionsBeforeComments]
                let cellHeight = commentCellVm.cellHeight
                
                return cellHeight
            }
            
            // This should never be reached
            let defaultHeight: CGFloat = 50.0
            
            return defaultHeight
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == self.submissionSectionNumber {
            
            // If first row, Title Cell
            if indexPath.row == 0 {
                
                let titleCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_TITLE_CELL_REUSE_ID, for: indexPath) as! SubmissionTitleCell
                titleCell.bind(toViewModel: self.submissionTitleVm!, shouldFilterLanguage: self.verionDataModel!.shouldFilterLanguage)
                
                return titleCell
                
            } else if indexPath.row == 1 {
                
                // If second row, Content Cell
                switch self.submissionMediaType {
                case .text:
                    let textCell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_TEXT_CELL_REUSE_ID, for: indexPath) as! SubmissionTextCell
                    textCell.bind(toViewModel: self.submissionTextContentVm, shouldFilterLanguage: self.verionDataModel!.shouldFilterLanguage)
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
                
                return sortByCell
            }
        } else if indexPath.section == self.adSectionNumber {
            let adCell = tableView.dequeueReusableCell(withIdentifier: self.AD_CELL_REUSE_ID, for: indexPath) as! AdCell
            
            // Set the ad cell's banner view
            adCell.adView.addSubview(self.adManager!.getBannerAd(rootViewController: self)!)
            
            return adCell
            
        } else {
            
            
            // Loading Comment Cell
            if self.areCommentsLoaded == false {
                
                // Activity Indicator for a 'Loading' cell
                if self.activityIndicatorCell != nil {
                    self.activityIndicatorCell?.removeActivityIndicator()
                }
                
                self.activityIndicatorCell = tableView.dequeueReusableCell(withIdentifier: self.ACTIVITY_INDICATOR_CELL_REUSE_ID, for: indexPath) as? ActivityIndicatorCell
                self.activityIndicatorCell?.loadActivityIndicator(length: self.ACTIVITY_INDICATOR_LENGTH, color: (self.navigationController?.navigationBar.barTintColor)!)
                self.activityIndicatorCell?.showActivityIndicator()
                return self.activityIndicatorCell!
            }
            else {
                // Comment cells
                
                let commentCell = tableView.dequeueReusableCell(withIdentifier: self.COMMENT_CELL_REUSE_ID, for: indexPath) as! CommentCell
                let commentCellViewModelIndex = indexPath.section - self.numOfSectionsBeforeComments
                let commentCellViewModel = self.commentsViewModels[commentCellViewModelIndex]
                commentCell.delegate = self
                commentCell.bind(toViewModel: commentCellViewModel, shouldFilterLanguage: self.verionDataModel!.shouldFilterLanguage)
                commentCell.textView.delegate = self
                
                
                return commentCell
            }
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
        if self.isCommentsSection(indexPath.section) {
            let viewModelIndex = indexPath.section - self.numOfSectionsBeforeComments
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
    
    private func isCommentsSection(_ sectionIndex: Int) -> Bool{
        return sectionIndex >= self.numOfSectionsBeforeComments
    }
    
    private func insertCommentsIntoLoadMore(loadMoreCellViewModel: CommentCellViewModel, atIndex viewModelIndex: Int, commentCellViewModels: [CommentCellViewModel]) {
        
        // Guard against the parent not existing if the loadMoreCell is not a top level comment (child comment)
        if loadMoreCellViewModel.childDepthIndex != 0 {
            
            // Remove load more child cell from parent, replace with new cells to parent
            if let parentCommentCellViewModel = loadMoreCellViewModel.parent {
                if parentCommentCellViewModel.children.count > 0 {
                    parentCommentCellViewModel.removeLastChild()
                }
                
                for i in 0..<commentCellViewModels.count {
                    let viewModel = commentCellViewModels[i]
                    parentCommentCellViewModel.addChild(viewModel: viewModel)
                }
            }
        }
        
        // Get uncollapsed tree from children
        let commentCellViewModelsLinearArray = self.getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels: commentCellViewModels)
        
        // Bind events
        self.bindCommentCellViewModelsToDataProvider(viewModels: commentCellViewModelsLinearArray)
        
        self.blockUsersFromList(commentCellViewModels: commentCellViewModelsLinearArray)
        
        // Replace LoadMoreCell with contents of first view model
        self.commentsViewModels.remove(at: viewModelIndex)
        self.commentsViewModels.insert(contentsOf: commentCellViewModelsLinearArray, at: viewModelIndex)
        
        // reload table
        let startingIndex = viewModelIndex + self.numOfSectionsBeforeComments
        let endingIndexExclusive = startingIndex + commentCellViewModelsLinearArray.count
        self.reloadTableAnimated(startingIndexInclusive: startingIndex, endingIndexExclusive: endingIndexExclusive, animation: .fade)
    }
    
    private func minimizeCommentCell(forViewModel viewModel: CommentCellViewModel, indexPath: IndexPath) {
        tableView.beginUpdates()
        
        // Get the total number of child cells removed
        let numOfChildCellsToRemove = viewModel.numOfVisibleChildren
        
        // Remove them from the array
        let indexOfCommentCellVm = indexPath.section - self.numOfSectionsBeforeComments
        let lowerBound = indexOfCommentCellVm + 1
        let upperBound = lowerBound + numOfChildCellsToRemove
        let rangeToRemove = Range.init(uncheckedBounds: (lower: lowerBound, upper: upperBound))
        self.commentsViewModels.removeSubrange(rangeToRemove)
        
        // The rangetoUpdate has to account for cells start at IndexPath.section+1
        let rangeToUpdate = Range.init(uncheckedBounds: (lower: lowerBound + self.numOfSectionsBeforeComments, upper: upperBound + self.numOfSectionsBeforeComments))
        
        let indexSet = IndexSet.init(integersIn: rangeToUpdate)
        tableView.deleteSections(indexSet, with: .fade)
        
        tableView.endUpdates()
    }
    
    private func maximizeCommentCell(forViewModel viewModel: CommentCellViewModel, indexPath: IndexPath) {
        
        // If maximized
        // Get the total number of child cells shown
        // Insert them into the array
        let currentIndex = indexPath.section - self.numOfSectionsBeforeComments
        
        var childrenVmToAdd = self.getAllCommentViewModelsInTreeIfUncollapsed(fromTopLevelViewModels: [viewModel])
        // Remove the first child, which is the top node
        childrenVmToAdd.remove(at: 0)
        
        // Bind events
        self.bindCommentCellViewModelsToDataProvider(viewModels: childrenVmToAdd)
        
        self.commentsViewModels.insert(contentsOf: childrenVmToAdd, at: currentIndex+1)
        
        self.animateInsertComments(startingIndex: indexPath.section + 1, numOfObjects: childrenVmToAdd.count)
    }
    
    private func animateInsertComments(startingIndex: Int, numOfObjects: Int) {
        tableView.beginUpdates()
        
        let lowerBoundToInsert = startingIndex
        let upperBoundToInsert = lowerBoundToInsert + numOfObjects
        let rangeToInsert = Range.init(uncheckedBounds: (lower: lowerBoundToInsert, upper: upperBoundToInsert))
        let indexSet = IndexSet.init(integersIn: rangeToInsert)
        
        tableView.insertSections(indexSet, with: .bottom)
        
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { alertAction in
            
        }))
        
        self.present(alertController, animated: true) {
            
        }
    }
    
    fileprivate func getIndexOfCommentViewModel(byId id: Int64) -> Int? {
        var index: Int?
        
        for i in 0..<self.commentsViewModels.count {
            
            let viewModel = self.commentsViewModels[i]
            
            if viewModel.id == id {
                index = i
                break
            }
        }
        
        return index
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        
        #if DEBUG
        print ("Deallocated Comments View Controller")
        #endif
    }
}

// MARK: - Submit comments

extension CommentsViewController: ComposeCommentViewControllerDelegate {
    
    fileprivate func showSubmitCommentView(type: CommentResponseType, commentId: Int64?) {
        
        if self.composeCommentVc != nil {
            guard self.composeCommentVc?.isShown == false else {
                // If currently showing, do not show
                
                return
            }
        }
        
        // Prepare data
        var commentSubmissionDataModel = ComposeCommentViewControllerDataModel()
        commentSubmissionDataModel.submissionId = (self.submissionDataModel?.id)!
        commentSubmissionDataModel.subverseName = (self.submissionDataModel?.subverseName)!
        commentSubmissionDataModel.username = (self.dataManager?.getUsernameFromKeychain())!
        commentSubmissionDataModel.type = type
        
        // Set Comment Id if applicable
        switch type {
        case .topLevelComment:
            // do nothing
            break
        case .reply:
            // Set comment ID
            if commentId == nil {
                fatalError("Comment ID required for Comment Reply submissions.")
            }
            commentSubmissionDataModel.commentId = commentId!
        }
        
        // Initialize if not initialized
        if self.composeCommentVc == nil {
            let composeCommentSb = SwinjectStoryboard.create(name: "Comments", bundle: nil)
            self.composeCommentVc = composeCommentSb.instantiateViewController(withIdentifier: "ComposeCommentViewController") as? ComposeCommentViewController
            self.composeCommentVc?.delegate = self
            
            // Force call of viewDidLoad()
            _ = self.composeCommentVc?.view
        }
        
        self.composeCommentVc?.showTextView(rootViewController: self.navigationController!, dataModel: commentSubmissionDataModel)
    }
    
    // MARK: - Compose Comments VC Delegate methods
    
    func composeCommentViewControllerDidClose(controller: ComposeCommentViewController) {
        
    }
    
    func composeCommentViewControllerSubmittedComment(controller: ComposeCommentViewController, composeCommentDataModel: ComposeCommentViewControllerDataModel, commentDataModel: CommentDataModelProtocol) {
        
        switch composeCommentDataModel.type {
        case .topLevelComment:
            self.addTopLevelComment(commentDataModel: commentDataModel)
        case .reply:
            self.addReplyComment(commentDataModel: commentDataModel, parentCommentId: composeCommentDataModel.commentId)
        }
    }
    
    fileprivate func addTopLevelComment(commentDataModel: CommentDataModelProtocol) {
        // Create view model and bind
        let viewModel = CommentCellViewModel()
        self.dataProvider?.bindTopLevelCommentViewModel(commentCellViewModel: viewModel, dataModel: commentDataModel)
        
        // Add view model to self.viewmodels
        self.commentsViewModels.insert(viewModel, at: 0)
        
        self.submittedComments.append(viewModel)
        
        // Reload table
        self.reloadTableCommentsAnimated()
    }
    
    fileprivate func addReplyComment(commentDataModel: CommentDataModelProtocol, parentCommentId: Int64) {
        // Create view model and bind
        let viewModel = CommentCellViewModel()
        self.dataProvider?.bindTopLevelCommentViewModel(commentCellViewModel: viewModel, dataModel: commentDataModel)
        
        // Insert View Model into parent
        // Find parent
        if let parentCommentViewModelIndex = self.getIndexOfCommentViewModel(byId: parentCommentId) {
            
            let parentCommentViewModel = self.commentsViewModels[parentCommentViewModelIndex]
            parentCommentViewModel.addChild(viewModel: viewModel)
            self.commentsViewModels.insert(viewModel, at: parentCommentViewModelIndex+1)
            
            self.submittedComments.append(viewModel)
            
            // Reload table
            self.reloadTableCommentsAnimated()
        }
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
    
    // Block user
    func commentCellDidPressBlockUser(commentCell: CommentCell, username: String) {
        
        if commentCell.viewModel?.isBlocked == false {
            
            // Block prompt
            let blockAlert = UIAlertController.init(title: "Block User", message: "Block all comments by this user?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                let activityIndicator = ActivityIndicatorProvider.getAndShowProgressHudActivityIndicator(rootViewController: self.navigationController!)
                
                // Add user to block list
                self.verionDataModel?.blockedUsers!.insert(username)
                self.saveData()
                
                // Refresh comments
                self.loadCommentCells {
                    Delayer.delay(seconds: self.BLOCK_USER_ACTIVITY_INDICATOR_DELAY) {
                        activityIndicator.hide(animated: true)
                    }
                }
            })
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                // do nothing
            })
            
            blockAlert.addAction(cancelAction)
            blockAlert.addAction(yesAction)
            
            self.present(blockAlert, animated: true, completion: nil)
            
        } else {
            
            // Unblock prompot
            let unblockAlert = UIAlertController.init(title: "", message: "Unblock this user?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                
                let activityIndicator = ActivityIndicatorProvider.getAndShowProgressHudActivityIndicator(rootViewController: self.navigationController!)
                
                // unblock user
                _ = self.verionDataModel?.blockedUsers!.remove(username)
                self.saveData()
                
                // Refresh comments
                self.loadCommentCells {
                    Delayer.delay(seconds: self.BLOCK_USER_ACTIVITY_INDICATOR_DELAY) {
                        activityIndicator.hide(animated: true)
                    }
                }
            })
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                // do nothing
            })
            
            unblockAlert.addAction(cancelAction)
            unblockAlert.addAction(yesAction)
            
            self.present(unblockAlert, animated: true, completion: nil)
        }
    }
    
    // Comment Reply
    func commentCellDidPressComment(commentCell: CommentCell, viewModel: CommentCellViewModel) {
        
        let commentReplyClosure: ()->() = { [weak self] in
            self?.showSubmitCommentView(type: .reply, commentId: viewModel.id)
        }
        
        // Check login first
        if OAuth2Handler.sharedInstance.accessToken != "" {
            commentReplyClosure()
        } else {
            self.loginScreen?.presentLogin(rootViewController: self, showConfirmation: true, completion: { (username, error) in
                
                guard error == nil else {
                    self.showAlert(title: "Error", message: "Failed to Sign In")
                    return
                }
                
                // Success
                commentReplyClosure()
            })
        }
    }
    
    
    
    // Share
    func commentsSortByCell(cell: CommentsSortByCell, didPressShare: Any) {
        
        // Analytics
        let params = AnalyticsEvents.getCommentsControllerShareParams(subverseName: self.submissionDataModel!.subverseName, mediaType: self.submissionMediaType)
        self.analyticsManager?.logEvent(name: AnalyticsEvents.commentsControllerShare, params: params, timed: false)
        
        self.shareActivities()
    }
    
    func commentsSortByCell(cell: CommentsSortByCell, didPressReport: Any) {
        
        let reportAlert = UIAlertController.init(title: "Report Content", message: "Report Submission as Inappropriate Content?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.showAlert(title: "Report Submitted", message: "The submission has been reported to Voat and will be reviewed for necessary actions.")
        })
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            // do nothing
        })
        
        reportAlert.addAction(cancelAction)
        reportAlert.addAction(yesAction)
        
        self.present(reportAlert, animated: true, completion: nil)
    }
    
    func commentsSortByCell(cell: CommentsSortByCell, didPressComment: Any) {
        let commentReplyClosure: ()->() = { [weak self] in
            self?.showSubmitCommentView(type: CommentResponseType.topLevelComment, commentId: nil)
        }
        
        // Check login first
        if OAuth2Handler.sharedInstance.accessToken != "" {
            commentReplyClosure()
        } else {
            self.loginScreen?.presentLogin(rootViewController: self, showConfirmation: true, completion: { (username, error) in
                
                guard error == nil else {
                    self.showAlert(title: "Error", message: "Failed to Sign In")
                    return
                }
                
                // Success
                commentReplyClosure()
            })
        }
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
