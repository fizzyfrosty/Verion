//
//  NavigationActivityIndicator.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MBProgressHUD

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
    
    static func getStandardActivityIndicator() -> UIActivityIndicatorView {
        return UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    }
    
    static func showNotification(message: String, view: UIView, completion: @escaping()->()) {
        let SUCCESS_HUD_DISPLAY_TIME: Float = 1.0
        
        let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        progressHud.mode = .customView
        
        let image = UIImage.init(named: "Checkmark")
        let imageView = UIImageView.init(image: image)
        progressHud.customView = imageView
        progressHud.animationType = .fade
        progressHud.label.text = message
        
        progressHud.show(animated: true)
        
        Delayer.delay(seconds: SUCCESS_HUD_DISPLAY_TIME) {
            progressHud.hide(animated: true)
            
            completion()
        }
    }
    
}
