//
//  LeftMenuController.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol LeftMenuControllerDelegate: class {
    func leftMenuDidSelectSubverse(leftMenu: LeftMenuController, subverseName: String)
    func leftMenuDidClearHistory(leftMenu: LeftMenuController)
    func leftMenuDidPurchaseProduct(leftMenu: LeftMenuController, productId: String)
}

class LeftMenuController: UITableViewController {
    
    enum LeftMenuSections: Int {
        case subverseHistory = 0
        case supportUs = 1
        
        static let allValues = [subverseHistory, supportUs]
    }
    
    // Table Elements
    private let SUBVERSE_CELL_REUSE_ID = "SubverseCell"
    private let CLEAR_HISTORY_CELL_REUSE_ID = "ClearHistoryCell"
    private let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    private let SECTION_HEIGHT: CGFloat = 30.0
    private let activtyIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    // Subverse history section
    fileprivate var subverseCellViewModels = [SubverseCellViewModel]()
    private let clearHistoryCellCount: Int = 1
    fileprivate let MAX_NUM_HISTORY_ENTRIES: Int = 20
    
    // Support us section
    enum SupportUsRows: Int {
        case removeAds = 0
        case donate = 1
        
        static let allValues = [removeAds]
    }
    private let REMOVE_ADS_CELL_REUSE_ID = "RemoveAdsCell"
    private let DONATE_CELL_REUSE_ID = "DonateCell"
    
    private let SUBVERSE_HISTORY_SECTION_TITLE = "    Subverses Visited"
    private let SUPPORT_US_SECTION_TITLE = "    Support Us <3"
    
    private let PURCHASE_SUCCESS_TITLE = "Thank you"
    private let PURCHASE_REMOVE_ADS_SUCCESS_MESSAGE = "Ads are now removed! We hope you continue enjoy using Voatify!"
    private let PURCHASE_FAILED_MESSAGE = "Purchase was cancelled."
    
    // Delegate
    weak var delegate: LeftMenuControllerDelegate?
    
    
    // Dependencies
    var dataManager: DataManagerProtocol?
    var analyticsManager: AnalyticsManagerProtocol?
    var inAppPurchaseManager: InAppPurchaseManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data from data manager
        self.loadData()
        self.tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func loadData() {
        // Load saved data
        if let verionDataModel = dataManager?.getSavedData() {
            
            // Load subverses
            self.subverseCellViewModels = self.createSubverseViewModels(withNames: verionDataModel.subversesVisited!)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { alertAction in
            
        }))
        
        self.present(alertController, animated: true) {
            
        }
    }
    
    private func purchaseRemoveAds() {
        
        self.showActivityIndicator()
        self.inAppPurchaseManager?.fetchProducts(productIds: [VerionProductIds.removeAds]) { error in
            
            self.hideActivityIndicator()
            guard error == nil else {
                self.showAlert(title: "Error", message: "There was a problem. Please try again later.")
                return
            }
            
            self.showActivityIndicator()
            self.inAppPurchaseManager?.purchaseProduct(productId: VerionProductIds.removeAds) { error in
                
                self.hideActivityIndicator()
                if error == nil {
                    self.showAlert(title: self.PURCHASE_SUCCESS_TITLE, message: self.PURCHASE_REMOVE_ADS_SUCCESS_MESSAGE)
                    if let _ = self.delegate?.leftMenuDidPurchaseProduct(leftMenu: self, productId: VerionProductIds.removeAds) {
                        // Success, do nothing
                        
                        // Analytics
                        self.analyticsManager?.logEvent(name: AnalyticsEvents.leftMenuPurchasedRemoveAds, timed: false)
                    } else {
                        #if DEBUG
                        print("Warning: LeftMenu's delegate may not be set for purchasing IAP.")
                        #endif
                    }
                } else {
                    self.showAlert(title: "", message: self.PURCHASE_FAILED_MESSAGE)
                }
                
            }
        }
    }
    
    private func showActivityIndicator() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self.activtyIndicator)
        self.activtyIndicator.center = CGPoint(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height/2.0)
        self.activtyIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        self.activtyIndicator.stopAnimating()
        self.activtyIndicator.removeFromSuperview()
    }
    
    fileprivate func saveData(completion: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            let verionDataModel = self.dataManager?.getSavedData()
            
            verionDataModel?.subversesVisited?.removeAll()
            for subverseCellViewModel in self.subverseCellViewModels {
                verionDataModel?.subversesVisited?.append(subverseCellViewModel.subverseName)
            }
            
            self.dataManager?.saveData(dataModel: verionDataModel!)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func createSubverseViewModels(withNames names: [String]) -> [SubverseCellViewModel]{
        var subverseCellViewModels: [SubverseCellViewModel] = []
        for i in 0..<names.count {
            let subverseCellViewModel = SubverseCellViewModel()
            subverseCellViewModel.subverseName = names[i]
            
            subverseCellViewModels.append(subverseCellViewModel)
        }
        
        return subverseCellViewModels
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return LeftMenuSections.allValues.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case LeftMenuSections.subverseHistory.rawValue:
            guard self.subverseCellViewModels.count != 0 else {
                return 0
            }
            
            let numOfCells = self.subverseCellViewModels.count + self.clearHistoryCellCount
            
            return numOfCells
            
        case LeftMenuSections.supportUs.rawValue:
            return SupportUsRows.allValues.count
            
        default:
            break;
        }
        
        // This should never be reached
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case LeftMenuSections.subverseHistory.rawValue:
            
            // If last cell, it is the Clear History cell
            if indexPath.row == self.subverseCellViewModels.count {
                let clearHistoryCell = tableView.dequeueReusableCell(withIdentifier: self.CLEAR_HISTORY_CELL_REUSE_ID)
                
                return clearHistoryCell!
            } else {
                // Subverse history cells
                let historyCell = tableView.dequeueReusableCell(withIdentifier: self.SUBVERSE_CELL_REUSE_ID, for: indexPath) as! SubverseCell
                
                let viewModel = self.subverseCellViewModels[indexPath.row]
                historyCell.bind(toViewModel: viewModel)
                
                return historyCell
            }
        case LeftMenuSections.supportUs.rawValue:
            
            // Remove ads cell
            if indexPath.row == SupportUsRows.removeAds.rawValue {
                let removeAdsCell = tableView.dequeueReusableCell(withIdentifier: self.REMOVE_ADS_CELL_REUSE_ID, for: indexPath)
                return removeAdsCell
                
            } else if indexPath.row == SupportUsRows.donate.rawValue {
                
                // Donate cell
                let donateCell = tableView.dequeueReusableCell(withIdentifier: self.DONATE_CELL_REUSE_ID, for: indexPath)
                return donateCell
                
            } else {
                // Should never be reached
                let transparentCell = tableView.dequeueReusableCell(withIdentifier: self.TRANSPARENT_CELL_REUSE_ID)
                return transparentCell!
            }
            
        default:
            let transparentCell = tableView.dequeueReusableCell(withIdentifier: self.TRANSPARENT_CELL_REUSE_ID)
            
            return transparentCell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        switch indexPath.section {
        case LeftMenuSections.subverseHistory.rawValue:
            
            // Delegate - tell to Go to Subverse
            if indexPath.row < self.subverseCellViewModels.count {
                let subverseName = self.subverseCellViewModels[indexPath.row].subverseName
                self.notifyDelegateToGoToSubverse(name: subverseName)
            } else {
                // Clear History
                if indexPath.row == self.subverseCellViewModels.count {
                    self.clearHistory()
                }
            }
            
        case LeftMenuSections.supportUs.rawValue:
            if indexPath.row == SupportUsRows.removeAds.rawValue {
                self.purchaseRemoveAds()
            }
        default:
            break
        }
    }
    
    private func notifyDelegateToGoToSubverse(name: String) {
        if let _ = self.delegate?.leftMenuDidSelectSubverse(leftMenu: self, subverseName: name) {
            
            // Analytics
            let params = AnalyticsEvents.getLeftMenuGoToSubverseFromHistoryParams(subverseName: name)
            self.analyticsManager?.logEvent(name: AnalyticsEvents.leftMenuGoToSubverseFromHistory, params: params, timed: false)
            
            // Success, do nothing
        } else {
            #if DEBUG
                print("Warning: Left Menu Controller's delegate may not be set.")
            #endif
        }
    }
    
    private func clearHistory() {
        // Analytics
        var subverseNames: [String] = []
        for viewModel in self.subverseCellViewModels {
            subverseNames.append(viewModel.subverseName)
        }
        let params = AnalyticsEvents.getLeftMenuClearHistoryParams(subverseNames: subverseNames)
        self.analyticsManager?.logEvent(name: AnalyticsEvents.leftMenuClearHistory, params: params, timed: false)
        
        
        let range = Range.init(uncheckedBounds: (lower: 0, upper: 1))
        let indexSet = IndexSet.init(integersIn: range)
        self.subverseCellViewModels.removeAll()
        
        self.tableView.reloadData()
        self.tableView.reloadSections(indexSet, with: .automatic)
        
        self.delegate?.leftMenuDidClearHistory(leftMenu: self)
        
        self.saveData(){
            
        }
    }
    
    // Headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case LeftMenuSections.subverseHistory.rawValue:
            return self.SUBVERSE_HISTORY_SECTION_TITLE
        case LeftMenuSections.supportUs.rawValue:
            return self.SUPPORT_US_SECTION_TITLE
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return self.SECTION_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = UIColor.black
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
    
    fileprivate func limitSubverseHistory(byMaxCount maxCount: Int) {
        if self.subverseCellViewModels.count > maxCount {
            let numOfElementsToRemove = self.subverseCellViewModels.count - maxCount
            self.subverseCellViewModels.removeLast(numOfElementsToRemove)
        }
    }

}

extension LeftMenuController {
    
    func addToHistory(subverseName: String) {
        let subverseCellViewModel = SubverseCellViewModel()
        subverseCellViewModel.subverseName = subverseName
        
        // If it already exists, move it to the top. Otherwise, prepend it
        var duplicateIndex = -1
        
        for i in 0..<self.subverseCellViewModels.count {
            let viewModel = self.subverseCellViewModels[i]
            // Duplicate found
            if viewModel.subverseName == subverseName {
                duplicateIndex = i
                break
            }
        }
        
        if duplicateIndex >= 0 {
            // Duplicate exists, move to top
            let duplicateViewModel = self.subverseCellViewModels.remove(at: duplicateIndex)
            self.subverseCellViewModels.insert(duplicateViewModel, at: 0)
            
        } else {
            // No duplicates, Prepend to history
            self.subverseCellViewModels.insert(subverseCellViewModel, at: 0)
        }
        
        // Max history
        self.limitSubverseHistory(byMaxCount: self.MAX_NUM_HISTORY_ENTRIES)
        
        // Reload table
        self.tableView.reloadData()
        
        // Save
        self.saveData {
            
        }
    }
}
