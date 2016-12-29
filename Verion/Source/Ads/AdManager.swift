//
//  AdManager.swift
//  Verion
//
//  Created by Simon Chen on 12/28/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import GoogleMobileAds

enum AdServiceType {
    case none
    case admob
}

class AdManager: NSObject {

    private let GOOGLE_ADS_KEY = "ca-app-pub-4428866879213280~5788052650"
    var adServiceType: AdServiceType = .none
    
    
    static let sharedInstance: AdManager = {
        let instance = AdManager(adServiceType: .none)
        return instance
    }()
    
    
    init(adServiceType: AdServiceType) {
        self.adServiceType = adServiceType
    }
    
    func startAdNetwork() {
        if self.adServiceType == .admob {
            GADMobileAds.configure(withApplicationID: self.GOOGLE_ADS_KEY)
        }
    }
    
    func isRemoveAdsPurchased() -> Bool{
        var didPurchase = false
        
        
        
        
        return didPurchase
    }
    
    
}
