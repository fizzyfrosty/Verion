//
//  SubverseSearchResultCell.swift
//  Verion
//
//  Created by Simon Chen on 12/17/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import ReactiveKit

class SubverseSearchResultCell: UITableViewCell {

    @IBOutlet var subverseLabel: UILabel!
    @IBOutlet var subscriberCountLabel: UILabel!
    @IBOutlet var subverseDescription: UILabel!
    
    
    private weak var sfxManager: SFXManager?
    
    private var bindings: [Disposable] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: SubverseSearchResultCellViewModel, sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        self.setUIColors()
        
        self.subverseLabel.text = viewModel.subverseString
        self.bindings.append( viewModel.subscriberCountString.observeNext() {[weak self] string in
            self?.subscriberCountLabel.text = string
        })
        
        self.subverseLabel.text = viewModel.subverseString
        self.subverseDescription.text = viewModel.subverseDescription
    }
    
    private func setUIColors() {
        self.contentView.backgroundColor = self.sfxManager?.bgColor1
        
        self.subverseLabel.textColor = self.sfxManager?.textColor
        self.subscriberCountLabel.textColor = self.sfxManager?.textColor
        self.subverseDescription.textColor = self.sfxManager?.textColor
    }
    
    override func prepareForReuse() {
        self.resetBindings()
    }
    
    private func resetBindings() {
        for binding in self.bindings {
            binding.dispose()
        }
        
        self.bindings.removeAll()
    }
}
