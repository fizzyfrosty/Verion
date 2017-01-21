//
//  AppDelegate.swift
//  Verion
//
//  Created by Simon Chen on 11/26/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard
import GoogleMobileAds

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let FLURRY_API_KEY = "BKGPY6BG5Y9FWCSSXWGG"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Instantiate a window.
        
        #if !DEBUG
            Flurry.startSession(self.FLURRY_API_KEY)
        #endif
        
        if AdManager.sharedInstance.isRemoveAdsPurchased() == false {
            AdManager.sharedInstance.startAdNetwork()
        }
        
        /*
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil, container: container)
        window.rootViewController = storyboard.instantiateInitialViewController()
        */
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension SwinjectStoryboard {
    class func setup() {
        let defaultContainer = SwinjectStoryboard.defaultContainer
        
        defaultContainer.register(SFXManagerType.self, factory: { _ in
            SFXManager()
        })
        
        defaultContainer.register(DataProviderType.self){ _ in
            OfflineDataProvider(apiVersion: .v1)
            //VoatDataProvider(apiVersion: .v1)
        }
        
        defaultContainer.register(DataManagerProtocol.self) { _ in
            VerionDataManager()
        }
        
        defaultContainer.register(AnalyticsManagerProtocol.self) { _ in
            var analyticsType = AnalyticsType.flurry
            
            #if DEBUG
            analyticsType = .none
            #endif
            
            return AnalyticsManager(analyticsType: analyticsType)
        }
        
        defaultContainer.storyboardInitCompleted(SubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = ResolverType.resolve(SFXManagerType.self)!
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
            C.dataManager = ResolverType.resolve(DataManagerProtocol.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.adManager = AdManager.sharedInstance
            C.loginPresenter = LoginPresenter.sharedInstance
        })
        
        defaultContainer.storyboardInitCompleted(CommentsViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = ResolverType.resolve(SFXManagerType.self)!
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.dataManager = ResolverType.resolve(DataManagerProtocol.self)!
            C.adManager = AdManager.sharedInstance
        })
        
        defaultContainer.storyboardInitCompleted(FindSubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            
        })
        
        defaultContainer.storyboardInitCompleted(LeftMenuController.self) { (ResolverType, C) in
            C.dataManager = ResolverType.resolve(DataManagerProtocol.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.inAppPurchaseManager = InAppPurchaseManager.sharedInstance
        }
        
        defaultContainer.storyboardInitCompleted(LoginController.self) { (ResolverType, C) in
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
        }
    }
}



