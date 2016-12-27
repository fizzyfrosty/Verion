//
//  FindSubverseViewController.swift
//  Verion
//
//  Created by Simon Chen on 12/17/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class FindSubverseViewController: UITableViewController {
    
    let searchController = UISearchController.init(searchResultsController: nil)
    let PLACEHOLDER_TEXT = "Find Subverse"
    
    let SUBVERSE_SEARCH_RESULT_CELL_REUSE_ID = "SubverseSearchResultCell"
    
    var filteredSubverseSearchResultViewModels: [SubverseSearchResultCellViewModel] = []
    var allSubverseSearchResultViewModels: [SubverseSearchResultCellViewModel] = []
    private var didSearchResultsLoad = false
    
    
    // Dependencies
    var dataProvider: DataProviderType?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.searchController.searchBar.placeholder = self.PLACEHOLDER_TEXT
        

        // Set up search bar
        self.setupSearchController()
        
        // Request for all subverses
        self.dataProvider?.requestSubverseList() { subverseSearchResultsDataModels, error in
            
            DispatchQueue.global(qos: .background).async {
                
                // Clear
                self.allSubverseSearchResultViewModels.removeAll()
                self.filteredSubverseSearchResultViewModels.removeAll()
                
                // prepend all/frontpage subverses first
                self.allSubverseSearchResultViewModels.append(self.getAllSubverse())
                self.allSubverseSearchResultViewModels.append(self.getFrontpageSubverse())
                
                // Bind viewmodels to data models
                for dataModel in subverseSearchResultsDataModels {
                    let subverseSearchResultCellVm = SubverseSearchResultCellViewModel()
                    
                    self.dataProvider?.bind(subverseSearchResultCellViewModel: subverseSearchResultCellVm, dataModel: dataModel)
                    
                    self.allSubverseSearchResultViewModels.append(subverseSearchResultCellVm)
                }
                
                // Start with full list of subverses
                self.filteredSubverseSearchResultViewModels = self.allSubverseSearchResultViewModels
                
                self.didSearchResultsLoad = true
                
                DispatchQueue.main.async {
                    self.reloadTableAnimated()
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Not used, because something wrong with legacy api
    func getAllSubverse() -> SubverseSearchResultCellViewModel {
        var initData = SubverseSearchResultCellViewModelInitData()
        initData.subverseString = "all"
        
        let subverse = SubverseSearchResultCellViewModel()
        subverse.loadInitData(initData: initData)
        
        return subverse
    }
    
    func getFrontpageSubverse() -> SubverseSearchResultCellViewModel {
        var initData = SubverseSearchResultCellViewModelInitData()
        initData.subverseString = "frontpage"
        
        let subverse = SubverseSearchResultCellViewModel()
        subverse.loadInitData(initData: initData)
        
        return subverse
    }
    
    func reloadTableAnimated() {
        self.tableView.reloadData()
    }
    
    func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true // "By setting definesPresentationContext on your view controller to true, you ensure that the search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active."
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.searchController.searchBar.delegate = self
        self.searchController.delegate = self
        self.searchController.isActive = true
        
        self.searchController.searchBar.autocapitalizationType = .none
        self.searchController.searchBar.autocorrectionType = .no
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.didSearchResultsLoad != false else {
            return 0
        }
        
        return self.filteredSubverseSearchResultViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.didSearchResultsLoad != false else {
            return 0
        }
        
        let subverseSearchResultCellVm = self.filteredSubverseSearchResultViewModels[indexPath.row]
        
        return subverseSearchResultCellVm.cellHeight
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let subverseSearchResultCell = tableView.dequeueReusableCell(withIdentifier: self.SUBVERSE_SEARCH_RESULT_CELL_REUSE_ID, for: indexPath) as! SubverseSearchResultCell
        
        let subverseSearchResultCellVm = self.filteredSubverseSearchResultViewModels[indexPath.row]
        
        subverseSearchResultCell.bind(toViewModel: subverseSearchResultCellVm)
        
        return subverseSearchResultCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResult = self.filteredSubverseSearchResultViewModels[indexPath.row]
        self.loadSubverseViewController(forSubverse: searchResult.subverseString)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func filterSubverseList(forText searchText: String) {
        
        // When search bar is empty, do not filter
        guard searchText != "" else {
            self.filteredSubverseSearchResultViewModels = self.allSubverseSearchResultViewModels
            self.reloadTableAnimated()
            return
        }
        
        self.filteredSubverseSearchResultViewModels = self.allSubverseSearchResultViewModels.filter() { viewModel in
            let searchTextLowerCased = searchText.lowercased()
            if viewModel.subverseString.lowercased().contains(searchTextLowerCased) ||
                viewModel.subverseDescription.lowercased().contains(searchTextLowerCased) {
                return true
            }
            return false
        }
        
        // If no search results (since we are displaying only top 200), load a cell with the name that's searched
        if self.filteredSubverseSearchResultViewModels.count == 0 {
            var initData = SubverseSearchResultCellViewModelInitData()
            initData.subverseString = searchText
            let customSearchResult = SubverseSearchResultCellViewModel()
            customSearchResult.loadInitData(initData: initData)
            
            self.filteredSubverseSearchResultViewModels.append(customSearchResult)
        }
        
        self.reloadTableAnimated()
    }
    
    func loadSubverseViewController(forSubverse subverse: String) {
        // Begin reloading the subverse submissions in the Subverse VC
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            
            // Get the VC
            let subverseViewController = navController.viewControllers[navController.viewControllers.count - 2] as! SubverseViewController
            subverseViewController.loadTableCellsNew(forSubverse: subverse, clearScreen: true, animateNavBar: true) {
                
            }
            
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    deinit {
        #if DEBUG
            print ("Deallocated Find Subverse View Controller")
        #endif
    }
}

extension FindSubverseViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension FindSubverseViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // update filter code here
        self.filterSubverseList(forText: searchController.searchBar.text!)
    }
}

extension FindSubverseViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.loadSubverseViewController(forSubverse: searchBar.text!)
    }
}



