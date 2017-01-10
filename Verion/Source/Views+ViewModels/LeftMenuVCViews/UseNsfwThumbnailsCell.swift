//
//  UseNsfwThumbnailsCell.swift
//  Verion
//
//  Created by Simon Chen on 1/10/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class UseNsfwThumbnailsCell: UITableViewCell {
    @IBOutlet var enableSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(useNsfwThumbnailCellViewModel: UseNsfwThumbnailsCellViewModel) {
        
        // Set, then bind
        self.enableSwitch.isEnabled = useNsfwThumbnailCellViewModel.isSwitchEnabled.value
        _ = useNsfwThumbnailCellViewModel.isSwitchEnabled.observeNext { [weak self] isEnabled in
            self?.enableSwitch.isEnabled = isEnabled
        }
        
        self.enableSwitch.isOn = useNsfwThumbnailCellViewModel.shouldUseNsfwThumbnails.value
        _ = self.enableSwitch.bnd_isOn.observeNext { shouldUse in
            useNsfwThumbnailCellViewModel.shouldUseNsfwThumbnails.value = shouldUse
        }
        
    }

}
