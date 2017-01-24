//
//  CommentCell.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

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
    let BACKGROUND_COLOR_ODD_CHILD = UIColor.init(red: 255.0/255.0, green: 179.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    
    @IBOutlet var headerView: UIView!
    
    let MINIMIZED_LABEL_STRING = "[+]"
    let MAXIMIZED_LABEL_STRING = "[-]"
    
    weak var delegate: CommentCellDelegate?
    weak var viewModel: CommentCellViewModel?
    
    @IBOutlet var blockUserButton: UIButton!
    @IBAction func pressedBlockUser(_ sender: Any) {
        self.notifyDelegateDidPressBlockUser(sender: sender)
    }
    
    
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
        
        // Background
        self.shiftingViewLeadingConstraint.constant = CGFloat(viewModel.childDepthIndex) * viewModel.COMMENT_CHILD_ALIGNMENTVIEWS_WIDTH
        if viewModel.childDepthIndex % 2 == 0 {
            self.setBackgroundColors(withColor: self.BACKGROUND_COLOR_EVEN_CHILD)
        } else {
            self.setBackgroundColors(withColor: self.BACKGROUND_COLOR_ODD_CHILD)
        }
        
        // Name color
        if viewModel.isUserOP == true {
            self.usernameLabel.textColor = self.USERNAME_COLOR_OP
        } else if viewModel.isLoadMoreCell == true {
            self.usernameLabel.textColor = self.USERNAME_COLOR_LOAD_MORE_TITLE
        } else {
            self.usernameLabel.textColor = self.USERNAME_COLOR_DEFAULT
        }
        
        self.usernameLabel.text = viewModel.usernameString
        
        
        // Show title data
        if viewModel.isLoadMoreCell {
            self.datePostedLabel.text = ""
            self.voteCountLabel.text = ""
            self.separatedVoteCountLabel.text = ""
        } else {
            self.datePostedLabel.text = viewModel.dateString
            
            self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
            _ = viewModel.voteCountTotal.observeNext() { [weak self] voteCount in
                self?.voteCountLabel.text = String(voteCount)
            }
            
            self.separatedVoteCountLabel.text = viewModel.separatedVoteCountString.value
            _ = viewModel.separatedVoteCountString.observeNext() { [weak self] string in
                self?.separatedVoteCountLabel.text = string
            }
        }
        
        // Text Content
        if shouldFilterLanguage == true {
            self.textView.attributedText = viewModel.attributedTextString.censored()
        } else {
            self.textView.attributedText = viewModel.attributedTextString
        }
        
        
        
        
        _ = viewModel.isMinimized.observeNext() { [weak self] isMinimized in
            if let _ = self?.delegate?.commentCellDidChange(commentCell: self!) {
                if isMinimized == true {
                    self?.textView.isHidden = true
                    self?.minimizeMaximizeLabel.text = self?.MINIMIZED_LABEL_STRING
                    self?.blockUserButton.isHidden = true
                }
                else {
                    self?.textView.isHidden = false
                    self?.minimizeMaximizeLabel.text = self?.MAXIMIZED_LABEL_STRING
                    self?.blockUserButton.isHidden = false
                }
            } else {
                print("Warning: Delegate for Comment Cell may not be set.")
            }
        }
        
        // Blocked user
        if viewModel.isBlocked {
            let UNBLOCK_USER_TITLE = "Unblock User"
            self.blockUserButton.setTitle(UNBLOCK_USER_TITLE, for: .normal)
            self.blockUserButton.setTitle(UNBLOCK_USER_TITLE, for: .selected)
            self.blockUserButton.setTitle(UNBLOCK_USER_TITLE, for: .focused)
        } else {
            let BLOCK_USER_TITLE = "Block User"
            self.blockUserButton.setTitle(BLOCK_USER_TITLE, for: .normal)
            self.blockUserButton.setTitle(BLOCK_USER_TITLE, for: .selected)
            self.blockUserButton.setTitle(BLOCK_USER_TITLE, for: .focused)
        }
    }
    
    private func setBackgroundColors(withColor color: UIColor) {
        //self.contentView.backgroundColor = color
        //self.shiftingContentView.backgroundColor = color
        //self.textView.backgroundColor = color
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
    
    deinit{
        #if DEBUG
            print("Deallocated a Comment Cell")
        #endif
    }
}
