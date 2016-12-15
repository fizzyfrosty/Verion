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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: SubmissionLinkCellViewModel) {
        self.domainLabel.text = viewModel.domainString
        
        self.endpointLabel.text = viewModel.endpointString
    }
    
    func bindThumbnailImage(fromViewModel viewModel: SubmissionLinkCellViewModel) {
        
        self.thumbnailImageView.image = viewModel.thumbnailImage
        
        // TODO: use an image representing the web
        if self.thumbnailImageView.image == nil {
            self.thumbnailImageView.image = UIImage(named: "noimageavailable")
        }
        
        self.thumbnailImageView.layer.borderWidth = 1.0
        self.thumbnailImageView.layer.borderColor = UIColor.black.cgColor
    }
}
