//
//  SFXManager.swift
//  Verion
//
//  Created by Simon Chen on 11/30/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SFXManager {
    
    private let SHADOW_OFFSET_X = -1
    private let SHADOW_OFFSET_Y = 2
    private let SHADOW_OPACITY: Float = 0.5
    private let SHADOW_RADIUS: CGFloat = 1.5
    
    private let TITLE_COLOR_LIGHT_MODE = UIColor.init(red: 112.0/255.0, green: 113.0/255.0, blue: 113.0/255.0, alpha: 1.0)
    private let TITLE_COLOR_DARK_MODE = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    var titleColor: UIColor {
        get {
            switch self.isNightModeEnabled {
            case true:
                return TITLE_COLOR_DARK_MODE
            case false:
                return TITLE_COLOR_LIGHT_MODE
            }
        }
    }
    
    private let TEXT_COLOR_LIGHT_MODE = UIColor.init(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    private let TEXT_COLOR_DARK_MODE = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    var textColor: UIColor {
        get {
            switch self.isNightModeEnabled {
            case true:
                return TEXT_COLOR_DARK_MODE
            case false:
                return TEXT_COLOR_LIGHT_MODE
            }
        }
    }
    
    private let LINK_COLOR_LIGHT_MODE = UIColor.init(red: 0/255.0, green: 91.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    private let LINK_COLOR_DARK_MODE = UIColor.init(red: 98.0/255.0, green: 176.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    var linkColor: UIColor {
        get {
            switch self.isNightModeEnabled {
            case true:
                return LINK_COLOR_DARK_MODE
            case false:
                return LINK_COLOR_LIGHT_MODE
            }
        }
    }
    
    private let VOTE_COLOR_LIGHT_MODE = UIColor.init(red: 238.0/255.0, green: 138.0/255.0, blue: 3.0/255.0, alpha: 1.0)
    private let VOTE_COLOR_DARK_MODE = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    var voteCountColor: UIColor {
        get {
            switch self.isNightModeEnabled {
            case true:
                return VOTE_COLOR_LIGHT_MODE//VOTE_COLOR_DARK_MODE
            case false:
                return VOTE_COLOR_LIGHT_MODE
            }
        }
    }
    
    
    private let BG1_COLOR_LIGHT_MODE = UIColor.white
    private let BG1_COLOR_DARK_MODE = UIColor.init(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    var bgColor1: UIColor {
        get {
            switch self.isNightModeEnabled {
            case true:
                return BG1_COLOR_DARK_MODE
            case false:
                return BG1_COLOR_LIGHT_MODE
            }
        }
    }
    
    var isNightModeEnabled = false
    
    static let sharedInstance: SFXManager = {
        let dataManager = VerionDataManager()
        let instance = SFXManager()
        instance.isNightModeEnabled = dataManager.getSavedData().isNightModeEnabled
        
        return instance
    }()
    
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
    
    static func getAndSetDarkenedView(ontoParentView parentView: UIView, alpha: CGFloat) -> UIView {
        let darkView = UIView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        darkView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        
        let bottom = NSLayoutConstraint.init(item: darkView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: parentView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint.init(item: darkView, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: darkView, attribute: .trailing, relatedBy: .equal, toItem: parentView, attribute: .trailing, multiplier: 1, constant: 0)
        
        parentView.addSubview(darkView)
        parentView.addConstraints([bottom, top, leading, trailing])
        
        return darkView
    }
    
    deinit {
        #if DEBUG
        //print("Deallocated SFXManager")
        #endif
    }
}
