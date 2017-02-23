//
//  SubmissionCell.swift
//  Verion
//
//  Created by Simon Chen on 11/30/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

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
    
    // Bindings
    private var bindings: [Disposable] = []

    weak var viewModel: SubmissionCellViewModel?
    weak var sfxManager: SFXManager?
    
    let BORDER_WIDTH: CGFloat = 0.5
    let BORDER_COLOR_LIGHT_MODE: CGColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
    let BORDER_COLOR_DARK_MODE: CGColor = UIColor(colorLiteralRed: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
    var borderColor: CGColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return BORDER_COLOR_DARK_MODE
            case false:
                return BORDER_COLOR_LIGHT_MODE
            }
        }
    }
    
    private var txtColor: UIColor {
        get {
            return self.sfxManager!.titleColor
        }
    }
    
    var bgColor: UIColor {
        get {
            return sfxManager!.bgColor1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
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
    
    func bind(toViewModel viewModel: SubmissionCellViewModel, shouldFilterLanguage: Bool, sfxManager: SFXManager) {
        self.viewModel = viewModel
        self.sfxManager = sfxManager // for nightMode
        
        viewModel.resetViewBindings() // TODO: This may not be needed, as all bindings are owned by the setter
        self.resetUI()
        self.setUIColors()
        
        // Title
        if shouldFilterLanguage == true {
            self.titleLabel.text = viewModel.titleString.censored()
        } else {
            self.titleLabel.text = viewModel.titleString
        }
        
        
        // Thumbnail Label
        self.thumbnailLabel.text = viewModel.linkShortString
        
        // Clear thumbnail until downloaded
        self.thumbnailImageView.image = nil
        
        // Vote Count Label
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        self.bindings.append( viewModel.voteCountTotal.observeNext() { [weak self] count in
            self?.voteCountLabel.text = String(count)
        })
        
        // Separated Vote Count Label
        self.voteSeparatedCountLabel.text = viewModel.voteSeparatedCountString.value
        self.bindings.append( viewModel.voteSeparatedCountString.observeNext() { [weak self] separatedCountString in
            self?.voteSeparatedCountLabel.text = separatedCountString
        })
        
        // Comments Label
        self.commentLabel.text = String(viewModel.commentCount)
        
        // Submitted by User label
        self.submittedByUserLabel.attributedText = viewModel.submittedByString
        
        // Submitted to Subverse string
        self.submittedToSubverseLabel.attributedText = viewModel.submittedToSubverseString
        
        // Bind to User-input events
        self.setVotingButtonsBindings(forViewModel: viewModel)
        
        self.setVoteButtonsIsSelected(forViewModel: viewModel)
    }
    
    private func setVoteButtonsIsSelected(forViewModel viewModel: SubmissionCellViewModel) {
        switch viewModel.voteValue.value {
        case .none:
            // Do nothing
            break;
        case .up:
            self.upvoteButton.isSelected = true
        case .down:
            self.downvoteButton.isSelected = true
        }
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
    
    private func setUIColors() {
        self.layer.borderWidth = self.BORDER_WIDTH
        self.layer.borderColor = self.borderColor
        
        self.titleLabel.textColor = self.txtColor
        self.contentView.backgroundColor = self.bgColor
        
        self.commentLabel.textColor = self.txtColor
        self.submittedByUserLabel.textColor = self.txtColor
        self.submittedToSubverseLabel.textColor = self.txtColor
        self.thumbnailLabel.textColor = self.txtColor
        self.voteCountLabel.textColor = self.txtColor
        self.voteSeparatedCountLabel.textColor = self.txtColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.resetProperties()
        self.resetBindings()

    }
    
    private func resetProperties() {
        self.viewModel = nil
    }
    
    private func resetUI() {
        self.downvoteButton.isSelected = false
        self.upvoteButton.isSelected = false
        
        self.upvoteButton.imageView?.contentMode = .center
        self.downvoteButton.imageView?.contentMode = .center
    }
    
    private func resetBindings() {
        for binding in self.bindings {
            binding.dispose()
        }
        
        self.bindings.removeAll()
    }

    deinit{
        #if DEBUG
            print("Deallocated a Submission Cell")
        #endif
    }

}
