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
    private let GOOGLE_AD_UNIT_KEY = "ca-app-pub-4428866879213280/1218252257"
    var adServiceType: AdServiceType = .none
    
    
    static let sharedInstance: AdManager = {
        let instance = AdManager(adServiceType: .admob)
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
        
        let dataManager = VerionDataManager()
        let verionDataModel = dataManager.getSavedData()
        didPurchase = verionDataModel.isRemoveAdsPurchased
        
        // FIXME: Remove before publication
        didPurchase = true
        
        return didPurchase
    }
    
    func getBannerAd(rootViewController: UIViewController) -> UIView? {
        var bannerAd: UIView?
        
        switch self.adServiceType {
        case .admob:
            let adSize: GADAdSize
            if (UIDevice.current.orientation == UIDeviceOrientation.portrait) {
                adSize = kGADAdSizeSmartBannerPortrait
            } else {
                adSize = kGADAdSizeSmartBannerLandscape
            }
            
            bannerAd = GADBannerView.init(adSize: adSize)
            
            let googleBannerAd = bannerAd as! GADBannerView
            googleBannerAd.adUnitID = self.GOOGLE_AD_UNIT_KEY
            googleBannerAd.rootViewController = rootViewController
            googleBannerAd.load(GADRequest())
        default:
            break
        }
        
        return bannerAd
    }
    
    func getBannerAdHeight() -> CGFloat {
        
        var bannerHeight: CGFloat = 0.0
        
        // These are google standards: https://firebase.google.com/docs/admob/ios/banner?hl=en-US
        switch self.adServiceType {
        case .admob:
            let screenHeight = UIScreen.main.bounds.height
            if screenHeight <= 400 {
                bannerHeight = 32.0
            } else if screenHeight > 400 && screenHeight <= 720 {
                bannerHeight = 50.0
            } else {
                bannerHeight = 90.0
            }
        default:
            bannerHeight = 0.0
            break
        }
        
        return bannerHeight
    }
}

extension AdManager: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
    }
}
