//
//  SubverseSearchResultCell.swift
//  Verion
//
//  Created by Simon Chen on 12/17/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubverseSearchResultCell: UITableViewCell {

    @IBOutlet var subverseLabel: UILabel!
    @IBOutlet var subscriberCountLabel: UILabel!
    @IBOutlet var subverseDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(toViewModel viewModel: SubverseSearchResultCellViewModel) {
        
        self.subverseLabel.text = viewModel.subverseString
        _ = viewModel.subscriberCountString.observeNext() { string in
            self.subscriberCountLabel.text = string
        }
        
        self.subverseLabel.text = viewModel.subverseString
        
        self.subverseDescription.text = viewModel.subverseDescription
    }
}
