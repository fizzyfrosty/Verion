//
//  SubmissionLinkCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionLinkCell: UITableViewCell {

    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var domainLabel: UILabel!
    @IBOutlet var endpointLabel: UILabel!
    
    @IBOutlet var thumbnailWidthConstraint: NSLayoutConstraint!
    
    
    private var bgColor: UIColor {
        get {
            return sfxManager!.bgColor1
        }
    }
    
    private var linkColor: UIColor {
        get {
            return self.sfxManager!.linkColor
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
    }

    func bind(toViewModel viewModel: SubmissionLinkCellViewModel, sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        self.setUIColors()
        
        self.domainLabel.text = viewModel.domainString
        
        self.endpointLabel.text = viewModel.endpointString
    }
    
    func bindThumbnailImage(fromViewModel viewModel: SubmissionLinkCellViewModel) {
        
        self.thumbnailImageView.image = viewModel.thumbnailImage
        
        if self.thumbnailImageView.image == nil {
            self.thumbnailImageView.image = UIImage(named: "noimageavailable")
        }
        
        self.thumbnailImageView.layer.borderWidth = 1.0
        self.thumbnailImageView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setUIColors() {
        self.contentView.backgroundColor = self.bgColor
        self.domainLabel.textColor = self.linkColor
        self.endpointLabel.textColor = self.linkColor
    }
    
    deinit{
        #if DEBUG
            print("Deallocated a Submission Link Cell")
        #endif
    }
}
