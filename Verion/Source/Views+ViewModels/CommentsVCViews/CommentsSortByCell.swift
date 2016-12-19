//
//  CommentsSortByCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol CommentsSortByCellDelegate: class {
    func commentsSortByCell(cell: CommentsSortByCell, didSortBy sortType: SortTypeComments)
}

class CommentsSortByCell: UITableViewCell {

    @IBOutlet var sortByButton: UIButton!
    
    // TODO: These are for v1 api implementation
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    var viewModel: CommentsSortByCellViewModel?
    var navigationController: UINavigationController?
    
    let SORT_BY_STRING = "Sorted by:"
    
    // Delegate for sorting by view controller
    weak var delegate: CommentsSortByCellDelegate?
    
    @IBAction func sortByTouched(_ sender: UIButton) {
        
        // Present UI for selecting options. It will merely change the View Model, which will dictate action taken.
        guard self.navigationController != nil else {
            print("Error: Unable to present SortBy Actionsheet. Navigation controller for Sort-by Cell is not set.")
            return
        }
        
        // Create action sheet
        let alertController = UIAlertController.init(title: "Sort Comments by", message: nil, preferredStyle: .actionSheet)
        
        // Create Actions corresponding to SortByComments enum choices
        var sortByActions = [UIAlertAction]()
        for sortByType in SortTypeComments.allValues {
            let sortChoice = UIAlertAction.init(title: sortByType.rawValue, style: .default, handler: { alertAction in
                
                // Set the view model
                self.viewModel?.sortType.value = sortByType
                
                // Pass to delegate for actual sorting
                if let _ = self.delegate?.commentsSortByCell(cell: self, didSortBy: sortByType) {
                } else {
                    print("Warning: CommentsSortByCell's delegate may not be set.")
                }
            })
            
            sortByActions.append(sortChoice)
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
            alertController.popoverPresentationController?.sourceView = sender
            alertController.popoverPresentationController?.sourceRect = sender.bounds
        }
        
        // Present
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
        _ = self.viewModel?.sortType.observeNext() { [weak self] sortTypeComment in
            let titleString = self?.getButtonTitleString(sortTypeString: sortTypeComment.rawValue)
            self?.setButtonTitle(titleString: titleString!)
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
