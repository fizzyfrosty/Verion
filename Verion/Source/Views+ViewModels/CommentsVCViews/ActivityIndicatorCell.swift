//
//  ActivityIndicatorCell.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ActivityIndicatorCell: UITableViewCell {
    
    
    var activityIndicator: NVActivityIndicatorView?
    var activityIndicatorLength: CGFloat = 5.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadActivityIndicator(length: CGFloat, color: UIColor) {
        self.activityIndicatorLength = length
        
        self.activityIndicator = ActivityIndicatorProvider.getActivityIndicator(type: .ballSpinFadeLoader, length: self.activityIndicatorLength)
        self.activityIndicator?.color = color
        
        self.reloadPosition()
        
        self.contentView.addSubview(self.activityIndicator!)
    }
    
    func reloadPosition() {
        let center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: self.contentView.bounds.size.height/2.0)
        self.activityIndicator?.center = center
    }
    
    func showActivityIndicator() {
        self.activityIndicator?.startAnimating()
    }
    
    func hideActivityIndicator() {
        self.activityIndicator?.stopAnimating()
    }

    func removeActivityIndicator() {
        self.activityIndicator?.removeFromSuperview()
    }

}
