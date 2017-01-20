//
//  HideNsfwCell.swift
//  Verion
//
//  Created by Simon Chen on 1/10/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class HideNsfwCell: UITableViewCell {
    @IBOutlet var enableSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(hideNsfwCellViewModel: HideNsfwCellViewModel) {
        
        // Set, then bind
        self.enableSwitch.isOn = hideNsfwCellViewModel.shouldHideNsfwContent.value
        _ = self.enableSwitch.bnd_isOn.observeNext { isHidden in
            hideNsfwCellViewModel.shouldHideNsfwContent.value = isHidden
        }
        
    }
}
