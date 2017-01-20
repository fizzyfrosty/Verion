//
//  AdCell.swift
//  Verion
//
//  Created by Simon Chen on 1/19/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

class AdCell: UITableViewCell {
    
    @IBOutlet var adView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.adView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
    }

}
