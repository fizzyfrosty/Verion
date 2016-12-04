//
//  SubmissionCell.swift
//  Verion
//
//  Created by Simon Chen on 11/30/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class SubmissionCell: UITableViewCell {
    
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var thumbnailLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var voteSeparatedCountLabel: UILabel!
    
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!

    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var submittedByUserLabel: UILabel!
    @IBOutlet var submittedToSubverseLabel: UILabel!
    
    var viewModel: SubmissionCellViewModel?
    
    let BORDER_WIDTH: CGFloat = 1
    let BORDER_COLOR: CGColor = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.borderWidth = self.BORDER_WIDTH
        self.layer.borderColor = self.BORDER_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // TODO: Unfinished binding
    func bind(toViewModel viewModel: SubmissionCellViewModel) {
        self.viewModel = viewModel
        
        // Bind to UI elements
        // Title
        self.titleLabel.text = viewModel.titleString
        
        // Thumbnail Image
        self.thumbnailImageView.image = viewModel.thumbnailImage
        self.thumbnailImageView.contentMode = .scaleAspectFit
        
        // Thumbnail Label
        self.thumbnailLabel.text = viewModel.linkShortString
        
        // Vote Count Label
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        _ = viewModel.voteCountTotal.observeNext() { count in
            self.voteCountLabel.text = String(count)
        }
        
        // Separated Vote Count Label
        self.voteSeparatedCountLabel.text = viewModel.voteSeparatedCountString.value
        _ = viewModel.voteSeparatedCountString.observeNext() { separatedCountString in
            self.voteSeparatedCountLabel.text = separatedCountString
        }
        
        // Comments Label
        self.commentLabel.text = String(viewModel.commentCount)
        
        // Submitted by User label
        self.submittedByUserLabel.attributedText = viewModel.submittedByString
        
        // Submitted to Subverse string
        self.submittedToSubverseLabel.attributedText = viewModel.submittedToSubverseString
        
        // Bind to User-input events
        // Upvote
        _ = self.upvoteButton.bnd_tap.observeNext {
            viewModel.didUpvote.value = true
        }
        
        // Downvote
        _ = self.downvoteButton.bnd_tap.observeNext {
            viewModel.didDownvote.value = true
        }
    }
    
    

}
