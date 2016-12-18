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
    @IBOutlet var datePostedLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var separatedVoteCountLabel: UILabel!
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var minimizeMaximizeLabel: UILabel!
    
    let MINIMIZED_LABEL_STRING = "[+]"
    let MAXIMIZED_LABEL_STRING = "[-]"
    
    weak var delegate: CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: CommentCellViewModel) {
        
        self.usernameLabel.text = viewModel.usernameString
        
        self.datePostedLabel.text = viewModel.dateString
        
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        _ = viewModel.voteCountTotal.observeNext() { voteCount in
            self.voteCountLabel.text = String(voteCount)
        }
        
        self.separatedVoteCountLabel.text = viewModel.separatedVoteCountString.value
        _ = viewModel.separatedVoteCountString.observeNext() { string in
            self.separatedVoteCountLabel.text = string
        }
        
        self.textView.attributedText = viewModel.attributedTextString
        
        _ = viewModel.isMinimized.observeNext() { isMinimized in
            if let _ = self.delegate?.commentCellDidChange(commentCell: self) {
                if isMinimized == true {
                    self.textView.isHidden = true
                    self.minimizeMaximizeLabel.text = self.MINIMIZED_LABEL_STRING
                }
                else {
                    self.textView.isHidden = false
                    self.minimizeMaximizeLabel.text = self.MAXIMIZED_LABEL_STRING
                }
            } else {
                print("Warning: Delegate for Comment Cell may not be set.")
            }
        }
    }
}
