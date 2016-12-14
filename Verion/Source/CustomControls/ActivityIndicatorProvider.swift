//
//  NavigationActivityIndicator.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ActivityIndicatorProvider {

    
    static func getActivityIndicator(type: NVActivityIndicatorType, length: CGFloat) -> NVActivityIndicatorView {
        let activityIndicatorFrame = CGRect(x: 0,
                                            y: 0,
                                            width: length,
                                            height: length)
        
        let activityIndicator = NVActivityIndicatorView.init(frame: activityIndicatorFrame,
                                                              type: type,
                                                              color: UIColor.white,
                                                              padding: 0)
        
        return activityIndicator
    }
}
