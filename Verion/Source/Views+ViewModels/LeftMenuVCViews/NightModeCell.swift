//
//  NightModeCell.swift
//  Verion
//
//  Created by Simon Chen on 2/22/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class NightModeCell: UITableViewCell {

    
    @IBOutlet var nightModeSwitch: UISwitch!
    private var bindings: [Disposable] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: NightModeCellViewModel) {
        
        self.nightModeSwitch.isOn = viewModel.isNightModeEnabled.value
        self.bindings.append( self.nightModeSwitch.bnd_isOn.observeNext(with: { (isEnabled) in
            viewModel.isNightModeEnabled.value = isEnabled
        }))
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
