//
//  SubverseViewController.swift
//  Verion
//
//  Created by Simon Chen on 11/29/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SubverseViewController: UITableViewController, NVActivityIndicatorViewable {
    
    // Cell configuration
    let SUBMISSION_CELL_REUSE_ID = "SubmissionCell"
    private let CELL_SPACING: CGFloat = 10.0
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
    
    
    // Navigation Bar items
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    var activityIndicator: NVActivityIndicatorView?
    
    var subverse = "frontpage"
    
    private let BGCOLOR: UIColor = UIColor(colorLiteralRed: 0.8, green: 0.4, blue: 0.4, alpha: 1.0)
    @IBOutlet var navigationBarLabel: SpringLabel!
    @IBOutlet var navigationBarView: UIView!
    
    
    // Data Models and View Models
    private var subCellViewModels: [SubmissionCellViewModel] = []
    private var submissionDataModels: [SubmissionDataModelProtocol] = []
    var didTableLoadOnce = false // prevents table from rendering before cells completely bounded
    
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = self.BGCOLOR
        self.navigationController?.navigationBar.barTintColor = self.BGCOLOR
        
        self.numOfCellsToDisplay = self.NUM_OF_STARTING_CELLS_TO_DISPLAY
        self.loadPullToRefreshControl()
        self.loadActivityIndicator()
        self.showNavBarActivityIndicator()
        
        self.loadTableCells(dataProvider: self.dataProvider) {
            self.hideNavBarActivityIndicator()
        }

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        
        let activityIndicatorFrame = CGRect(x: 0,
                                            y: 0,
                                            width: self.ACTIVITY_INDICATOR_LENGTH,
                                            height: self.ACTIVITY_INDICATOR_LENGTH)
        
        self.activityIndicator = NVActivityIndicatorView.init(frame: activityIndicatorFrame,
                                                              type: NVActivityIndicatorType.ballPulse,
                                                              color: UIColor.white,
                                                              padding: 0)
        
        self.activityIndicator?.center = self.navigationBarLabel.center
        
        self.navigationBarView.addSubview(self.activityIndicator!)
    }
    
    func showNavBarActivityIndicator() {
        self.activityIndicator?.startAnimating()
        
        self.navigationBarLabel.isHidden = true
    }
    
    func hideNavBarActivityIndicator() {
        self.activityIndicator?.stopAnimating()
        
        self.navigationBarLabel.isHidden = false
        self.navigationBarLabel.animation = "fadeIn"
        self.navigationBarLabel.animate()
    }
    
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -(self.scrollViewContentOffsetY + self.REFRESH_CONTROL_PULL_DISTANCE) {
            
            // Refresh control activated
            self.refreshControl?.beginRefreshing()
            self.customRefreshControl?.isRefreshing = true
            self.customRefreshControl?.showActivityIndicator()
            //refresh logic
            
            
            self.loadTableCells(dataProvider: self.dataProvider) {
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
    
    func loadTableCells(dataProvider: DataProviderType, completion: @escaping ()->()) {
        
        // Make initial request with DataProvider
        dataProvider.requestSubverseSubmissions(subverse: self.subverse) { submissionDataModels, error in
            
            // Perform Data-binding in background thread
            // (Includes Initialization of ImageViews in viewModels)
            DispatchQueue.global(qos: .background).async {
                
                // Clear all current data
                self.subCellViewModels.removeAll()
                
                // For each data model, initialize a subCell viewModel
                for _ in 0..<submissionDataModels.count {
                    let subCellViewModel = SubmissionCellViewModel()
                    self.subCellViewModels.append(subCellViewModel)
                }
                
                self.submissionDataModels = submissionDataModels
                
                // Bind set of cells to be loaded
                self.bindCellsToBeDisplayed(startingIndexInclusive: 0, endingIndexExclusive: self.subCellViewModels.count)
                
                // Reload table, animated, back on main thread
                DispatchQueue.main.async {
                    self.didTableLoadOnce = true
                    
                    self.reloadTableAnimated(forTableView: self.tableView,
                                             startingIndexInclusive: 0,
                                             endingIndexExclusive: self.numOfCellsToDisplay,
                                             animation: UITableViewRowAnimation.automatic)
                    
                    // Set Navigation title after finished loading table
                    self.navigationBarLabel.text = self.getNavigationLabelString(subverse: self.subverse)
                    
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
        // Table can be partially loaded with viewModels while still binding to cells
        guard self.didTableLoadOnce == true else {
            let transparentCell = tableView.dequeueReusableCell(withIdentifier: "TransparentCell")!
            
            // Return an invisible cell
            return transparentCell
        }
        
        // "Load More" cell
        guard  !self.shouldLoadLoadMoreCell(indexPath: indexPath, numOfCellsCurrentlyDisplaying: self.numOfCellsToDisplay, numOfMaxCells: self.subCellViewModels.count) else {
            let loadMoreCell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell")
            
            return loadMoreCell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_CELL_REUSE_ID, for: indexPath) as! SubmissionCell
        
        // Create cell if viewModel exists
        let viewModel = self.subCellViewModels[indexPath.section] as SubmissionCellViewModel
        cell.bind(toViewModel: viewModel)
        self.sfxManager?.applyShadow(view: cell)
        
        
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
        
        // If the Load More Cells should->did load, then allow the touch of last cell to load more
        if self.shouldLoadLoadMoreCell(indexPath: indexPath, numOfCellsCurrentlyDisplaying: self.numOfCellsToDisplay, numOfMaxCells: self.subCellViewModels.count) {
            self.increaseAmountOfTableCellsAndReload(increaseBy: self.NUM_OF_CELLS_TO_INCREMENT_BY,
                                                  maxLimit: self.subCellViewModels.count)
            
            /*
            self.tableView.beginUpdates()
            self.numOfCellsToDisplay += 2
            let range = Range.init(uncheckedBounds: (lower: self.numOfCellsToDisplay-2, upper: self.numOfCellsToDisplay))
            let indexSet = IndexSet.init(integersIn: range)
            self.tableView.insertSections(indexSet, with: .automatic)
            self.tableView.endUpdates()
 
            
            
            self.tableView.beginUpdates()
            let range2 = Range.init(uncheckedBounds: (lower: self.numOfCellsToDisplay-3, upper: self.numOfCellsToDisplay))
            let indexSet2 = IndexSet.init(integersIn: range2)
            self.tableView.reloadSections(indexSet2, with: .automatic)
            self.tableView.endUpdates()
            */
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
            let dataModel = self.submissionDataModels[i]
            
            self.dataProvider.bind(subCellViewModel: subCellViewModel, dataModel: dataModel)
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
 
    private func reloadTableAnimated(forTableView tableView: UITableView, startingIndexInclusive: Int, endingIndexExclusive:
        Int, animation: UITableViewRowAnimation) {
        
        tableView.reloadData()
        let range = Range.init(uncheckedBounds: (lower: startingIndexInclusive, upper: endingIndexExclusive))
        let indexSet = IndexSet.init(integersIn: range)
        tableView.reloadSections(indexSet, with: animation)
    }
    
    func getNavigationLabelString(subverse: String) -> String{
        let subverseTitle: String
        
        if subverse == "frontpage" {
            subverseTitle = subverse
        } else {
            subverseTitle = "/v/" + subverse
        }
        
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
    
    func reloadDataAnimatedKeepingOffset()
    {
        let offset = self.tableView.contentOffset
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        self.tableView.contentOffset = offset
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Forces redraw of shadows right before transition
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
        // Ensure we hit bottom of table
        guard indexPath.section >= (self.numOfCellsToDisplay - 1) else {
            
            return
        }
        
        // Ensure we didn't reach the max number of cells
        guard self.numOfCellsToDisplay != self.subCellViewModels.count else {
            return
        }
        */
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



// Mark: - Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
    class func setup() {
        let defaultContainer = SwinjectStoryboard.defaultContainer
        
        defaultContainer.register(SFXManagerType.self, factory: { _ in
            SFXManager()
        })
        
        defaultContainer.register(DataProviderType.self){ _ in
            OfflineDataProvider(apiVersion: .legacy)
        }
        
        defaultContainer.registerForStoryboard(SubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = ResolverType.resolve(SFXManagerType.self)!
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
        })
    }
}
