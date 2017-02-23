//
//  AdCell.swift
//  Verion
//
//  Created by Simon Chen on 1/19/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

class AdCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var adView: UIView!
    @IBOutlet var topDivider: UIView!
    @IBOutlet var bottomDivider: UIView!
    
    private var titleColor: UIColor {
        get {
            return self.sfxManager!.titleColor
        }
    }
    
    private var bgColor: UIColor {
        get {
            return self.sfxManager!.bgColor1
        }
    }
    
    private let DIVIDER_BG_COLOR_LIGHT_MODE = UIColor.lightGray
    private let DIVIDER_BG_COLOR_DARK_MODE = UIColor.black
    private var dividerBgColor: UIColor {
        get {
            switch self.sfxManager!.isNightModeEnabled {
            case true:
                return DIVIDER_BG_COLOR_DARK_MODE
            case false:
                return DIVIDER_BG_COLOR_LIGHT_MODE
            }
        }
    }
    
    
    private weak var sfxManager: SFXManager?

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
    
    func bind(sfxManager: SFXManager) {
        self.sfxManager = sfxManager
        
        self.setUIColors()
    }
    
    private func setUIColors() {
        self.contentView.backgroundColor = self.bgColor
        self.adView.backgroundColor = self.bgColor
        self.titleLabel.textColor = self.titleColor
        
        self.topDivider.backgroundColor = self.dividerBgColor
        self.bottomDivider.backgroundColor = self.dividerBgColor
    }

}
