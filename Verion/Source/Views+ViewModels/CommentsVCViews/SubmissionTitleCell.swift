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
    
    func bind(viewModel: SubmissionCellViewModel, shouldFilterLanguage: Bool) {
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


}
