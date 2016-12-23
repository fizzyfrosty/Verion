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
}

class LeftMenuController: UITableViewController {
    
    // Table Elements
    private let SUBVERSE_CELL_REUSE_ID = "SubverseCell"
    private var subverseCellViewModels = [SubverseCellViewModel]()
    
    let testValues = ["abc", "123", "banana"]
    
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
            self.subverseCellViewModels = self.createSubverseViewModels(withNames: verionDataModel.subversesVisited)
        }
        
        // FIXME: temporarily populate with view models
        self.subverseCellViewModels = self.createSubverseViewModels(withNames: self.testValues)
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
        return self.subverseCellViewModels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.SUBVERSE_CELL_REUSE_ID, for: indexPath) as! SubverseCell
        
        let viewModel = self.subverseCellViewModels[indexPath.row]
        cell.bind(toViewModel: viewModel)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
