//
//  SubverseRefreshControl.swift
//  Verion
//
//  Created by Simon Chen on 12/5/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SubverseRefreshControl: UIViewController, UITableViewDelegate {

    let TIME_BEFORE_LABEL_REAPPEARS_SECONDS: Float = 0.5
    var height: CGFloat = 0
    var isRefreshing = false 
    
    var activityIndicator: NVActivityIndicatorView?
    let ACTIVITY_INDICATOR_LENGTH = 30
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var label: SpringLabel!

    
    
    override func viewDidLoad() {
        self.backgroundView.layer.backgroundColor = UIColor.clear.cgColor
        
        self.activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width:self.ACTIVITY_INDICATOR_LENGTH, height: self.ACTIVITY_INDICATOR_LENGTH ),
                                                         type: NVActivityIndicatorType.ballSpinFadeLoader,
                                                         color: UIColor.white,
                                                         padding: 0)
        
        self.backgroundView.addSubview(self.activityIndicator!)
        self.activityIndicator?.isHidden = true
    }
    
    func prepareFrameForShowing() {
        let width = UIScreen.main.bounds.size.width
        
        self.backgroundView.frame = CGRect(x: 0,
                                           y: -height,
                                           width: width,
                                           height: self.height)
        
        self.label.center = CGPoint(x: self.backgroundView.center.x,
                                    y: -self.backgroundView.center.y)
        
        // Set position of activity indicator
        self.activityIndicator?.center = self.label.center
        
        // Show label
        self.label.isHidden = false
    }
    
    // Use Spring to pop in transation?
    func showActivityIndicator() {
        // Start animating
        self.activityIndicator?.isHidden = false
        self.activityIndicator?.startAnimating()
        self.label.isHidden = true
        
    }
    
    func hideActivityIndicator() {
        // stop animating
        self.activityIndicator?.isHidden = true
        self.activityIndicator?.stopAnimating()
        
        Delayer.delay(seconds: self.TIME_BEFORE_LABEL_REAPPEARS_SECONDS) {
            self.label.isHidden = false
            
            self.label.scaleX = 0.1
            self.label.scaleY = 0.1
            self.label.animation = "zoomIn"
            self.label.curve = "easeOut"
            self.label.animate()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}






