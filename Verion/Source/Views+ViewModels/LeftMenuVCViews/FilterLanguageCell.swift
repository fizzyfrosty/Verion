//
//  FilterLanguageCell.swift
//  Verion
//
//  Created by Simon Chen on 1/10/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

class FilterLanguageCell: UITableViewCell {

    @IBOutlet var enableSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(filterLanguageCellViewModel: FilterLanguageCellViewModel) {
        
        // Set, then bind
        self.enableSwitch.isOn = filterLanguageCellViewModel.shouldFilterLanguage.value
        _ = self.enableSwitch.bnd_isOn.observeNext { shouldFilter in
            filterLanguageCellViewModel.shouldFilterLanguage.value = shouldFilter
        }
        
    }
}
