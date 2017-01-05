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
    
    
    @IBOutlet var thumbnailWidthConstraint: NSLayoutConstraint!
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
    
    weak var viewModel: SubmissionCellViewModel?
    
    let BORDER_WIDTH: CGFloat = 1.0
    let BORDER_COLOR: CGColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
    
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
    
    func bindThumbnailImage() {
        // Thumbnail Image
        if self.viewModel?.thumbnailImage == nil {
            self.thumbnailWidthConstraint.constant = 0
        } else {
            self.thumbnailWidthConstraint.constant = 75
            self.thumbnailImageView.image = self.viewModel?.thumbnailImage
            self.thumbnailImageView.contentMode = .scaleAspectFit
            
            // Set border width only for non-NSFW images. Because it looks better that way
            if self.viewModel?.isNsfw == false {
                self.thumbnailImageView.layer.borderWidth = self.BORDER_WIDTH
            } else {
                self.thumbnailImageView.layer.borderWidth = 0
            }
            
            self.thumbnailImageView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func bind(toViewModel viewModel: SubmissionCellViewModel) {
        self.viewModel = viewModel
        
        // Bind to UI elements
        // Title
        self.titleLabel.text = viewModel.titleString
        
        // Thumbnail Label
        self.thumbnailLabel.text = viewModel.linkShortString
        
        // Clear thumbnail until downloaded
        self.thumbnailImageView.image = nil
        
        // Vote Count Label
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        _ = viewModel.voteCountTotal.observeNext() { [weak self] count in
            self?.voteCountLabel.text = String(count)
        }
        
        // Separated Vote Count Label
        self.voteSeparatedCountLabel.text = viewModel.voteSeparatedCountString.value
        _ = viewModel.voteSeparatedCountString.observeNext() { [weak self] separatedCountString in
            self?.voteSeparatedCountLabel.text = separatedCountString
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
