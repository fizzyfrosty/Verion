//
//  SubverseViewController.swift
//  Verion
//
//  Created by Simon Chen on 11/29/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubverseViewController: UITableViewController {
    
    let SUBMISSION_CELL_REUSE_ID = "SubmissionCell"
    let CELL_SPACING: CGFloat = 10.0
    
    let BGCOLOR: UIColor = UIColor(colorLiteralRed: 0.8, green: 0.4, blue: 0.4, alpha: 1.0)
    
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType!
    
    var subCellViewModels: [SubmissionCellViewModel] = []
    
    
    @IBOutlet var navigationBarLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = self.BGCOLOR
        self.navigationController?.navigationBar.barTintColor = self.BGCOLOR
        self.navigationBarLabel.text = "/v/whatever"
        
        
        self.loadInitialTableCells(dataProvider: self.dataProvider)
        
        //self.tableView.estimatedRowHeight = 140.0;
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadInitialTableCells(dataProvider: DataProviderType) {
        
        // Make initial request with DataProvider
        dataProvider.requestSubverseSubmissions() { submissionDataModels, error in
            // For each data model, initialize a subCell viewModel
            for i in 0..<submissionDataModels.count {
                let subCellViewModel = SubmissionCellViewModel()
                self.subCellViewModels.append(subCellViewModel)
                
                // Bind dataModel-viewModel-dataProvider
                self.dataProvider.bind(subCellViewModel: subCellViewModel, dataModel: submissionDataModels[i])
            }
            
            // Reload table
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.subCellViewModels.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    // Create the Submission Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_CELL_REUSE_ID, for: indexPath) as! SubmissionCell
        
        // Create cell if viewModel exists
        let viewModel = self.subCellViewModels[indexPath.section] as SubmissionCellViewModel
        cell.bind(toViewModel: viewModel)
        self.sfxManager?.applyShadow(view: cell)
        
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

    
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        // Get the corresponding cell
        if self.subCellViewModels.count > 0 {
            if let cell = tableView.cellForRow(at: indexPath) as! SubmissionCell? {
                // Height = titleLabel.topMargin + titleLabel + titleLabel.bottomMargin + submittedby.y
                let titleLabel = cell.titleLabel!
                let titleSize = titleLabel.frame.size
                let titleTopMargin: CGFloat = 5
                let titleBottomMargin: CGFloat = titleTopMargin
                
                height = titleSize.height + titleTopMargin + titleBottomMargin
            }
        }
        
        
        return height
    }
 */
    
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
            OfflineDataProvider()
        }
        
        defaultContainer.registerForStoryboard(SubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = ResolverType.resolve(SFXManagerType.self)!
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
        })
    }
}
