//
//  SFXManagerProtocol.swift
//  Verion
//
//  Created by Simon Chen on 11/30/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol SFXManagerType: class{
    
    var isNightModeEnabled: Bool {get set}
    
    func applyShadow(view: UIView)
}
