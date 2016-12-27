//
//  SubverseViewController.swift
//  Verion
//
//  Created by Simon Chen on 11/29/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol SubverseViewControllerDelegate: class {
    func subverseViewController(controller: SubverseViewController, willLoadSubverse subverse: String)
}

class SubverseViewController: UITableViewController, NVActivityIndicatorViewable {
    
    // Cell configuration
    let ACTIVITY_INDICATOR_CELL_REUSE_ID = "ActivityIndicatorCell"
    let SUBMISSION_CELL_REUSE_ID = "SubmissionCell"
    private let CELL_SPACING: CGFloat = 0.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private let DEFAULT_ROW_HEIGHT: CGFloat = 50.0
    
    
    // Pull to Refresh control configuration
    private var REFRESH_CONTROL_PULL_DISTANCE: CGFloat = 50
    private var PULL_TO_REFRESH_STRING = "Pull to Refresh"
    private var PULL_TO_REFRESH_ATTRIBUTED_TITLE = NSAttributedString.init(string: "Pull to Refresh", attributes: [NSForegroundColorAttributeName : UIColor.white])
    private var customRefreshControl: SubverseRefreshControl?
    private var SCROLLVIEW_CONTENT_OFFSET_PORTRAIT: CGFloat = 64
    private var SCROLLVIEW_CONTENT_OFFSET_LANDSCAPE: CGFloat = 32
    private var isLoadingRequest = false {
        didSet {
            if isLoadingRequest == false {
                self.tableView?.isScrollEnabled = true
            } else {
                self.tableView?.isScrollEnabled = false
            }
        }
    }
    var scrollViewContentOffsetY:CGFloat {
        get {
            if UIDevice.current.orientation.isLandscape {
                return SCROLLVIEW_CONTENT_OFFSET_LANDSCAPE
            }
            return SCROLLVIEW_CONTENT_OFFSET_PORTRAIT
        }
        set {
            self.scrollViewContentOffsetY = newValue
        }
    }
    
    private var RELEASE_TO_REFRESH_STRING = "Release to Refresh"
    private var RELEASE_TO_REFRESH_ATTRIBUTED_TITLE = NSAttributedString.init(string: "Release to Refresh", attributes: [NSForegroundColorAttributeName : UIColor.white])
    private let BOTTOM_INSET_HEIGHT: CGFloat = 50
    
    // Sorting
    private let SORT_BY_TITLE = "Sort Submissions by"
    @IBOutlet var sortByButton: UIBarButtonItem!
    
    // Activity Indicator Cell
    private var activityIndicatorCell: ActivityIndicatorCell?
    private var LOADMORE_CELL_INDEX_VALUE = 1
    private let MAX_NUMBER_OF_PAGES = 19
    
    
    // Navigation Bar items
    @IBOutlet var menuButton: UIBarButtonItem!
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    var activityIndicator: NVActivityIndicatorView?
    
    let DEFAULT_STARTING_SUBVERSE = "frontpage"
    var subverseSubmissionParams = SubmissionsRequestParams(subverse: "frontpage", page: 0, sortType: .hot, topSortTypeTime: .week) {
        didSet {
            self.sortByButton.title = self.subverseSubmissionParams.sortType.rawValue
        }
    }
    
    private let NAVIGATION_BG_COLOR: UIColor = UIColor(colorLiteralRed: 95.0/255.0, green: 173.0/255.0, blue: 220.0/255.0, alpha: 1.0)
    private let BGCOLOR: UIColor = UIColor(colorLiteralRed: 161.0/255.0, green: 212.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    @IBOutlet var navigationBarCenterButton: SpringButton!
    @IBOutlet var navigationBarView: UIView!
    
    
    // Data Models and View Models
    private var subCellViewModels: [SubmissionCellViewModel] = []
    private var submissionDataModels: [SubmissionDataModelProtocol] = []
    
    // Segue
    private var selectedIndex: Int = 0
    private let SUBMISSION_SEGUE_IDENTIFIER = "SubmissionSegue"
    private let FIND_SUBVERSE_SEGUE_IDENTIFIER = "FindSubverseSegue"
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType!
    var dataManager: DataManagerProtocol?
    
    // Delegate
    weak var delegate: SubverseViewControllerDelegate?
    
    
    // UIOutlets and actions
    @IBAction func findSubverseButtonPress(_ sender: Any) {
        self.performSegue(withIdentifier: self.FIND_SUBVERSE_SEGUE_IDENTIFIER, sender: sender)
    }
    
    @IBAction func findSubverseNameButtonPress(_ sender: Any) {
        self.performSegue(withIdentifier: self.FIND_SUBVERSE_SEGUE_IDENTIFIER, sender: sender)
    }
    
    
    // Sort By
    @IBAction func pressedSortBy(_ sender: UIBarButtonItem) {
        // Create actionsheet and show
        
        // Create action sheet
        let alertController = UIAlertController.init(title: self.SORT_BY_TITLE, message: nil, preferredStyle: .actionSheet)
        
        // Create Actions corresponding to SortByComments enum choices
        var sortByActions = [UIAlertAction]()
        for sortByType in SortTypeSubmissions.allValues {
            let sortAction = UIAlertAction.init(title: sortByType.rawValue, style: .default, handler: { alertAction in
                
                // Set the view model
                self.subverseSubmissionParams.sortType = sortByType
                self.saveSortType(sortType: sortByType){}
                
                // Reload table
                self.loadTableCellsNew(forSubverse: self.subverseSubmissionParams.subverseName, clearScreen: true, animateNavBar: true) {
                }
                
            })
            
            sortByActions.append(sortAction)
        }
        
        // Cancel Button
        let cancelButton = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        // Populate alert controller with actions
        for sortByAction in sortByActions {
            alertController.addAction(sortByAction)
        }
        alertController.addAction(cancelButton)
        
        // Custom presentation for iPad
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let barButtonView: UIView = sender.value(forKey: "view") as! UIView
            alertController.popoverPresentationController?.sourceView = barButtonView
            alertController.popoverPresentationController?.sourceRect = barButtonView.bounds
        }
        
        // Present
        navigationController?.present(alertController, animated: true, completion: {
            
        })
    }
    
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = self.NAVIGATION_BG_COLOR
        self.tableView.backgroundColor = self.BGCOLOR
        
        self.loadPullToRefreshControl()
        self.loadActivityIndicator()
        
        self.loadSavedData()
        
        self.loadTableCellsNew(forSubverse: self.subverseSubmissionParams.subverseName, clearScreen: true, animateNavBar: true) {
            
        }

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadSavedData() {
        let verionDataModel = self.dataManager?.getSavedData()
        
        self.subverseSubmissionParams.subverseName = self.getLastSavedSubverse(fromVerionDataModel: verionDataModel!)
        self.subverseSubmissionParams.sortType = verionDataModel!.sortType!
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set bottom content Inset for possible ad-placement
        let topDefaultInset = self.tableView.contentInset.top
        self.tableView.contentInset = UIEdgeInsets(top: topDefaultInset, left: 0, bottom: self.BOTTOM_INSET_HEIGHT, right: 0)
    }
    
    func getLastSavedSubverse(fromVerionDataModel dataModel: VerionDataModel) -> String {
        
        // If a new model, should default to frontpage
        if dataModel.subversesVisited?.count == 0 {
            return self.DEFAULT_STARTING_SUBVERSE
        }
        
        return (dataModel.subversesVisited?[0])!
    }
    
    fileprivate func saveSortType(sortType: SortTypeSubmissions, completion: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            let verionDataModel = self.dataManager?.getSavedData()
            
            verionDataModel?.sortType = sortType
            
            self.dataManager?.saveData(dataModel: verionDataModel!)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func loadPullToRefreshControl() {
        
        self.customRefreshControl = UIStoryboard.init(name: "Subverse", bundle: Bundle.main).instantiateViewController(withIdentifier: "SubverseRefreshControl") as? SubverseRefreshControl
        
        _ = self.customRefreshControl?.view
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.clear
        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "", attributes: [NSForegroundColorAttributeName : UIColor.white])
        self.tableView.addSubview(self.customRefreshControl!.backgroundView)
        
        let height: CGFloat = (self.scrollViewContentOffsetY)
        
        self.customRefreshControl?.height = height
        self.customRefreshControl?.prepareFrameForShowing()
    }
    
    func loadActivityIndicator() {
        
        self.activityIndicator = ActivityIndicatorProvider.getActivityIndicator(type: .ballPulse, length: self.ACTIVITY_INDICATOR_LENGTH)
        
        self.activityIndicator?.center = self.navigationBarCenterButton.center
        
        self.navigationBarView.addSubview(self.activityIndicator!)
    }
    
    func showNavBarActivityIndicator() {
        self.activityIndicator?.startAnimating()
        
        self.navigationBarCenterButton.isHidden = true
    }
    
    func setNavigationBarCenterButtonName(string: String) {
        self.navigationBarCenterButton.setTitle(string, for: .normal)
        self.navigationBarCenterButton.setTitle(string, for: .selected)
        self.navigationBarCenterButton.setTitle(string, for: .disabled)
    }
    
    func hideNavBarActivityIndicator() {
        self.activityIndicator?.stopAnimating()
        
        self.navigationBarCenterButton.isHidden = false
        self.navigationBarCenterButton.animation = "fadeIn"
        self.navigationBarCenterButton.animate()
    }
    
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -(self.scrollViewContentOffsetY + self.REFRESH_CONTROL_PULL_DISTANCE) {
            
            // Refresh control activated
            self.refreshControl?.beginRefreshing()
            self.customRefreshControl?.isRefreshing = true
            self.customRefreshControl?.showActivityIndicator()
            //refresh logic
            
            // Pull to refresh
            self.loadTableCellsNew(forSubverse: self.subverseSubmissionParams.subverseName, clearScreen: false, animateNavBar: false){
                self.refreshControl?.endRefreshing()
                self.customRefreshControl?.isRefreshing = false
                self.customRefreshControl?.hideActivityIndicator()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.customRefreshControl?.isRefreshing == false else {
            return
        }
        
        if scrollView.contentOffset.y <= -(self.scrollViewContentOffsetY + self.REFRESH_CONTROL_PULL_DISTANCE) {
            if self.customRefreshControl?.label.text != self.RELEASE_TO_REFRESH_STRING {
                self.customRefreshControl?.label.text = self.RELEASE_TO_REFRESH_STRING
            }
            
        }
        else {
            
            if self.customRefreshControl?.label.text != self.PULL_TO_REFRESH_STRING{
                self.customRefreshControl?.label.text = self.PULL_TO_REFRESH_STRING
            }
        }
    }
    
    // public function to call loading from outside of VC
    func loadTableCellsNew(forSubverse subverseString: String, clearScreen: Bool, animateNavBar: Bool, completion: @escaping ()->()) {
        // Clear current submissions
        self.cleanupModels()
        
        if clearScreen {
            self.tableView.reloadData()
        }
        
        // Set the subverse name
        self.subverseSubmissionParams.subverseName = subverseString
        self.subverseSubmissionParams.page = 0
        
        // Animate the nav bar
        if animateNavBar {
            self.showNavBarActivityIndicator()
        }
        
        // Load cells
        self.loadTableCellsAddedToCurrent(withParams: self.subverseSubmissionParams) {
            if animateNavBar {
                self.hideNavBarActivityIndicator()
            }
            
            self.reloadTableAnimated(forTableView: self.tableView, startingIndexInclusive: 0, endingIndexExclusive: self.subCellViewModels.count+self.LOADMORE_CELL_INDEX_VALUE, animation: .fade)
            
            completion()
        }
    }
    
    private func loadTableCellsAddedToCurrent(withParams params: SubmissionsRequestParams, completion: @escaping ()->()) {
        
        guard self.isLoadingRequest != true else {
            return
        }
        
        self.isLoadingRequest = true
        
        // Notify delegate
        if let _ = self.delegate?.subverseViewController(controller: self, willLoadSubverse: self.subverseSubmissionParams.subverseName) {
            // Success, do nothing
        } else {
            #if DEBUG
                print ("Warning: SubverseViewController's delegate may not be set.")
            #endif
        }
        
        
        // Make initial request with DataProvider
        let submissionParams = self.subverseSubmissionParams
        self.dataProvider.requestSubverseSubmissions(submissionParams: submissionParams) { submissionDataModels, error in
            
            // Perform Data-binding in background thread
            // (Includes Initialization of ImageViews in viewModels)
            DispatchQueue.global(qos: .background).async {
                
                // Set the new starting view model index before we add new ones
                let newStartingVmIndex = self.subCellViewModels.count
                var dataModelsToAppend: [SubmissionDataModelProtocol] = []
                
                // For each data model, initialize a subCell viewModel
                for i in 0..<submissionDataModels.count {
                    var isDuplicate = false
                    
                    let subCellViewModel = SubmissionCellViewModel()
                    subCellViewModel.dataModel = submissionDataModels[i]
                    
                    // Check for duplicates
                    for j in 0..<self.submissionDataModels.count {
                        if submissionDataModels[i].id == self.submissionDataModels[j].id {
                            // A duplicate is found, flag it
                            isDuplicate = true
                            break
                        }
                    }
                    
                    // Combine if no duplicates
                    if isDuplicate == false {
                        self.subCellViewModels.append(subCellViewModel)
                        dataModelsToAppend.append(submissionDataModels[i])
                    }
                    
                }
                
                // Add to data source
                self.submissionDataModels.append(contentsOf: dataModelsToAppend)
                
                
                // Bind set of cells to be loaded
                self.bindCellsToBeDisplayed(startingIndexInclusive: newStartingVmIndex, endingIndexExclusive: self.subCellViewModels.count)
                
                
                // Reload table, animated, back on main thread
                DispatchQueue.main.async {
                    
                    // Set Navigation title after finished loading table
                    let subverseTitle = self.getNavigationLabelString(subverse: self.subverseSubmissionParams.subverseName)
                    self.setNavigationBarCenterButtonName(string: subverseTitle)
                    
                    completion()
                    
                    self.isLoadingRequest = false
                }
            }
            
        }
    }
    
    private func loadMoreTableCells(completion: @escaping ()->()) {
        // Increment page number and Make call to Data provider
        self.subverseSubmissionParams.page += 1
        
        // The starting index before the refresh is the last item
        let startingIndex = self.subCellViewModels.count
        
        self.loadTableCellsAddedToCurrent(withParams: self.subverseSubmissionParams) {
            self.insertSectionsAnimated(forTableView: self.tableView, startingIndexInclusive: startingIndex, endingIndexExclusive: self.subCellViewModels.count-1 + self.LOADMORE_CELL_INDEX_VALUE, animation: .fade)
            
            // If Reached the max pages that the api will return
            if self.subverseSubmissionParams.page == self.MAX_NUMBER_OF_PAGES {
                // Don't show the Load More Cell
                self.LOADMORE_CELL_INDEX_VALUE = 0
                self.tableView.reloadData()
            }
        }
        
        self.reloadTableAnimated(forTableView: self.tableView, startingIndexInclusive: self.submissionDataModels.count-1 + self.LOADMORE_CELL_INDEX_VALUE, endingIndexExclusive: self.submissionDataModels.count + self.LOADMORE_CELL_INDEX_VALUE, animation: .fade)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.subCellViewModels.count == 0 {
            return 0
        }
        
        return self.subCellViewModels.count + self.LOADMORE_CELL_INDEX_VALUE
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    // Create the Submission Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // On first load, do not display any cells until table is finished loading
        guard (indexPath.section > self.submissionDataModels.count-1 + self.LOADMORE_CELL_INDEX_VALUE) == false else {
            let transparentCell = tableView.dequeueReusableCell(withIdentifier: "TransparentCell")!
            
            // Return a blank cell
            return transparentCell
        }
        
        // If is last cell, return an Activity Indicator cell, start the animation
        if self.isLastCell(forIndexPath: indexPath, inLoadedViewModels: self.subCellViewModels) {
            
            // If not loading, show load more cells
            if self.isLoadingRequest == false {
                let loadMoreCell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell")
                
                return loadMoreCell!
            } else {
                // If loading, show activity indicator
                let activityIndicatorCell = self.getActivityIndicatorCell(forIndexPath: indexPath, startAnimation: true)
                
                return activityIndicatorCell
            }
        }
        
        // Regular submission cell loading
        let cell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_CELL_REUSE_ID, for: indexPath) as! SubmissionCell
        
        // Create cell if viewModel exists
        let viewModel = self.subCellViewModels[indexPath.section] as SubmissionCellViewModel
        cell.bind(toViewModel: viewModel)
        
        
        // Create Thumbnail in ViewModel and Attach in Background Queue
        DispatchQueue.global(qos: .background).async {
            viewModel.createThumbnailImage()
            
            DispatchQueue.main.async {
                cell.bindThumbnailImage()
            }
        }
        
        return cell
    }
    
    // Spacing between cells
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // No header for first cell
        if section == 0 {
            return 0
        }
        
        return self.CELL_SPACING
    }
    
    // Background
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat = self.DEFAULT_ROW_HEIGHT
        
        // If Last element, return the LoadMore cell height
        guard self.isLastCell(forIndexPath: indexPath, inLoadedViewModels: self.subCellViewModels) == false else {
            cellHeight = self.LOAD_MORE_CELL_HEIGHT
            return cellHeight
        }
        
        if self.subCellViewModels.count > 0 {
            // Get corresponding viewModel
            let viewModel = self.subCellViewModels[indexPath.section] as SubmissionCellViewModel
            cellHeight = viewModel.cellHeight
        }
        
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard self.isLoadingRequest != true else {
            return
        }
        
        // If the Load More Cells should->did load, then allow the touch of last cell to load more
        if self.isLastCell(forIndexPath: indexPath, inLoadedViewModels: self.subCellViewModels) {
            
            self.loadMoreTableCells() {
                
            }
            
        }
        else {
            // Will transition to segue, remember the index
            self.selectedIndex = indexPath.section
            
            self.performSegue(withIdentifier: self.SUBMISSION_SEGUE_IDENTIFIER, sender: self)
        }
    }
    
 
    // For detecting rotations beginning and finishing.
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
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
            self.customRefreshControl?.prepareFrameForShowing()
        })
    }
    
    private func shouldLoadMoreCells(forIndexPath indexPath: IndexPath, inLoadedViewModels viewModels: [SubmissionCellViewModel]) -> Bool {
        let shouldLoad = false
        
        
        return shouldLoad
    }
    
    private func indexPathIsLastSectionOfCurrentDisplayed(indexPath: IndexPath, numOfCellsCurrentlyDisplaying: Int) -> Bool{
        let isLastSection: Bool = (indexPath.section == (numOfCellsCurrentlyDisplaying-1))
        
        return isLastSection
    }
    
    private func indexPathIsLastSectionOfMaximum(indexPath: IndexPath, maxNumberOfCells: Int) -> Bool{
        let isLastSection: Bool = (indexPath.section == (maxNumberOfCells-1))
        
        return isLastSection
    }
    
    private func bindCellsToBeDisplayed(startingIndexInclusive: Int, endingIndexExclusive: Int) {
        
        // For each cell
        for i in startingIndexInclusive..<endingIndexExclusive {
            // Bind dataModel-viewModel-dataProvider
            
            let subCellViewModel = self.subCellViewModels[i]
            let dataModel = subCellViewModel.dataModel
            
            self.dataProvider.bind(subCellViewModel: subCellViewModel, dataModel: dataModel!)
            #if DEBUG
                //print("Binding cell to viewModel \(i)...")
            #endif
        }
    }
    
    private func isLastCell(forIndexPath indexPath: IndexPath, inLoadedViewModels loadedViewModels: [SubmissionCellViewModel]) -> Bool {
        
        // If we reached max pages, don't return true to show last page
        guard self.LOADMORE_CELL_INDEX_VALUE != 0 else {
            return false
        }
        
        var isLastCell = false
        
        if indexPath.section == loadedViewModels.count-1 + self.LOADMORE_CELL_INDEX_VALUE {
            isLastCell = true
        }
        
        return isLastCell
    }
    
    private func getActivityIndicatorCell(forIndexPath indexPath: IndexPath, startAnimation: Bool) -> ActivityIndicatorCell {
        
        // Activity Indicator for a 'Loading' cell
        if self.activityIndicatorCell != nil {
            self.activityIndicatorCell?.removeActivityIndicator()
        }
        
        self.activityIndicatorCell = tableView.dequeueReusableCell(withIdentifier: self.ACTIVITY_INDICATOR_CELL_REUSE_ID, for: indexPath) as? ActivityIndicatorCell
        self.activityIndicatorCell?.loadActivityIndicator(length: self.ACTIVITY_INDICATOR_LENGTH)
        self.activityIndicatorCell?.activityIndicator?.color = self.NAVIGATION_BG_COLOR
        
        if startAnimation {
            self.activityIndicatorCell?.showActivityIndicator()
        }
        
        return self.activityIndicatorCell!
    }
    
    
    private func insertSectionsAnimated(forTableView tableView: UITableView, startingIndexInclusive: Int, endingIndexExclusive: Int, animation: UITableViewRowAnimation) {

        tableView.beginUpdates()
        let range = Range.init(uncheckedBounds: (lower: startingIndexInclusive, upper: endingIndexExclusive))
        let indexSet = IndexSet.init(integersIn: range)
        tableView.insertSections(indexSet, with: animation)
        tableView.endUpdates()
    }
    
    private func reloadTableAnimated(lastCellIndex: Int) {
        self.reloadTableAnimated(forTableView: self.tableView,
                                 startingIndexInclusive: 0,
                                 endingIndexExclusive: lastCellIndex,
                                 animation: UITableViewRowAnimation.automatic)
    }
 
    private func reloadTableAnimated(forTableView tableView: UITableView, startingIndexInclusive: Int, endingIndexExclusive:
        Int, animation: UITableViewRowAnimation) {
        
            tableView.reloadData()
            let range = Range.init(uncheckedBounds: (lower: startingIndexInclusive, upper: endingIndexExclusive))
            let indexSet = IndexSet.init(integersIn: range)
            tableView.reloadSections(indexSet, with: animation)
        
    }
    
    func getNavigationLabelString(subverse: String) -> String{
        let subverseTitle: String
        
        subverseTitle = subverse
        
        return subverseTitle
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.SUBMISSION_SEGUE_IDENTIFIER {
            
            // Comments View Controller segue
            if let commentsViewController = segue.destination as? CommentsViewController {
                commentsViewController.submissionDataModel = self.subCellViewModels[self.selectedIndex].dataModel
                commentsViewController.backgroundColor = self.BGCOLOR
                
            }
            
        } else if segue.identifier == self.FIND_SUBVERSE_SEGUE_IDENTIFIER {
            
            
            // Find Subverse View Controller segue
            
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Forces redraw of shadows right before transition
        self.tableView.reloadData()
    }
    
    private func cleanupModels() {
        self.subCellViewModels.removeAll()
        self.submissionDataModels.removeAll()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

