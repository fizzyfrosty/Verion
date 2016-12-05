//
//  SubverseRefreshControl.swift
//  Verion
//
//  Created by Simon Chen on 12/5/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubverseRefreshControl: UIViewController, UITableViewDelegate {

    var height: CGFloat = 0
    var isRefreshing = false
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var label: UILabel!
    
    
    override func viewDidLoad() {
        self.backgroundView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func update() {
        let width = UIScreen.main.bounds.size.width
        
        self.backgroundView.frame = CGRect(x: 0,
                                           y: -height,
                                           width: width,
                                           height: self.height)
        
        self.label.center = CGPoint(x: self.backgroundView.center.x,
                                    y: -self.backgroundView.center.y)
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
