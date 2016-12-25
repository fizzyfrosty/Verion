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
    let SUBMISSION_CELL_REUSE_ID = "SubmissionCell"
    private let CELL_SPACING: CGFloat = 0.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private var numOfCellsToDisplay = 0
    
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
    
    // Sorting
    private let SORT_BY_TITLE = "Sort Submissions by"
    private var sortType: SortTypeSubmissions = .hot

    @IBOutlet var sortByButton: UIBarButtonItem!
    
    
    // Navigation Bar items
    @IBOutlet var menuButton: UIBarButtonItem!
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    var activityIndicator: NVActivityIndicatorView?
    
    var subverse = "frontpage"
    
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
    
    
    @IBAction func pressedSortBy(_ sender: UIBarButtonItem) {
        // Create actionsheet and show
        
        // Create action sheet
        let alertController = UIAlertController.init(title: self.SORT_BY_TITLE, message: nil, preferredStyle: .actionSheet)
        
        // Create Actions corresponding to SortByComments enum choices
        var sortByActions = [UIAlertAction]()
        for sortByType in SortTypeSubmissions.allValues {
            let sortAction = UIAlertAction.init(title: sortByType.rawValue, style: .default, handler: { alertAction in
                
                // Set the view model
                self.sortType = sortByType
                
                self.sortSubmissions(bySortType: self.sortType)
                
                // Send to top
                self.tableView.setContentOffset(CGPoint(x: 0.0, y: -self.tableView.contentInset.top), animated: true)
                
                // Reload table
                self.reloadTableAnimated(lastCellIndex: self.numOfCellsToDisplay)
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
        
        let savedSubverse = self.getLastSavedSubverse()
        
        self.loadTableCells(forSubverse: savedSubverse)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getLastSavedSubverse() -> String {
        let verionDataModel = self.dataManager?.getSavedData()
        
        // If a new model, should default to frontpage
        if verionDataModel?.subversesVisited.count == 0 {
            return self.subverse
        }
        
        return (verionDataModel?.subversesVisited[0])!
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
            
            
            self.loadTableCells() {
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
    func loadTableCells(forSubverse subverseString: String) {
        // Clear subverse
        self.cleanupModels()
        
        self.numOfCellsToDisplay = min(self.NUM_OF_STARTING_CELLS_TO_DISPLAY, self.submissionDataModels.count)
        self.reloadTableAnimated(lastCellIndex: self.numOfCellsToDisplay)
        
        self.subverse = subverseString
        self.showNavBarActivityIndicator()
        
        
        self.loadTableCells {
            self.hideNavBarActivityIndicator()
        }
    }
    
    private func loadTableCells(completion: @escaping ()->()) {
        
        guard self.isLoadingRequest != true else {
            return
        }
        
        self.isLoadingRequest = true
        
        
        // Notify delegate
        if let _ = self.delegate?.subverseViewController(controller: self, willLoadSubverse: self.subverse) {
            // Success, do nothing
        } else {
            #if DEBUG
                print ("Warning: SubverseViewController's delegate may not be set.")
            #endif
        }
        
        
        // Make initial request with DataProvider
        self.dataProvider.requestSubverseSubmissions(subverse: self.subverse) { submissionDataModels, error in
            
            // Perform Data-binding in background thread
            // (Includes Initialization of ImageViews in viewModels)
            DispatchQueue.global(qos: .background).async {
                
                // Clear all current data
                self.cleanupModels()
                
                // For each data model, initialize a subCell viewModel
                for i in 0..<submissionDataModels.count {
                    let subCellViewModel = SubmissionCellViewModel()
                    subCellViewModel.dataModel = submissionDataModels[i]
                    
                    self.subCellViewModels.append(subCellViewModel)
                }
                self.submissionDataModels = submissionDataModels
                
                
                // Bind set of cells to be loaded
                self.bindCellsToBeDisplayed(startingIndexInclusive: 0, endingIndexExclusive: self.subCellViewModels.count)
                
                self.sortSubmissions(bySortType: self.sortType)
                
                self.numOfCellsToDisplay = min(self.NUM_OF_STARTING_CELLS_TO_DISPLAY, self.submissionDataModels.count)
                
                // Reload table, animated, back on main thread
                DispatchQueue.main.async {
                    
                    self.isLoadingRequest = false
                    self.reloadTableAnimated(lastCellIndex: self.numOfCellsToDisplay)
                    
                    // Set Navigation title after finished loading table
                    let subverseTitle = self.getNavigationLabelString(subverse: self.subverse)
                    self.setNavigationBarCenterButtonName(string: subverseTitle)
                    
                    completion()
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard self.subCellViewModels.count >= self.numOfCellsToDisplay else {
            return 0
        }
        
        return self.numOfCellsToDisplay
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    // Create the Submission Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // On first load, do not display any cells until table is finished loading
        guard self.isLoadingRequest != true else {
            let transparentCell = tableView.dequeueReusableCell(withIdentifier: "TransparentCell")!
            
            // Return a blank cell
            return transparentCell
        }
        
        // "Load More" cell
        guard  !self.shouldLoadLoadMoreCell(indexPath: indexPath, numOfCellsCurrentlyDisplaying: self.numOfCellsToDisplay, numOfMaxCells: self.subCellViewModels.count) else {
            let loadMoreCell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell")
            
            return loadMoreCell!
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
        var cellHeight: CGFloat = 0
        
        // If Last element, return the LoadMore cell height
        guard !self.shouldLoadLoadMoreCell(indexPath: indexPath, numOfCellsCurrentlyDisplaying: self.numOfCellsToDisplay, numOfMaxCells: self.subCellViewModels.count) else {
            return self.LOAD_MORE_CELL_HEIGHT
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
        if self.shouldLoadLoadMoreCell(indexPath: indexPath, numOfCellsCurrentlyDisplaying: self.numOfCellsToDisplay, numOfMaxCells: self.subCellViewModels.count) {
            self.increaseAmountOfTableCellsAndReload(increaseBy: self.NUM_OF_CELLS_TO_INCREMENT_BY,
                                                  maxLimit: self.subCellViewModels.count)
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
    
    private func shouldLoadLoadMoreCell(indexPath: IndexPath, numOfCellsCurrentlyDisplaying: Int, numOfMaxCells: Int) -> Bool {
        let shouldLoad: Bool = !self.indexPathIsLastSectionOfMaximum(indexPath: indexPath, maxNumberOfCells: numOfMaxCells) && self.indexPathIsLastSectionOfCurrentDisplayed(indexPath: indexPath, numOfCellsCurrentlyDisplaying: self.numOfCellsToDisplay)
        
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
    
    private func insertSectionsAnimated(forTableView tableView: UITableView, startingIndexInclusive: Int, endingIndexExclusive: Int, animation: UITableViewRowAnimation) {

        tableView.beginUpdates()
        let range = Range.init(uncheckedBounds: (lower: startingIndexInclusive, upper: endingIndexExclusive))
        let indexSet = IndexSet.init(integersIn: range)
        tableView.insertSections(indexSet, with: .automatic)
        tableView.endUpdates()
        
        
        
        // Refresh the cell that said "Load More Submissions"
        tableView.beginUpdates()
        let refreshRange = Range.init(uncheckedBounds: (lower: startingIndexInclusive-1, upper: startingIndexInclusive))
        let refreshIndexSet = IndexSet.init(integersIn: refreshRange)
        tableView.reloadSections(refreshIndexSet, with: .automatic)
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
    
    func increaseAmountOfTableCellsAndReload(increaseBy numToIncrease: Int, maxLimit: Int) {
        // Load more
        var numOfCellsToIncreaseBy = 0
        
        if (self.numOfCellsToDisplay + numToIncrease) > maxLimit {
            
            numOfCellsToIncreaseBy = maxLimit - self.numOfCellsToDisplay
            
        } else {
            numOfCellsToIncreaseBy = numToIncrease
        }
        
        let startingIndex = self.numOfCellsToDisplay
        
        // This is what is necessary to increase table cells
        self.numOfCellsToDisplay += numOfCellsToIncreaseBy
        
        self.insertSectionsAnimated(forTableView: self.tableView,
                                    startingIndexInclusive: startingIndex,
                                    endingIndexExclusive: self.numOfCellsToDisplay,
                                    animation: .automatic)
        
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
    
    private func sortSubmissions(bySortType sortType: SortTypeSubmissions) {
        // Sort it all
        switch sortType {
        case .hot:
            self.subCellViewModels.sort(by: { (viewModelA, viewModelB) -> Bool in
                return viewModelA.rank > viewModelB.rank
            })
        case .new:
            self.subCellViewModels.sort(by: { (viewModelA, viewModelB) -> Bool in
                return viewModelA.date?.compare(viewModelB.date!) == ComparisonResult.orderedDescending
            })
        case .top:
            self.subCellViewModels.sort(by: { (viewModelA, viewModelB) -> Bool in
                return viewModelA.voteCountTotal.value > viewModelB.voteCountTotal.value
            })
        }
        self.sortByButton.title = sortType.rawValue
        
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

