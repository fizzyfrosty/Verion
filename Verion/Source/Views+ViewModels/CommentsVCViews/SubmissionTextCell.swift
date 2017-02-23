//
//  SubmissionTextCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionTextCell: UITableViewCell {
    @IBOutlet var textView: UITextView!
    
    private var bgColor: UIColor {
        get {
            return sfxManager!.bgColor1
        }
    }
    
    private weak var sfxManager: SFXManager?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.textView.isScrollEnabled = false
    }
    
    func bind(toViewModel viewModel: SubmissionTextCellViewModel, shouldFilterLanguage: Bool, sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        self.setUIColors()
        
        
        if shouldFilterLanguage == true {
            self.textView.attributedText = viewModel.attributedTextString?.censored()
        } else {
            self.textView.attributedText = viewModel.attributedTextString
        }
    }

    private func setUIColors() {
        self.contentView.backgroundColor = self.bgColor
        self.textView.backgroundColor = self.bgColor
    }
}
