//
//  CommentsSortByCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class CommentsSortByCell: UITableViewCell {

    @IBOutlet var sortByButton: UIButton!
    
    // TODO: These are for v1 api implementation
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    var viewModel: CommentsSortByCellViewModel?
    var navigationController: UINavigationController?
    
    let SORT_BY_STRING = "Sorted by:"
    
    @IBAction func sortByTouched(_ sender: Any) {
        
        guard self.navigationController != nil else {
            print("Error: Unable to present SortBy Actionsheet. Navigation controller for Sort-by Cell is not set.")
            return
        }
        
        // Create action sheet
        let alertController = UIAlertController.init(title: "Sort Comments by", message: nil, preferredStyle: .actionSheet)
        let topButton = UIAlertAction.init(title: "Top", style: .default, handler: { alertAction in
            self.viewModel?.sortType.value = .top
        })
        
        let newButton = UIAlertAction.init(title: "New", style: .default, handler: { alertAction in
            self.viewModel?.sortType.value = .new
        })
        
        let cancelButton = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(topButton)
        alertController.addAction(newButton)
        alertController.addAction(cancelButton)
        
        navigationController?.present(alertController, animated: true, completion: { 
            
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let titleString = self.getButtonTitleString(sortTypeString: SortTypeComments.top.rawValue)
        self.setButtonTitle(titleString: titleString)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: CommentsSortByCellViewModel) {
        self.viewModel = viewModel
        
        
        // Bind the viewModel to the button's title
        _ = self.viewModel?.sortType.observeNext() { sortTypeComment in
            let titleString = self.getButtonTitleString(sortTypeString: sortTypeComment.rawValue)
            self.setButtonTitle(titleString: titleString)
        }
    }
    
    private func getButtonTitleString(sortTypeString: String) -> String {
        let titleString = self.SORT_BY_STRING + " " + sortTypeString
        return titleString
    }
    
    private func setButtonTitle(titleString: String) {
        self.sortByButton.setTitle(titleString, for: .normal)
        self.sortByButton.setTitle(titleString, for: .selected)
        self.sortByButton.setTitle(titleString, for: .disabled)
    }

}
