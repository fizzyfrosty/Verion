//
//  SubverseCell.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubverseCell: UITableViewCell {
    @IBOutlet var subverseNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toViewModel viewModel: SubverseCellViewModel) {
        
        self.subverseNameLabel.text = viewModel.subverseName
    }

}
