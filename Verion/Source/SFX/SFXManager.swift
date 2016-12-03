//
//  SFXManager.swift
//  Verion
//
//  Created by Simon Chen on 11/30/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SFXManager: SFXManagerType {
    
    private let SHADOW_OFFSET_X = -1
    private let SHADOW_OFFSET_Y = 2
    private let SHADOW_OPACITY: Float = 0.5
    private let SHADOW_RADIUS: CGFloat = 1.5
    
    func applyShadow(view: UIView) {
        // Drop shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: self.SHADOW_OFFSET_X, height: self.SHADOW_OFFSET_Y)
        view.layer.shadowOpacity = self.SHADOW_OPACITY
        view.layer.shadowRadius = self.SHADOW_RADIUS
        
        view.clipsToBounds = false
        
        let shadowFrame: CGRect = view.layer.bounds
        let shadowPath: CGPath = UIBezierPath(rect: shadowFrame).cgPath
        view.layer.shadowPath = shadowPath
    }
}
