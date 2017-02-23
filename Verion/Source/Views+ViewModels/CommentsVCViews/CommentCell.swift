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
    func commentCellDidPressComment(commentCell: CommentCell, viewModel: CommentCellViewModel)
}

class CommentCell: UITableViewCell {

    @IBOutlet var usernameLabel: UILabel!
    
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
    
    
    private var bgColor: UIColor {
        get {
            return self.sfxManager!.bgColor1
        }
    }
    
    private var titleColor: UIColor {
        get {
            return self.sfxManager!.titleColor
        }
    }
    
    private var usernameColorOP: UIColor {
        get {
            return self.sfxManager!.linkColor
        }
    }
    
    private let USERNAME_COLOR_DEFAULT_LIGHT_MODE = UIColor.init(red: 86.0/255.0, green: 82.0/255.0, blue: 130.0/255.0, alpha: 1.0)
    private let USERNAME_COLOR_DEFAULT_DARK_MODE = UIColor.init(red: 255.0/255.0, green: 218.0/255.0, blue: 98.0/255.0, alpha: 1.0)
    private var usernameColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return USERNAME_COLOR_DEFAULT_DARK_MODE
            case false:
                return USERNAME_COLOR_DEFAULT_LIGHT_MODE
            }
        }
    }
    
    private let HEADER_BORDER_COLOR_LIGHT_MODE = UIColor.lightGray
    private let HEADER_BORDER_COLOR_DARK_MODE = UIColor.black
    private var headerBorderColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return HEADER_BORDER_COLOR_DARK_MODE
            case false:
                return HEADER_BORDER_COLOR_LIGHT_MODE
            }
        }
    }
    
    
    @IBOutlet var headerView: UIView!
    
    let MINIMIZED_LABEL_STRING = "[+]"
    let MAXIMIZED_LABEL_STRING = "[-]"
    let MINIMIZE_MAXIMIZE_DELAY_TIME: Float = 0.25
    
    // Bindings
    private var bindings: [Disposable] = []

    weak var delegate: CommentCellDelegate?
    weak var viewModel: CommentCellViewModel?
    private weak var sfxManager: SFXManager?
    
    @IBOutlet var blockUserButton: UIButton!
    @IBAction func pressedBlockUser(_ sender: Any) {
        self.notifyDelegateDidPressBlockUser(sender: sender)
    }
    
    @IBAction func pressedCommentButton(_ sender: Any) {
        self.notifyDelegateDidPressComment()
    }
    
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: CommentCellViewModel, shouldFilterLanguage: Bool, sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        self.viewModel = viewModel
        viewModel.resetViewBindings()
        self.resetUI()
        self.setUIColors()
        
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
        if viewModel.isMinimized.value == true {
            self.hideUIElements()
        }
        
        self.setMinimizeMaximizeBindings(forViewModel: viewModel)
        
        // Upvote and downvote buttons
        self.setVotingButtonsBindings(forViewModel: viewModel)
       
        self.setVoteButtonsIsSelected(forViewModel: viewModel)
    }
    
    private func setVoteButtonsIsSelected(forViewModel viewModel: CommentCellViewModel) {
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
    
    private func setVotingButtonsBindings(forViewModel viewModel: CommentCellViewModel) {
        
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
    
    private func setBackgroundProperties(forViewModel viewModel: CommentCellViewModel) {
        self.shiftingViewLeadingConstraint.constant = CGFloat(viewModel.childDepthIndex) * viewModel.COMMENT_CHILD_ALIGNMENTVIEWS_WIDTH
        if viewModel.childDepthIndex % 2 == 0 {
            self.setBackgroundColors(withColor: self.BACKGROUND_COLOR_EVEN_CHILD)
        } else {
            self.setBackgroundColors(withColor: self.BACKGROUND_COLOR_ODD_CHILD)
        }
    }
    
    private func setMinimizeMaximizeBindings(forViewModel viewModel: CommentCellViewModel) {
        
        self.bindings.append( viewModel.isMinimized.observeNext() { [weak self] isMinimized in
            
            // Notify delegate - probably to allow for refresh of this cell
            if let _ = self?.delegate?.commentCellDidChange(commentCell: self!) {
                if isMinimized == true {
                    self?.hideUIElements()
                }
                else {
                    
                    self?.showUIElements()
                    
                    // Adding a delay to make UI visibility-animation more fluid
                    Delayer.delay(seconds: (self?.MINIMIZE_MAXIMIZE_DELAY_TIME)!) {
                        // Only show if it's the same view model, because delay may execute on a different reuse cell
                        if self?.viewModel?.id == viewModel.id {
                            self?.showButtons()
                        }
                    }
                }
            } else {
                print("Warning: Delegate for Comment Cell may not be set.")
            }
        })
    }
    
    private func setUsernameProperties(forViewModel viewModel: CommentCellViewModel) {
        if viewModel.isUserOP == true {
            self.usernameLabel.textColor = self.usernameColorOP
        } else if viewModel.isLoadMoreCell == true {
            self.usernameLabel.textColor = self.usernameColor
        } else {
            self.usernameLabel.textColor = self.usernameColor
        }
        self.usernameLabel.text = viewModel.usernameString // If cell is a "LoadMoreCell", username should automatically be supplied by the viewModel

        self.minimizeMaximizeLabel.textColor = self.usernameLabel.textColor
    }
    
    private func clearHeaderElements() {
        self.datePostedLabel.text = ""
        self.voteCountLabel.text = ""
        self.separatedVoteCountLabel.text = ""
    }
    
    private func setHeaderProperties(fromViewModel viewModel: CommentCellViewModel) {
        self.datePostedLabel.text = viewModel.dateString
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        
        self.bindings.append( viewModel.voteCountTotal.observeNext() { [weak self] voteCount in
            self?.voteCountLabel.text = String(voteCount)
        })
        
        self.separatedVoteCountLabel.text = viewModel.separatedVoteCountString.value
        
        self.bindings.append( viewModel.separatedVoteCountString.observeNext() { [weak self] string in
            self?.separatedVoteCountLabel.text = string
        })
    }
    
    private func hideUIElements() {
        self.textView.isHidden = true
        self.minimizeMaximizeLabel.text = self.MINIMIZED_LABEL_STRING
        self.blockUserButton.isHidden = true
        self.upvoteButton.isHidden = true
        self.downvoteButton.isHidden = true
        self.commentButton.isHidden = true
        self.childColorBar.isHidden = true
    }
    
    private func showUIElements() {
        self.textView.isHidden = false
        self.minimizeMaximizeLabel.text = self.MAXIMIZED_LABEL_STRING
        self.childColorBar.isHidden = false
    }
    
    private func showButtons() {
        self.blockUserButton.isHidden = false
        self.upvoteButton.isHidden = false
        self.downvoteButton.isHidden = false
        self.commentButton.isHidden = false
        
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
    
    private func notifyDelegateDidPressComment() {
        if let _ = self.delegate?.commentCellDidPressComment(commentCell: self, viewModel: self.viewModel!) {
            
        } else {
            #if DEBUG
                print("Warning: CommentCell's delegate may not be set.")
            #endif
        }
    }
    
    private func setUIColors() {
        self.headerView.backgroundColor = self.bgColor
        self.contentView.backgroundColor = self.bgColor
        self.shiftingContentView.backgroundColor = self.bgColor
        self.textView.backgroundColor = self.bgColor
        
        self.separatedVoteCountLabel.textColor = self.titleColor
        self.datePostedLabel.textColor = self.titleColor
        
        self.headerView.layer.borderWidth = 1.0
        self.headerView.layer.borderColor = self.headerBorderColor.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetProperties()
        self.resetBindings()
    }
    
    private func resetUI() {
        self.upvoteButton.isSelected = false
        self.downvoteButton.isSelected = false
    }
    
    private func resetBindings() {
        for binding in self.bindings {
            binding.dispose()
        }
        
        self.bindings.removeAll()
    }
    
    private func resetProperties() {
        self.viewModel = nil
    }
    
    deinit{
        #if DEBUG
            print("Deallocated a Comment Cell")
        #endif
    }
}
