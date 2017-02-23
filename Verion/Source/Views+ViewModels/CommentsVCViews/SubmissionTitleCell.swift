//
//  SubmissionTitleCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

class SubmissionTitleCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var separatedVoteCountLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var timeAndSubverseLabel: UILabel!
    @IBOutlet var bottomDivider: UIView!
    
    
    private let BG_COLOR_LIGHT_MODE = UIColor.white
    private let BG_COLOR_DARK_MODE = UIColor.init(red: 55.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    private var bgColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return BG_COLOR_DARK_MODE
            case false:
                return BG_COLOR_LIGHT_MODE
            }
        }
    }
    
    private let DIVIDER_COLOR_LIGHT_MODE = UIColor.lightGray
    private let DIVIDER_COLOR_DARK_MODE = UIColor.black
    private var dividerBgColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return DIVIDER_COLOR_DARK_MODE
            case false:
                return DIVIDER_COLOR_LIGHT_MODE
            }
        }
    }
    
    private var txtColor: UIColor {
        get {
            return self.sfxManager!.titleColor
        }
    }
    
    private var titleColor: UIColor {
        get {
            return self.sfxManager!.textColor
        }
    }
    
    private var voteCountColor: UIColor {
        get {
            return self.sfxManager!.voteCountColor
        }
    }
    
    private let USER_COLOR_LIGHT_MODE = UIColor.init(red: 0/255.0, green: 91.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    private let USER_COLOR_DARK_MODE = UIColor.init(red: 98.0/255.0, green: 176.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    private var usernameColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return USER_COLOR_DARK_MODE
            case false:
                return USER_COLOR_LIGHT_MODE
            }
        }
    }
    
    
    private weak var sfxManager: SFXManager?
    
    // Bindings
    private var bindings: [Disposable] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: SubmissionCellViewModel, shouldFilterLanguage: Bool, sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        self.setUIColors()
        
        // Title
        if shouldFilterLanguage == true {
            self.titleLabel.text = viewModel.titleString.censored()
        } else {
            self.titleLabel.text = viewModel.titleString
        }
        
        // Vote Count Label
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        self.bindings.append( viewModel.voteCountTotal.observeNext() { [weak self] count in
            self?.voteCountLabel.text = String(count)
        })
        
        // Separated Vote Count Label
        self.separatedVoteCountLabel.text = viewModel.voteSeparatedCountString.value
        self.bindings.append( viewModel.voteSeparatedCountString.observeNext() { [weak self] separatedCountString in
            self?.separatedVoteCountLabel.text = separatedCountString
        })
        
        // Total Vote count
        self.bindings.append( viewModel.voteCountTotal.observeNext { [weak self] (int) in
            self?.voteCountLabel.text = String(int)
        })
        self.voteCountLabel.text = String(viewModel.voteCountTotal.value)
        
        // Separated vote count
        self.bindings.append( viewModel.voteSeparatedCountString.observeNext(with: { [weak self] (string) in
            self?.separatedVoteCountLabel.text = string
        }))
        self.separatedVoteCountLabel.text = viewModel.voteSeparatedCountString.value
        
        // Username
        self.userLabel.text = viewModel.username
        
        // Time and Subverse
        self.timeAndSubverseLabel.attributedText = viewModel.submittedToSubverseString
    }
    
    private func setUIColors() {
        self.contentView.backgroundColor = self.bgColor
        self.titleLabel.textColor = self.titleColor
        self.voteCountLabel.textColor = self.voteCountColor
        self.separatedVoteCountLabel.textColor = self.txtColor
        self.userLabel.textColor = self.usernameColor
        self.timeAndSubverseLabel.textColor = self.txtColor
        
        self.bottomDivider.backgroundColor = self.dividerBgColor
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
            print("Deallocated a Submission Title Cell")
        #endif
    }
}
