//
//  AdManager.swift
//  Verion
//
//  Created by Simon Chen on 12/28/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Appodeal

enum AdServiceType {
    case none
    case admob
    case appodeal
}

class AdManager: NSObject {

    private let GOOGLE_ADS_KEY = "ca-app-pub-4428866879213280~5788052650"
    private let GOOGLE_AD_UNIT_KEY = "ca-app-pub-4428866879213280/1218252257"
    private let APPODEAL_API_KEY = "8f5394101ef4f3f028acfc163ce8bec3163596840b7ec09d"
    
    var adServiceType: AdServiceType = .none
    
    private var currentBannerAd: UIView?
    private var currentMediumRectAd: UIView?
    private var lastRefreshTime: Date?
    private let REFRESH_TIME_INTERVAL: TimeInterval = 16.0
    
    fileprivate var apdLoader: APDNativeAdLoader?
    fileprivate var apdNativeAd: APDNativeAd?
    fileprivate var nativeAdCompletion: (APDNativeAd?, Error?)->() = {_,_ in
    }
    fileprivate var isNativeAdLoading = false
    var isNativeAdShown = true
    
    
    static let sharedInstance: AdManager = {
        let instance = AdManager(adServiceType: .appodeal)
        return instance
    }()
    
    
    init(adServiceType: AdServiceType) {
        super.init()
        
        self.adServiceType = adServiceType
        
        if self.isRemoveAdsPurchased() {
            self.adServiceType = .none
        }
    }
    
    func startAdNetwork() {
        if self.adServiceType == .admob {
            //GADMobileAds.configure(withApplicationID: self.GOOGLE_ADS_KEY)
        } else if self.adServiceType == .appodeal {
            self.initializeAppodealServices()
        }
    }
    
    private func initializeAppodealServices() {
        Appodeal.initialize(withApiKey: self.APPODEAL_API_KEY, types:[.nativeAd, .banner])
    }
    
    func isRemoveAdsPurchased() -> Bool{
        var didPurchase = false
        
        let dataManager = VerionDataManager()
        let verionDataModel = dataManager.getSavedData()
        didPurchase = verionDataModel.isRemoveAdsPurchased
        
        // FIXME: Comment out before publication
        //didPurchase = true
        
        return didPurchase
    }
    
    func getMediumRectAd(rootViewController: UIViewController) -> UIView? {
        var bannerAd: UIView?
        
        switch self.adServiceType {
        case .admob:
            break
        case .appodeal:
            self.currentMediumRectAd = self.getAppodealMediumRectBannerAd(rootViewController: rootViewController)
            bannerAd = self.currentMediumRectAd
            
        default:
            break
        }
        
        return bannerAd
    }
    
    func getBannerAd(rootViewController: UIViewController) -> UIView? {
        var bannerAd: UIView?
        
        switch self.adServiceType {
        case .admob:
            
            /*
            // Check if current time is past the refresh interval for last request time
            if self.isCurrentTimePastRefreshInterval() {
                // If it is, get a new ad
                self.currentBannerAd = self.getGoogleBannerAd(rootViewController: rootViewController)
                bannerAd = self.currentBannerAd
            } else {
                // If it isn't, return the old ad
                bannerAd = self.currentBannerAd
            }*/
            break
        case .appodeal:
            
            self.currentBannerAd = self.getAppodealBannerAd(rootViewController: rootViewController)
            bannerAd = self.currentBannerAd
            
        default:
            break
        }
        
        return bannerAd
    }
    
    func preloadNativeAd() {
        if self.isNativeAdLoading == false && self.isNativeAdShown == true {
            self.isNativeAdLoading = true
            self.loadNativeAd()
        } else {
            #if DEBUG
                print("Not fetching NativeAd. Is currently loading: \(self.isNativeAdLoading), is shown: \(self.isNativeAdShown)")
            #endif
        }
        
    }
    
    func getNativeAd() -> APDNativeAd? {
        var nativeAd: APDNativeAd?
        
        switch self.adServiceType {
        case .admob:
            // unsupported
            break
        case .appodeal:
            nativeAd = self.apdNativeAd
        default:
            // unsupported
            break
        }
        
        return nativeAd
    }
    
    func getNativeAd(completion: @escaping (APDNativeAd?, Error?)->() ){
        
        switch self.adServiceType {
        case .admob:
            // unsupported
            break
        case .appodeal:
            self.nativeAdCompletion = completion
            self.loadNativeAd()
        default:
            // unsupported
            break
        }
        
    }
    
    private func getAppodealMediumRectBannerAd(rootViewController: UIViewController) -> UIView? {
        var bannerAd: AppodealBannerView?
        
        if self.currentMediumRectAd != nil {
            bannerAd = self.currentMediumRectAd as? AppodealBannerView
            bannerAd?.rootViewController = rootViewController
        } else {
            let size = self.getMediumRectangleBannerSize()
            bannerAd = AppodealBannerView.init(size: size, rootViewController: rootViewController)
            bannerAd?.loadAdWhithPrecache()
        }
        
        return bannerAd
    }
    
    private func getAppodealBannerAd(rootViewController: UIViewController) -> UIView? {
        var bannerAd: AppodealBannerView?
        
        if self.currentBannerAd != nil {
            bannerAd = self.currentBannerAd as? AppodealBannerView
            bannerAd?.rootViewController = rootViewController
        } else {
            // Regular banners
            let width = UIScreen.main.bounds.size.width
            let size = CGSize(width: width, height: self.getBannerAdHeight())
 
            bannerAd = AppodealBannerView.init(size: size, rootViewController: rootViewController)
            bannerAd?.loadAdWhithPrecache()
        }
        
        return bannerAd
    }
    
    private func getMediumRectangleBannerSize() -> CGSize {
        return CGSize(width: 300, height: 250)
    }
    
    /*
    private func getGoogleBannerAd(rootViewController: UIViewController) -> UIView? {
        let adSize: GADAdSize
        if (UIDevice.current.orientation == UIDeviceOrientation.portrait) {
            adSize = kGADAdSizeSmartBannerPortrait
        } else {
            adSize = kGADAdSizeSmartBannerLandscape
        }
        
        let googleBannerAd = GADBannerView.init(adSize: adSize)
        googleBannerAd.adUnitID = self.GOOGLE_AD_UNIT_KEY
        googleBannerAd.rootViewController = rootViewController
        googleBannerAd.load(GADRequest())
        
        return googleBannerAd
    }*/
    
    private func isCurrentTimePastRefreshInterval() -> Bool {
        var shouldRefresh = false
        
        let currentTime = Date()
        
        guard self.lastRefreshTime != nil else {
            shouldRefresh = true
            self.lastRefreshTime = currentTime
            
            return shouldRefresh
        }
        
        let timeInterval = currentTime.timeIntervalSince(self.lastRefreshTime!)
        
        if timeInterval > self.REFRESH_TIME_INTERVAL {
            shouldRefresh = true
            self.lastRefreshTime = currentTime
        }
        
        return shouldRefresh
    }
    
    func getMediumRectAdHeight() -> CGFloat {
        
        var bannerHeight: CGFloat = 0.0
        
        switch self.adServiceType {
        case .admob:
            // Unsupported
            break
        case .appodeal:
            bannerHeight = self.getMediumRectangleBannerSize().height
        default:
            bannerHeight = 250.0
            break
        }
        
        return bannerHeight
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
        case .appodeal:
            let screenHeight = UIScreen.main.bounds.height
            if screenHeight <= 400 {
                bannerHeight = 32.0
            } else if screenHeight > 400 && screenHeight <= 720 {
                bannerHeight = 50.0
            } else {
                bannerHeight = 90.0
            }
        default:
            bannerHeight = 32.0
            break
        }
        
        return bannerHeight
    }
}

// MARK: - Appodeal Native Ads
extension AdManager: APDNativeAdLoaderDelegate {
    
    fileprivate func loadNativeAd() {
        self.apdLoader = APDNativeAdLoader.init()
        self.apdLoader?.delegate = self
        self.apdLoader?.loadAd(with: .noVideo)
    }
    
    func nativeAdLoader(_ loader: APDNativeAdLoader!, didLoad nativeAd: APDNativeAd!) {
        #if DEBUG
            print("Appodeal NativeAd successfully loaded.")
        #endif
        
        self.isNativeAdShown = false
        self.isNativeAdLoading = false
        self.apdNativeAd = nativeAd
        self.nativeAdCompletion(nativeAd, nil)
    }
    
    func nativeAdLoader(_ loader: APDNativeAdLoader!, didFailToLoadWithError error: Error!) {
        #if DEBUG
            print("Warning: Appodeal NativeAd failed to load: \(error.localizedDescription)")
        #endif
        self.isNativeAdLoading = false
        self.nativeAdCompletion(nil, error)
    }
}

/*
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
*/
