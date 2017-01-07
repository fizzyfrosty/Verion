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
    
    let BACKGROUND_COLOR_EVEN_CHILD = UIColor.white
    let BACKGROUND_COLOR_ODD_CHILD = UIColor.init(red: 226.0/255.0, green: 237.0/255.0, blue: 255.0/255.0, alpha: 1.0)//UIColor.init(red: 209.0/255.0, green: 229.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    
    @IBOutlet var headerView: UIView!
    
    let MINIMIZED_LABEL_STRING = "[+]"
    let MAXIMIZED_LABEL_STRING = "[-]"
    
    weak var delegate: CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.headerView.layer.borderWidth = 1.0
        self.headerView.layer.borderColor = UIColor.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: CommentCellViewModel) {
        
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
        
        
        self.textView.attributedText = viewModel.attributedTextString
        
        _ = viewModel.isMinimized.observeNext() { [weak self] isMinimized in
            if let _ = self?.delegate?.commentCellDidChange(commentCell: self!) {
                if isMinimized == true {
                    self?.textView.isHidden = true
                    self?.minimizeMaximizeLabel.text = self?.MINIMIZED_LABEL_STRING
                }
                else {
                    self?.textView.isHidden = false
                    self?.minimizeMaximizeLabel.text = self?.MAXIMIZED_LABEL_STRING
                }
            } else {
                print("Warning: Delegate for Comment Cell may not be set.")
            }
        }
    }
    
    private func setBackgroundColors(withColor color: UIColor) {
        self.contentView.backgroundColor = color
        self.shiftingContentView.backgroundColor = color
        self.textView.backgroundColor = color
    }
    
    
    deinit{
        #if DEBUG
            print("Deallocated a Comment Cell")
        #endif
    }
}
