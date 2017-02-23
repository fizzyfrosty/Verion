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

protocol NightModeCellDelegate: class {
    func nightModeCellDidChangeMode(_ cell: NightModeCell, enabled: Bool)
}

class NightModeCell: UITableViewCell {

    weak var delegate: NightModeCellDelegate?
    weak var viewModel: NightModeCellViewModel?
    
    @IBOutlet var nightModeSwitch: UISwitch!
    @IBAction func nightModeChanged(_ sender: UISwitch) {
        self.viewModel?.isNightModeEnabled.value = sender.isOn
        self.delegate?.nightModeCellDidChangeMode(self, enabled: self.viewModel!.isNightModeEnabled.value)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: NightModeCellViewModel) {
        self.viewModel = viewModel
        self.nightModeSwitch.isOn = viewModel.isNightModeEnabled.value
    }

}
