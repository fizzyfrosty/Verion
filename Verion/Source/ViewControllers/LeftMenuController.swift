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
}

class LeftMenuController: UITableViewController {
    
    // Table Elements
    private let SUBVERSE_CELL_REUSE_ID = "SubverseCell"
    private let CLEAR_HISTORY_CELL_REUSE_ID = "ClearHistoryCell"
    private let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    fileprivate var subverseCellViewModels = [SubverseCellViewModel]()
    
    private let clearHistoryCellCount: Int = 1
    
    fileprivate let MAX_NUM_HISTORY_ENTRIES: Int = 20
    
    
    private let SUBVERSE_HISTORY_SECTION_TITLE = "    Subverses Visited"
    
    // Delegate
    weak var delegate: LeftMenuControllerDelegate?
    
    
    // Dependencies
    var dataManager: DataManagerProtocol?
    

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
        if let verionDataModel = dataManager?.getSavedData() {
            self.subverseCellViewModels = self.createSubverseViewModels(withNames: verionDataModel.subversesVisited!)
        }
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard self.subverseCellViewModels.count != 0 else {
            return 0
        }
        
        let numOfCells = self.subverseCellViewModels.count + self.clearHistoryCellCount
        
        return numOfCells
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.subverseCellViewModels.count != 0 else {
            let transparentCell = tableView.dequeueReusableCell(withIdentifier: self.TRANSPARENT_CELL_REUSE_ID)
            
            return transparentCell!
        }
        
        // If last cell, it is the Clear History cell
        if indexPath.row == self.subverseCellViewModels.count {
            let clearHistoryCell = tableView.dequeueReusableCell(withIdentifier: self.CLEAR_HISTORY_CELL_REUSE_ID)
            
            return clearHistoryCell!
        }
        
        // Subverse history cells
        let cell = tableView.dequeueReusableCell(withIdentifier: self.SUBVERSE_CELL_REUSE_ID, for: indexPath) as! SubverseCell
        
        let viewModel = self.subverseCellViewModels[indexPath.row]
        cell.bind(toViewModel: viewModel)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // If no subverse history, do nothing
        guard self.subverseCellViewModels.count != 0 else {
            return
        }
        
        // If selected subverse
        if indexPath.row < self.subverseCellViewModels.count {
            let subverseName = self.subverseCellViewModels[indexPath.row].subverseName
            if let _ = self.delegate?.leftMenuDidSelectSubverse(leftMenu: self, subverseName: subverseName) {
                // Success, do nothing
            } else {
                #if DEBUG
                    print("Warning: Left Menu Controller's delegate may not be set.")
                #endif
            }
        }
        
        // If selected clear, last object
        if indexPath.row == self.subverseCellViewModels.count {
            // Clear it
            self.clearHistory()
        }
    }
    
    private func clearHistory() {
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
        if section == 0 {
            return self.SUBVERSE_HISTORY_SECTION_TITLE
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30.0
        }
        return 0.0
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
