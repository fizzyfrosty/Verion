//
//  SubmissionLoadMoreCell.swift
//  Verion
//
//  Created by Simon Chen on 2/22/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionLoadMoreCell: UITableViewCell {

    weak var sfxManager: SFXManager?
    
    let TEXT_COLOR_LIGHT_MODE = UIColor.init(red: 255.0/255.0, green: 147.0/255.0, blue: 0/255.0, alpha: 1.0)
    let TEXT_COLOR_DARK_MODE = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    var txtColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return TEXT_COLOR_DARK_MODE
            case false:
                return TEXT_COLOR_LIGHT_MODE
            }
        }
    }
    
    let BG_COLOR_LIGHT_MODE = UIColor.white
    let BG_COLOR_DARK_MODE = UIColor.init(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    var bgColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return BG_COLOR_DARK_MODE
            case false:
                return BG_COLOR_LIGHT_MODE
            }
        }
    }
    
    @IBOutlet var loadMoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func bind(sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        
        self.setUIColors()
    }
    
    private func setUIColors() {
        self.contentView.backgroundColor = self.bgColor
        self.loadMoreLabel.textColor = self.txtColor
    }
}
