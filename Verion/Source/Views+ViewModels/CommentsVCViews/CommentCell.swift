//
//  CommentCell.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

protocol CommentCellDelegate: class {
    func commentCellDidChange(commentCell: CommentCell)
    func commentCellDidPressBlockUser(commentCell: CommentCell, username: String)
}

class CommentCell: UITableViewCell {

    @IBOutlet var usernameLabel: UILabel!
    
    let USERNAME_COLOR_DEFAULT = UIColor.init(red: 86.0/255.0, green: 82.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    let USERNAME_COLOR_OP = UIColor.blue
    let USERNAME_COLOR_LOAD_MORE_TITLE = UIColor.init(red: 86.0/255.0, green: 82.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    
    @IBOutlet var datePostedLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var separatedVoteCountLabel: UILabel!
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var minimizeMaximizeLabel: UILabel!
    
    @IBOutlet var shiftingContentView: UIView!
    
    @IBOutlet var shiftingViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var childColorBar: UIView!
    
    
    let BACKGROUND_COLOR_EVEN_CHILD = UIColor.init(red: 135.0/255.0, green: 145.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    let BACKGROUND_COLOR_ODD_CHILD = UIColor.init(red: 141.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    @IBOutlet var headerView: UIView!
    
    let MINIMIZED_LABEL_STRING = "[+]"
    let MAXIMIZED_LABEL_STRING = "[-]"
    let MINIMIZE_MAXIMIZE_DELAY_TIME: Float = 0.15
    
    private var bindings: [Disposable] = []
    weak var delegate: CommentCellDelegate?
    weak var viewModel: CommentCellViewModel?
    
    @IBOutlet var blockUserButton: UIButton!
    @IBAction func pressedBlockUser(_ sender: Any) {
        self.notifyDelegateDidPressBlockUser(sender: sender)
    }
    
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.headerView.layer.borderWidth = 1.0
        self.headerView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: CommentCellViewModel, shouldFilterLanguage: Bool) {
        
        self.viewModel = viewModel
        viewModel.resetViewBindings()
        
        
        // Background offset and colors
        self.setBackgroundProperties(forViewModel: viewModel)
        
        
        // Username
        self.setUsernameProperties(forViewModel: viewModel)
        
        // Header data
        if viewModel.isLoadMoreCell {
            self.clearHeaderElements()
        } else {
            self.setHeaderProperties(fromViewModel: viewModel)
        }
        
        // Text Content
        if shouldFilterLanguage == true {
            self.textView.attributedText = viewModel.attributedTextString.censored()
        } else {
            self.textView.attributedText = viewModel.attributedTextString
        }
        
        // Minimize and Maximize
        self.setMinimizeMaximizeBindings(forViewModel: viewModel)
        
        // Upvote and downvote buttons
        self.setVotingButtonsBindings(forViewModel: viewModel)
        
        // Blocked user button title
        self.setBlockUserButtonTitle(forViewModel: viewModel)
       
    }
    
    private func setVotingButtonsBindings(forViewModel viewModel: CommentCellViewModel) {
        
        // Bind to User-input events
        // Upvote
        self.upvoteButton.isSelected = viewModel.isUpvoted.value
        self.bindings.append( self.upvoteButton.bnd_tap.observeNext { [weak self] in
            
            // If previously selected
            if self?.upvoteButton.isSelected == true {
                viewModel.didRequestNoVote.value = true
                self?.upvoteButton.isSelected = false
                
            } else {
                // If not previously selected, attempt to select
                viewModel.didRequestUpvote.value = true
                viewModel.didRequestDownvote.value = false
                self?.upvoteButton.isSelected = true
            }
        })
        
        
        viewModel.viewBindings.append( viewModel.isUpvoted.observeNext { [weak self] isUpvoted in
            self?.upvoteButton.isSelected = isUpvoted
            
            if isUpvoted {
                viewModel.upvoteCount.value += 1
                
                // Unselect Downvote
                if self?.downvoteButton.isSelected == true {
                    self?.downvoteButton.isSelected = false
                    viewModel.downvoteCount.value -= 1
                }
            } else if viewModel.didRequestUpvote.value == true {
                viewModel.upvoteCount.value -= 1
                viewModel.didRequestUpvote.value = false
            }
        })
        
        
        // Downvote
        self.downvoteButton.isSelected = viewModel.isDownvoted.value
        self.bindings.append( self.downvoteButton.bnd_tap.observeNext { [weak self] in
            
            // If previously selected
            if self?.downvoteButton.isSelected == true {
                // Request NoVote
                viewModel.didRequestNoVote.value = true
                self?.downvoteButton.isSelected = false
            } else {
                // If not previously selected, attempt to select
                viewModel.didRequestDownvote.value = true
                viewModel.didRequestUpvote.value = false
                self?.downvoteButton.isSelected = true
            }
        })
        
        viewModel.viewBindings.append( viewModel.isDownvoted.observeNext { [weak self] isDownvoted in
            self?.downvoteButton.isSelected = isDownvoted
            
            if isDownvoted {
                viewModel.downvoteCount.value += 1
                
                // Unselect Upvote
                if self?.upvoteButton.isSelected == true {
                    self?.upvoteButton.isSelected = false
                    viewModel.upvoteCount.value -= 1
                }
            } else if viewModel.didRequestDownvote.value == true {
                viewModel.downvoteCount.value -= 1
                viewModel.didRequestDownvote.value = false
            }
            
        })
    }
    
    private func setBackgroundProperties(forViewModel viewModel: CommentCellViewModel) {
        self.shiftingViewLeadingConstraint.constant = CGFloat(viewModel.childDepthIndex) * viewModel.COMMENT_CHILD_ALIGNMENTVIEWS_WIDTH
        if viewModel.childDepthIndex % 2 == 0 {
            self.setBackgroundColors(withColor: self.BACKGROUND_COLOR_EVEN_CHILD)
        } else {
            self.setBackgroundColors(withColor: self.BACKGROUND_COLOR_ODD_CHILD)
        }
    }
    
    private func setBlockUserButtonTitle(forViewModel viewModel: CommentCellViewModel) {
        if viewModel.isBlocked {
            let UNBLOCK_USER_TITLE = "Unblock User"
            self.setBlockUserButtonTitle(title: UNBLOCK_USER_TITLE)
            
        } else {
            let BLOCK_USER_TITLE = "Block User"
            self.setBlockUserButtonTitle(title: BLOCK_USER_TITLE)
        }
    }
    
    private func setBlockUserButtonTitle(title: String) {
        self.blockUserButton.setTitle(title, for: .normal)
        self.blockUserButton.setTitle(title, for: .selected)
        self.blockUserButton.setTitle(title, for: .focused)
    }
    
    private func setMinimizeMaximizeBindings(forViewModel viewModel: CommentCellViewModel) {
        viewModel.viewBindings.append( viewModel.isMinimized.observeNext() { [weak self] isMinimized in
            
            // Notify delegate - probably to allow for refresh of this cell
            if let _ = self?.delegate?.commentCellDidChange(commentCell: self!) {
                if isMinimized == true {
                    self?.hideUIElements()
                }
                else {
                    // Adding a delay to make UI visibility-animation more fluid
                    Delayer.delay(seconds: (self?.MINIMIZE_MAXIMIZE_DELAY_TIME)!) {
                        self?.showUIElements()
                    }
                }
            } else {
                print("Warning: Delegate for Comment Cell may not be set.")
            }
        })
    }
    
    private func setUsernameProperties(forViewModel viewModel: CommentCellViewModel) {
        if viewModel.isUserOP == true {
            self.usernameLabel.textColor = self.USERNAME_COLOR_OP
        } else if viewModel.isLoadMoreCell == true {
            self.usernameLabel.textColor = self.USERNAME_COLOR_LOAD_MORE_TITLE
        } else {
            self.usernameLabel.textColor = self.USERNAME_COLOR_DEFAULT
        }
        self.usernameLabel.text = viewModel.usernameString // If cell is a "LoadMoreCell", username should automatically be supplied by the viewModel

    }
    
    private func clearHeaderElements() {
        self.datePostedLabel.text = ""
        self.voteCountLabel.text = ""
        self.separatedVoteCountLabel.text = ""
    }
    
    private func setHeaderProperties(fromViewModel viewModel: CommentCellViewModel) {
        self.datePostedLabel.text = viewModel.dateString
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        
        viewModel.viewBindings.append( viewModel.voteCountTotal.observeNext() { [weak self] voteCount in
            self?.voteCountLabel.text = String(voteCount)
        })
        
        self.separatedVoteCountLabel.text = viewModel.separatedVoteCountString.value
        
        viewModel.viewBindings.append( viewModel.separatedVoteCountString.observeNext() { [weak self] string in
            self?.separatedVoteCountLabel.text = string
        })
    }
    
    private func hideUIElements() {
        self.textView.isHidden = true
        self.minimizeMaximizeLabel.text = self.MINIMIZED_LABEL_STRING
        self.blockUserButton.isHidden = true
        self.upvoteButton.isHidden = true
        self.downvoteButton.isHidden = true
    }
    
    private func showUIElements() {
        self.textView.isHidden = false
        self.minimizeMaximizeLabel.text = self.MAXIMIZED_LABEL_STRING
        self.blockUserButton.isHidden = false
        self.upvoteButton.isHidden = false
        self.downvoteButton.isHidden = false
    }
    
    private func setBackgroundColors(withColor color: UIColor) {
        self.childColorBar.backgroundColor = color
    }
    
    private func notifyDelegateDidPressBlockUser(sender: Any) {
        if let _ = self.delegate?.commentCellDidPressBlockUser(commentCell: self, username: self.usernameLabel.text!) {
            
        } else {
            #if DEBUG
            print("Warning: CommentCell's delegate may not be set.")
            #endif
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.resetBindings()
    }
    
    private func resetBindings() {
        for binding in self.bindings {
            binding.dispose()
        }
        
        self.bindings.removeAll()
    }
    
    deinit{
        #if DEBUG
            print("Deallocated a Comment Cell")
        #endif
    }
}
