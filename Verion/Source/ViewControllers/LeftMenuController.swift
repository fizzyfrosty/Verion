//
//  LeftMenuController.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

protocol LeftMenuControllerDelegate: class {
    func leftMenuDidSelectSubverse(leftMenu: LeftMenuController, subverseName: String)
    func leftMenuDidClearHistory(leftMenu: LeftMenuController)
    func leftMenuDidPurchaseProduct(leftMenu: LeftMenuController, productId: String)
    func leftMenuDidPressClose(leftMenu: LeftMenuController)
    func leftMenuDidPressFindSubverse(leftMenu: LeftMenuController)
    func leftMenuDidPressLogin(leftMenu: LeftMenuController)
    func leftMenuDidLogOut(leftMenu: LeftMenuController)
}

class LeftMenuController: UITableViewController {
    
    enum LeftMenuSections: Int {
        case icon = 0
        case subverseHistory = 1
        case filters = 2
        case supportUs = 3
        case contactUs = 4
        case settings = 5
        
        static let allValues = [icon, subverseHistory, filters, supportUs, contactUs, settings]
    }
    
    // Section Titles
    private let SUBVERSE_HISTORY_SECTION_TITLE = "    Subverses Visited"
    private let SUPPORT_US_SECTION_TITLE = "    Support Us <3"
    private let CONTACT_SECTION_TITLE = "    Contact"
    private let FILTERS_SECTION_TITLE = "    Filters"
    private let SECTION_HEADER_FONT_SIZE: CGFloat = 14.0
    
    // Table Elements
    private let SUBVERSE_CELL_REUSE_ID = "SubverseCell"
    private let CLEAR_HISTORY_CELL_REUSE_ID = "ClearHistoryCell"
    private let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    private let SECTION_HEIGHT: CGFloat = 40.0
    private let activityIndicator = ActivityIndicatorProvider.getStandardActivityIndicator()
    private let DEFAULT_CELL_HEIGHT: CGFloat = 50.0
    
    // Title Icon section
    private let ICON_CELL_REUSE_ID = "VoatIconCell"
    private let ICON_CELL_HEIGHT: CGFloat = 150.0
    private let FIND_SUBVERSE_CELL_REUSE_ID = "FindSubverseCell"
    
    enum IconRows: Int {
        case icon = 0
        case findSubverse = 1
        
        static let allValues = [icon, findSubverse]
    }
    
    // Subverse history section
    fileprivate var subverseCellViewModels = [SubverseCellViewModel]()
    private let clearHistoryCellCount: Int = 1
    fileprivate let MAX_NUM_HISTORY_ENTRIES: Int = 5
    
    // Filters section
    enum FilterRows: Int {
        case hideNsfw = 0
        case useNsfwThumbnails = 1
        case filterLanguage = 2
        
        static let allValues = [hideNsfw, useNsfwThumbnails, filterLanguage]
    }
    
    private let HIDE_NSFW_CELL_REUSE_ID = "HideNsfwCell"
    private let USE_NSFW_THUMBS_CELL_REUSE_ID = "UseNsfwThumbnailsCell"
    private let FILTER_LANGUAGE_CELL_REUSE_ID = "FilterLanguageCell"
    
    fileprivate var hideNsfwCellVm: HideNsfwCellViewModel?
    fileprivate var useNsfwThumbnailCellVm: UseNsfwThumbnailsCellViewModel?
    fileprivate var filterLanguageCellVm: FilterLanguageCellViewModel?
    
    // Support us section
    enum SupportUsRows: Int {
        case donate = 0
        case rate = 1
        case removeAds = 2
        case restorePurchases = 3
        
        static let allValues = [removeAds, restorePurchases, donate, rate]
    }
    private let REMOVE_ADS_CELL_REUSE_ID = "RemoveAdsCell"
    private let RESTORE_PURCHASES_REUSE_ID = "RestorePurchasesCell"
    private let DONATE_CELL_REUSE_ID = "DonateCell"
    private let RATE_CELL_REUSE_ID = "RateCell"
    fileprivate let APP_ID = "1188140122"
    fileprivate let SURE_BUTTON_TITLE = "Sure!"
    fileprivate let NAH_BUTTON_TITLE = "Nah"
    
    // Contact us section
    enum ContactUsRows: Int {
        case email = 0
        case voatify = 1
        
        static let allValues = [email, voatify]
    }
    private let EMAIL_CELL_REUSE_ID = "EmailUsCell"
    private let VOATIFY_SUB_REUSE_ID = "VoatifySubCell"
    
    private let PURCHASE_SUCCESS_TITLE = "Ads Removed"
    private let PURCHASE_REMOVE_ADS_SUCCESS_MESSAGE = "Thank you for your support! We hope you continue enjoy using Voatify!"
    private let PURCHASE_FAILED_MESSAGE = "Purchase was cancelled."
    
    // Settings section
    private let SETTINGS_SECTION_TITLE = "    Settings"
    enum SettingsRows: Int {
        case login = 0
        case createAccount = 1
        static let allValues = [login, createAccount]
    }
    private let LOGIN_CELL_REUSE_ID = "LoginCell"
    private let CREATE_ACCOUNT_CELL_REUSE_ID = "CreateAccountCell"
    fileprivate var loginCellViewModel: LoginCellViewModel?
    
    
    private let ERROR_TITLE = "Error"
    private let ERROR_MESSAGE = "There was a problem. Please try again later."
    private let SUCCESS_TITLE = "Success"
    
    fileprivate var savedStatusBarStyle: UIStatusBarStyle = .default
    
    // Delegate
    weak var delegate: LeftMenuControllerDelegate?
    
    
    // Dependencies
    var dataManager: DataManagerProtocol?
    var analyticsManager: AnalyticsManagerProtocol?
    var inAppPurchaseManager: InAppPurchaseManager?
    var authHandler: OAuth2Handler?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data from data manager
        self.setContentInsets()
        self.loadData()
        self.tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.loginCellViewModel = self.getRefreshedLoginCellViewModel()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.saveData {}
    }
    
    private func getRefreshedLoginCellViewModel() -> LoginCellViewModel{
        let loginCellViewModel = LoginCellViewModel()
        
        if let verionDataModel = dataManager?.getSavedData() {
            
            loginCellViewModel.isLoggedIn.value = verionDataModel.isLoggedIn
            if loginCellViewModel.isLoggedIn.value == true {
                
                loginCellViewModel.username = (self.dataManager?.getUsernameFromKeychain())!
            }
        }
        
        return loginCellViewModel
    }
    
    private func setContentInsets() {
        let bottomInset: CGFloat = 200.0
        let originalContentInset = self.tableView.contentInset
        
        let newContentInset = UIEdgeInsets.init(top: originalContentInset.top,
                                                left: originalContentInset.left,
                                                bottom: bottomInset,
                                                right: originalContentInset.right)
        
        self.tableView.contentInset = newContentInset
    }
    
    private func loadData() {
        // Load saved datam should always happen
        if let verionDataModel = dataManager?.getSavedData() {
            
            // Load subverses
            self.subverseCellViewModels = self.createSubverseViewModels(withNames: verionDataModel.subversesVisited!)
            
            // Filter data
            self.hideNsfwCellVm = HideNsfwCellViewModel()
            self.useNsfwThumbnailCellVm = UseNsfwThumbnailsCellViewModel()
            self.filterLanguageCellVm = FilterLanguageCellViewModel()
            
            // Bind Filters
            self.bind(hideNsfwCellViewModel: self.hideNsfwCellVm!)
            self.bind(useNsfwThumbnailCellViewModel: self.useNsfwThumbnailCellVm!)
            self.bind(filterLanguageCellViewModel: self.filterLanguageCellVm!)
            
            // Set Filters
            self.hideNsfwCellVm?.shouldHideNsfwContent.value = verionDataModel.shouldHideNsfw
            self.useNsfwThumbnailCellVm?.shouldUseNsfwThumbnails.value = verionDataModel.shouldUseNsfwThumbnail
            self.useNsfwThumbnailCellVm?.isSwitchEnabled.value = !verionDataModel.shouldHideNsfw
            self.filterLanguageCellVm?.shouldFilterLanguage.value = verionDataModel.shouldFilterLanguage
            
            // Settings
            self.loginCellViewModel = self.getRefreshedLoginCellViewModel()
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
                self.showAlert(title: self.ERROR_TITLE, message: self.ERROR_MESSAGE)
                return
            }
            
            self.showActivityIndicator()
            self.inAppPurchaseManager?.purchaseProduct(productId: VerionProductIds.removeAds) { error in
                
                self.hideActivityIndicator()
                if error == nil {
                    
                    // Purchased remove ads
                    self.showAlert(title: self.PURCHASE_SUCCESS_TITLE, message: self.PURCHASE_REMOVE_ADS_SUCCESS_MESSAGE)
                    
                    // notify delegate
                    self.notifyDelegateDidPurchaseRemoveAds()
                } else {
                    self.showAlert(title: "", message: self.PURCHASE_FAILED_MESSAGE)
                }
                
            }
        }
    }
    
    private func restorePurchases() {
        // Analytics
        self.analyticsManager?.logEvent(name: AnalyticsEvents.leftMenuRestorePurchases, timed: false)
        
        self.showActivityIndicator()
        
        self.inAppPurchaseManager?.restorePurchases(completion: { (productIds, error) in
            
            self.hideActivityIndicator()
            
            guard error == nil else {
                self.showAlert(title: self.ERROR_TITLE, message: self.ERROR_MESSAGE)
                return
            }
            
            var productIdsString = ""
            
            for productId in productIds {
                productIdsString += productId + "\n"
                
                switch productId {
                case VerionProductIds.removeAds:
                    self.notifyDelegateDidPurchaseRemoveAds()
                default:
                    // Should not happen
                    #if DEBUG
                    print("Warning: Invalid Product ID Returned - " + productId)
                    #endif
                    break
                }
            }
            
            // Success
            self.showAlert(title: self.SUCCESS_TITLE, message: "Restored purchases: \(productIdsString)")
            
        })
    }
    
    private func notifyDelegateDidPurchaseRemoveAds() {
        if let _ = self.delegate?.leftMenuDidPurchaseProduct(leftMenu: self, productId: VerionProductIds.removeAds) {
            // Success, do nothing
            
            // Analytics
            self.analyticsManager?.logEvent(name: AnalyticsEvents.leftMenuPurchasedRemoveAds, timed: false)
        } else {
            #if DEBUG
                print("Warning: LeftMenu's delegate may not be set for purchasing IAP.")
            #endif
        }
    }
    
    private func showActivityIndicator() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self.activityIndicator)
        self.activityIndicator.center = CGPoint(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height/2.0)
        self.activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    fileprivate func saveData(completion: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            let verionDataModel = self.dataManager?.getSavedData()
            
            // History
            verionDataModel?.subversesVisited?.removeAll()
            for subverseCellViewModel in self.subverseCellViewModels {
                verionDataModel?.subversesVisited?.append(subverseCellViewModel.subverseName)
            }
            
            // Filters
            verionDataModel?.shouldHideNsfw = self.hideNsfwCellVm!.shouldHideNsfwContent.value
            verionDataModel?.shouldUseNsfwThumbnail = self.useNsfwThumbnailCellVm!.shouldUseNsfwThumbnails.value
            verionDataModel?.shouldFilterLanguage = self.filterLanguageCellVm!.shouldFilterLanguage.value
            
            // Settings
            verionDataModel?.isLoggedIn = self.loginCellViewModel!.isLoggedIn.value
            
            
            // Save
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
        case LeftMenuSections.icon.rawValue:
            return IconRows.allValues.count
            
        case LeftMenuSections.subverseHistory.rawValue:
            guard self.subverseCellViewModels.count != 0 else {
                return 0
            }
            
            let numOfCells = self.subverseCellViewModels.count + self.clearHistoryCellCount
            
            return numOfCells
            
        case LeftMenuSections.filters.rawValue:
            return FilterRows.allValues.count
            
        case LeftMenuSections.supportUs.rawValue:
            return SupportUsRows.allValues.count
            
        case LeftMenuSections.contactUs.rawValue:
            return ContactUsRows.allValues.count
            
        case LeftMenuSections.settings.rawValue:
            return SettingsRows.allValues.count
        default:
            break;
        }
        
        // This should never be reached
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case LeftMenuSections.icon.rawValue:
            if indexPath.row == IconRows.icon.rawValue {
                let iconCell = tableView.dequeueReusableCell(withIdentifier: self.ICON_CELL_REUSE_ID, for: indexPath)
                return iconCell
            } else {
                let findSubverseCell = tableView.dequeueReusableCell(withIdentifier: self.FIND_SUBVERSE_CELL_REUSE_ID, for: indexPath)
                return findSubverseCell
            }
            
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
        case LeftMenuSections.filters.rawValue:
            if indexPath.row == FilterRows.hideNsfw.rawValue {
                let hideNsfwCell = tableView.dequeueReusableCell(withIdentifier: self.HIDE_NSFW_CELL_REUSE_ID, for: indexPath) as! HideNsfwCell
                
                // Bind cell to the viewModel
                hideNsfwCell.bind(hideNsfwCellViewModel: self.hideNsfwCellVm!)
                
                return hideNsfwCell
                
            } else if indexPath.row == FilterRows.useNsfwThumbnails.rawValue {
                let useNsfwThumbnailsCell = tableView.dequeueReusableCell(withIdentifier: self.USE_NSFW_THUMBS_CELL_REUSE_ID, for: indexPath) as! UseNsfwThumbnailsCell
                useNsfwThumbnailsCell.bind(useNsfwThumbnailCellViewModel: self.useNsfwThumbnailCellVm!)
                
                return useNsfwThumbnailsCell
                
            } else if indexPath.row == FilterRows.filterLanguage.rawValue {
                let filterLanguageCell = tableView.dequeueReusableCell(withIdentifier: self.FILTER_LANGUAGE_CELL_REUSE_ID, for: indexPath) as! FilterLanguageCell
                filterLanguageCell.bind(filterLanguageCellViewModel: self.filterLanguageCellVm!)
                
                return filterLanguageCell
                
            }
            
        case LeftMenuSections.supportUs.rawValue:
            
            // Remove ads cell
            if indexPath.row == SupportUsRows.removeAds.rawValue {
                let removeAdsCell = tableView.dequeueReusableCell(withIdentifier: self.REMOVE_ADS_CELL_REUSE_ID, for: indexPath)
                return removeAdsCell
                
            } else if indexPath.row == SupportUsRows.restorePurchases.rawValue {
                let restorePurchasesCell = tableView.dequeueReusableCell(withIdentifier: self.RESTORE_PURCHASES_REUSE_ID, for: indexPath)
                return restorePurchasesCell
                
            } else if indexPath.row == SupportUsRows.donate.rawValue {
                
                // Donate cell
                let donateCell = tableView.dequeueReusableCell(withIdentifier: self.DONATE_CELL_REUSE_ID, for: indexPath)
                return donateCell
                
            } else if indexPath.row == SupportUsRows.rate.rawValue {
                // Rate Cell
                let rateCell = tableView.dequeueReusableCell(withIdentifier: self.RATE_CELL_REUSE_ID, for: indexPath)
                return rateCell
            }
            
        case LeftMenuSections.contactUs.rawValue:
            if indexPath.row == ContactUsRows.email.rawValue {
                let emailCell = tableView.dequeueReusableCell(withIdentifier: self.EMAIL_CELL_REUSE_ID, for: indexPath)
                return emailCell
                
            } else if indexPath.row == ContactUsRows.voatify.rawValue {
                let voatifySubverseCell = tableView.dequeueReusableCell(withIdentifier: self.VOATIFY_SUB_REUSE_ID, for: indexPath)
                return voatifySubverseCell
            }
            
        case LeftMenuSections.settings.rawValue:
            if indexPath.row == SettingsRows.login.rawValue {
                let loginCell = tableView.dequeueReusableCell(withIdentifier: self.LOGIN_CELL_REUSE_ID, for: indexPath) as! LoginCell
                loginCell.bind(viewModel: self.loginCellViewModel!)
                return loginCell
                
            } else if indexPath.row == SettingsRows.createAccount.rawValue {
                let createAccountCell = tableView.dequeueReusableCell(withIdentifier: self.CREATE_ACCOUNT_CELL_REUSE_ID, for: indexPath)
                return createAccountCell
            }
            
        default:
            let transparentCell = tableView.dequeueReusableCell(withIdentifier: self.TRANSPARENT_CELL_REUSE_ID)
            
            return transparentCell!
        }
        
        // Should never be reached
        let transparentCell = tableView.dequeueReusableCell(withIdentifier: self.TRANSPARENT_CELL_REUSE_ID)
        return transparentCell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        switch indexPath.section {
        case LeftMenuSections.icon.rawValue:
            if indexPath.row == IconRows.icon.rawValue {
                self.notifyDelegateDidPressClose()
            } else {
                // Find Subverse
                self.notifyDelegateDidPressFindSubverse()
            }
            
            
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
            } else if indexPath.row == SupportUsRows.restorePurchases.rawValue {
                self.restorePurchases()
            }else if indexPath.row == SupportUsRows.donate.rawValue {
                self.openDonate()
            } else if indexPath.row == SupportUsRows.rate.rawValue {
                self.rateApp()
            }
            
        case LeftMenuSections.contactUs.rawValue:
            if indexPath.row == ContactUsRows.email.rawValue {
                
                // Email
                self.showFeedbackEmail()
                
            } else if indexPath.row == ContactUsRows.voatify.rawValue {
                
                // Go to voatify subverse
                self.notifyDelegateToGoToSubverse(name: "voatify")
            }
            
        case LeftMenuSections.settings.rawValue:
            if indexPath.row == SettingsRows.login.rawValue {
                
                if self.loginCellViewModel?.isLoggedIn.value == true {
                    // Logout if logged in
                    self.logout(username: self.loginCellViewModel!.username)
                } else {
                    // Display login
                    self.notifyDelegateDidPressLogin()
                }
            } else if indexPath.row == SettingsRows.createAccount.rawValue {
                self.createAccount()
            }
        default:
            break
        }
    }
    
    // Headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case LeftMenuSections.subverseHistory.rawValue:
            return self.SUBVERSE_HISTORY_SECTION_TITLE
        case LeftMenuSections.filters.rawValue:
            return self.FILTERS_SECTION_TITLE
        case LeftMenuSections.supportUs.rawValue:
            return self.SUPPORT_US_SECTION_TITLE
        case LeftMenuSections.contactUs.rawValue:
            return self.CONTACT_SECTION_TITLE
        case LeftMenuSections.settings.rawValue:
            return self.SETTINGS_SECTION_TITLE
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case LeftMenuSections.icon.rawValue:
            return 0
        default:
            return self.SECTION_HEIGHT
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: self.SECTION_HEADER_FONT_SIZE)
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case LeftMenuSections.icon.rawValue:
            if indexPath.row == IconRows.icon.rawValue {
                return self.ICON_CELL_HEIGHT
            } else {
                return self.DEFAULT_CELL_HEIGHT
            }
            
        default:
            return self.DEFAULT_CELL_HEIGHT
        }
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
    
    

}

// MARK: - History
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
    }
    
    fileprivate func notifyDelegateDidPressClose() {
        if let _ = self.delegate?.leftMenuDidPressClose(leftMenu: self) {
            // success, do nothing
        } else {
            #if DEBUG
                print("Warning: Left Menu Controller's delegate may not be set.")
            #endif
        }
    }
    
    fileprivate func notifyDelegateDidPressFindSubverse() {
        if let _ = self.delegate?.leftMenuDidPressFindSubverse(leftMenu: self) {
            // success, do nothing
            
            self.analyticsManager?.logEvent(name: AnalyticsEvents.leftMenuFindSubverse, timed: false)
            
        } else {
            #if DEBUG
                print("Warning: Left Menu Controller's delegate may not be set.")
            #endif
        }
    }
    
    fileprivate func notifyDelegateToGoToSubverse(name: String) {
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
    
    fileprivate func clearHistory() {
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
    }
    
    fileprivate func limitSubverseHistory(byMaxCount maxCount: Int) {
        if self.subverseCellViewModels.count > maxCount {
            let numOfElementsToRemove = self.subverseCellViewModels.count - maxCount
            self.subverseCellViewModels.removeLast(numOfElementsToRemove)
        }
    }
}

// MARK: - Filters
extension LeftMenuController {
    
    // Bindings
    fileprivate func bind(hideNsfwCellViewModel: HideNsfwCellViewModel) {
        _ = hideNsfwCellViewModel.shouldHideNsfwContent.observeNext { [weak self] shouldHide in
            if shouldHide {
                self?.hideNsfwContent()
            } else {
                self?.showNsfwContent()
            }
            
            // Bind to enable/disable of UseNsfwThumbnailCell's switch
            self?.useNsfwThumbnailCellVm?.isSwitchEnabled.value = !shouldHide
        }
    }
    
    fileprivate func bind(useNsfwThumbnailCellViewModel: UseNsfwThumbnailsCellViewModel) {
        _ = useNsfwThumbnailCellViewModel.shouldUseNsfwThumbnails.observeNext{ [weak self] shouldUseNsfwThumb in
            if shouldUseNsfwThumb {
                self?.enableNsfwThumbnail()
            } else {
                self?.disableNsfwThumbnail()
            }
        }
    }
    
    fileprivate func bind(filterLanguageCellViewModel: FilterLanguageCellViewModel) {
        _ = filterLanguageCellViewModel.shouldFilterLanguage.observeNext { [weak self] shouldFilterLanguage in
            if shouldFilterLanguage {
                self?.enableFilterLanguage()
            } else {
                self?.disableFilterLanguage()
            }
        }
    }
    
    // Hide nsfw content
    private func hideNsfwContent() {
        // Nothing needs to be done on toggle. Content is automatically hidden from value saved.
        
        #if DEBUG
            print("NSFW Content is hidden.")
        #endif
    }
    
    private func showNsfwContent() {
        
        #if DEBUG
            print("NSFW Content is shown.")
        #endif
    }
    
    // Use nsfw thumbnail
    private func enableNsfwThumbnail() {
        
        #if DEBUG
            print("NSFW Thumbnails are enabled.")
        #endif
    }
    
    private func disableNsfwThumbnail() {
        
        #if DEBUG
            print("NSFW Thumbnails are disabled.")
        #endif
    }
    
    // Filter language
    private func enableFilterLanguage() {
        
        #if DEBUG
            print("Language Filter is enabled.")
        #endif
    }
    
    private func disableFilterLanguage() {
        
        #if DEBUG
            print("Language Filter is disabled.")
        #endif
    }
    
}


let EMAIL_ADDRESS = "contact@workhorsebytes.com"
let EMAIL_SUBJECT = "Voatify Feedback"
// MARK: - Contact
extension LeftMenuController: MFMailComposeViewControllerDelegate {
    
    // Email
    fileprivate func showFeedbackEmail() {
        if MFMailComposeViewController.canSendMail() {
            // Send mail
            let mailComposerVc = self.getMailComposerVc()
            self.present(mailComposerVc, animated: true, completion: nil)
            
        } else {
            // Show error message
            self.showAlert(title: "Error", message: "Email not supported.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Close before showing alerts
        controller.dismiss(animated: true, completion: nil)
        
        // Finished sending email callback
        switch result {
        case .sent:
            self.showAlert(title: "Email Sent", message: "Thank you for your feedback!")
        case .failed:
            self.showAlert(title: "Failed to Send", message: "Please try again later.")
        default:
            break
        }
    }
    
    private func getMailComposerVc() -> MFMailComposeViewController {
        let mailComposerVc = MFMailComposeViewController()
        mailComposerVc.setToRecipients([EMAIL_ADDRESS])
        mailComposerVc.setSubject("Voatify Feedback")
        mailComposerVc.setMessageBody("Here is some feedback for Voatify:\n\n(touch here to add message)", isHTML: false)
        mailComposerVc.mailComposeDelegate = self
        
        return mailComposerVc
    }
}

// MARK: - Support Us

let DONATE_URL = URL.init(string: "https://voatify.com/donate")

extension LeftMenuController {
    fileprivate func openDonate() {
        // Create alert view to ask if they want to open in safari
        let donateAlert = UIAlertController.init(title: "Support Us!", message: "Donations help keep the hamster wheel running at Voatify! Check out the Donation page in Safari?", preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: self.SURE_BUTTON_TITLE, style: .default) { alertAction in
            // Open link in safari
            self.openUrlInSafari(DONATE_URL!)
        }
        let cancelAction = UIAlertAction.init(title: self.NAH_BUTTON_TITLE, style: .cancel) { alertAction in
            // Close alert view
            donateAlert.removeFromParentViewController()
        }
        
        donateAlert.addAction(okAction)
        donateAlert.addAction(cancelAction)
        
        self.present(donateAlert, animated: true, completion: nil)
    }
    
    fileprivate func rateApp() {
        let message = "Giving us a stellar rating would help us a lot! Would you like to rate us on the App Store?"
        let rateAppAlert = UIAlertController.init(title: "Rate Us!", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: self.SURE_BUTTON_TITLE, style: .default, handler: { [weak self] alertAction in
            self?.rateApp(appId: (self?.APP_ID)!)
        })
        let cancelAction = UIAlertAction.init(title: self.NAH_BUTTON_TITLE, style: .cancel, handler: nil)
        
        rateAppAlert.addAction(okAction)
        rateAppAlert.addAction(cancelAction)
        
        self.present(rateAppAlert, animated: true, completion: nil)
    }
    
    private func rateApp(appId: String) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id" + appId) else {
            return
        }
        self.openUrlInSafari(url)
    }
}


// MARK: - Settings

extension LeftMenuController {
    
    fileprivate func createAccount() {
        let registerUrl = URL.init(string: "https://voat.co/account/register")
        self.openUrlInSafariViewController(registerUrl!)
    }
    
    fileprivate func logout(username: String) {
        let logoutAlert = UIAlertController.init(title: "", message: "Logout as user \(username)?", preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "Ok", style: .default) { alertAction in
            // Perform Logout
            self.logout()
            
            self.tableView.reloadData()
            
            self.notifyDelegateDidLogOut()
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { alertAction in
            // Close alert view
            logoutAlert.removeFromParentViewController()
        }
        
        logoutAlert.addAction(okAction)
        logoutAlert.addAction(cancelAction)
        
        self.present(logoutAlert, animated: true, completion: nil)
    }
    
    private func logout() {
        self.loginCellViewModel?.isLoggedIn.value = false
        self.loginCellViewModel?.username = ""
        
        self.dataManager?.saveUsernameToKeychain(username: "")
        self.dataManager?.saveAccessTokenToKeychain(accessToken: "")
        self.dataManager?.saveRefreshTokenToKeychain(refreshToken: "")
        
        self.authHandler?.accessToken = ""
        self.authHandler?.refreshToken = ""
    }
    
    func setLoggedIn(username: String) {
        self.loginCellViewModel?.username = username
        self.loginCellViewModel?.isLoggedIn.value = true
    }
    
    fileprivate func notifyDelegateDidLogOut() {
        if let _ = self.delegate?.leftMenuDidLogOut(leftMenu: self) {
            // success, do nothing
        } else {
            #if DEBUG
                print("Warning: Left Menu Controller's delegate may not be set.")
            #endif
        }
    }
    
    fileprivate func notifyDelegateDidPressLogin() {
        if let _ = self.delegate?.leftMenuDidPressLogin(leftMenu: self) {
            // success, do nothing
        } else {
            #if DEBUG
                print("Warning: Left Menu Controller's delegate may not be set.")
            #endif
        }
    }
}

// MARK: - Opening Safari
extension LeftMenuController: SFSafariViewControllerDelegate {
    fileprivate func openUrlInSafari(_ url: URL) {
        guard #available(iOS 10, *) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    fileprivate func openUrlInSafariViewController(_ url: URL) {
        let safariViewController = SFSafariViewController.init(url: url)
        self.present(safariViewController, animated: true) {
        }
    }
}





