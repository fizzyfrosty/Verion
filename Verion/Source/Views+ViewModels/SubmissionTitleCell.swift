//
//  SubmissionTitleCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionTitleCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var separatedVoteCountLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var timeAndSubverseLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: SubmissionTitleCellViewModel) {
        // Title
        self.titleLabel.text = viewModel.titleString
        
        // Total Vote count
        _ = viewModel.voteCountTotal.observeNext { (int) in
            self.voteCountLabel.text = String(int)
        }
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        
        // Separated vote count
        _ = viewModel.voteSeparatedCountString.observeNext(with: { (string) in
            self.separatedVoteCountLabel.text = string
        })
        self.separatedVoteCountLabel.text = viewModel.voteSeparatedCountString.value
        
        // Username
        self.userLabel.text = viewModel.usernameString
        
        // Time and Subverse
        self.timeAndSubverseLabel.attributedText = viewModel.timeAndSubverseString
    }

}
