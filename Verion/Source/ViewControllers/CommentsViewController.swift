//
//  CommentsViewController.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CommentsViewController: UITableViewController {
    
    
    // Cell configuration
    let COMMENT_CELL_REUSE_ID = "CommentCell"
    let SUBMISSION_TITLE_CELL_REUSE_ID = "SubmissionTitleCell"
    let ACTIVITY_INDICATOR_CELL_REUSE_ID = "ActivityIndicatorCell"
    let TRANSPARENT_CELL_REUSE_ID = "TransparentCell"
    let LOAD_MORE_COMMENTS_CELL_REUSE_ID = "LoadMoreComments"
    private let CELL_SPACING: CGFloat = 10.0
    private let LOAD_MORE_CELL_HEIGHT: CGFloat = 50.0
    private let NUM_OF_STARTING_CELLS_TO_DISPLAY = 20
    private let NUM_OF_CELLS_TO_INCREMENT_BY = 15
    private var numOfCellsToDisplay = 0
    
    
    
    
    // Navigation Bar items
    private var ACTIVITY_INDICATOR_LENGTH: CGFloat = 25.0
    private var activityIndicatorCell: ActivityIndicatorCell?
    
    // Dependencies
    var sfxManager: SFXManagerType?
    var dataProvider: DataProviderType?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
        // TODO: Comment View Controller main functions
        // Load Refresh Control
        
        // Load Activity Indicator
        
        // Show NavigationBar activity indicator
        
        // Load Submission Post
        
        // Load Comment Cells
        
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard self.areCommentsLoaded() != false else {
            return 1
        }
        
        return 100
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.section != 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.SUBMISSION_TITLE_CELL_REUSE_ID, for: indexPath)
            return cell
        }
        
        // Loading Cell
        guard self.areCommentsLoaded() != false else {
            self.activityIndicatorCell = tableView.dequeueReusableCell(withIdentifier: self.ACTIVITY_INDICATOR_CELL_REUSE_ID) as! ActivityIndicatorCell?
            self.activityIndicatorCell?.loadActivityIndicator(length: self.ACTIVITY_INDICATOR_LENGTH)
            self.activityIndicatorCell?.showActivityIndicator()
            return self.activityIndicatorCell!
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.COMMENT_CELL_REUSE_ID, for: indexPath)

        // Configure the cell...

        return cell
    }
    
    // TODO: detect that comments are loaded
    func areCommentsLoaded() -> Bool {
        return false
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


}
