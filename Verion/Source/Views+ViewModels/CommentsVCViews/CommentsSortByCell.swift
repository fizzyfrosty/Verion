//
//  CommentsSortByCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

protocol CommentsSortByCellDelegate: class {
    func commentsSortByCell(cell: CommentsSortByCell, didSortBy sortType: SortTypeComments)
    func commentsSortByCell(cell: CommentsSortByCell, didPressShare: Any)
    func commentsSortByCell(cell: CommentsSortByCell, didPressReport: Any)
    func commentsSortByCell(cell: CommentsSortByCell, didPressComment: Any)
}

class CommentsSortByCell: UITableViewCell {

    @IBOutlet var sortByButton: UIButton!
    
    // These are for v1 api implementation
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBAction func pressedShare(_ sender: Any) {
        if let _ = self.delegate?.commentsSortByCell(cell: self, didPressShare: sender) {
        } else {
            #if DEBUG
                print("Warning: CommentsSortByCell's delegate may not be set.")
            #endif
        }
    }
    
    @IBOutlet var reportButton: UIButton!
    @IBAction func pressedReport(_ sender: Any) {
        self.notifyDelegateDidPressReport(sender: sender)
    }
    
    @IBAction func pressedComment(_ sender: Any) {
        self.notifyDelegateDidPressComment(sender: sender)
    }
    
    
    private var bindings: [Disposable] = []
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
        
        self.sortByButton.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: CommentsSortByCellViewModel, submissionCellViewModel: SubmissionCellViewModel) {
        self.viewModel = viewModel
        self.viewModel?.resetViewBindings()
        
        self.resetUI()
        
        // Bind the viewModel to the button's title
        viewModel.viewBindings.append( viewModel.sortType.observeNext() { [weak self] sortTypeComment in
            let titleString = self?.getButtonTitleString(sortTypeString: sortTypeComment.rawValue)
            self?.setButtonTitle(titleString: titleString!)
        })
        
        // Bind to User-input events
        self.setVotingButtonsBindings(forViewModel: submissionCellViewModel)
    }
    
    private func setVotingButtonsBindings(forViewModel viewModel: SubmissionCellViewModel) {
        // Upvote
        self.bindings.append( self.upvoteButton.bnd_tap.observeNext { [weak self] in
            
            viewModel.didRequestUpvote.value = true
            self?.upvoteButton.isSelected = !((self?.upvoteButton.isSelected)!)
            
            // Unselect the other button
            if self?.upvoteButton.isSelected == true {
                self?.downvoteButton.isSelected = false
            }
        })
        
        // Downvote
        self.bindings.append( self.downvoteButton.bnd_tap.observeNext { [weak self] in
            
            viewModel.didRequestDownvote.value = true
            self?.downvoteButton.isSelected = !((self?.downvoteButton.isSelected)!)
            
            // Unselect the other button
            if self?.downvoteButton.isSelected == true {
                self?.upvoteButton.isSelected = false
            }
        })
        
        self.bindings.append( viewModel.voteValue.observeNext { [weak self] voteValue in
            
            // Reset UI
            self?.downvoteButton.isSelected = false
            self?.upvoteButton.isSelected = false
            
            switch voteValue {
            case .down:
                self?.downvoteButton.isSelected = true
            case .up:
                self?.upvoteButton.isSelected = true
            case .none:
                break
            }
        })
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.resetBindings()
        self.resetProperties()
    }
    
    private func resetProperties() {
        self.viewModel = nil
    }
    
    private func resetBindings() {
        for binding in self.bindings {
            binding.dispose()
        }
        
        self.bindings.removeAll()
    }
    
    private func resetUI() {
        self.downvoteButton.isSelected = false
        self.upvoteButton.isSelected = false
    }

}

// MARK - Delegate notifications
extension CommentsSortByCell {
    fileprivate func notifyDelegateDidPressReport(sender: Any) {
        if let _ = self.delegate?.commentsSortByCell(cell: self, didPressReport: sender) {
            
        } else {
            #if DEBUG
            print("Warning: CommentsSortByCell's delegate may not be set.")
            #endif
        }
    }
    
    fileprivate func notifyDelegateDidPressComment(sender: Any) {
        if let _ = self.delegate?.commentsSortByCell(cell: self, didPressComment: sender) {
            
        } else {
            #if DEBUG
                print("Warning: CommentsSortByCell's delegate may not be set.")
            #endif
        }
    }
}



