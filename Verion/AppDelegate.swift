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
import OAuthSwift

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
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.host == "oauth-callback-url" {
            OAuthSwift.handle(url: url)
            
        } else {
            print ("Warning: Incorrect hostname returned from oauth-callback-url: \(url.host)")
        }
        
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
    
    enum OnlineMode {
        case offline
        case online
    }
    
    class func setup() {
        let defaultContainer = SwinjectStoryboard.defaultContainer
        
        // FIXME: Set Offline or Online mode here before running
        let mode: OnlineMode = .online
        
        defaultContainer.register(LoginScreenProtocol.self) { resolver in
            
            switch mode {
            case .offline:
                return OfflineLoginScreen(authHandler: OAuth2Handler.sharedInstance, dataManager: resolver.resolve(DataManagerProtocol.self)!)
            case .online:
                return OAuthSwiftAuthenticator(authHandler: OAuth2Handler.sharedInstance, dataManager: resolver.resolve(DataManagerProtocol.self)!)
            }
        }
        
        defaultContainer.register(DataProviderType.self){ resolver in
            switch mode {
            case .offline:
                return OfflineDataProvider(apiVersion: .v1, loginScreen: resolver.resolve(LoginScreenProtocol.self)!, analyticsManager: resolver.resolve(AnalyticsManagerProtocol.self)!)
            case .online:
                return VoatDataProvider(apiVersion: .v1, loginScreen: resolver.resolve(LoginScreenProtocol.self)!, analyticsManager: resolver.resolve(AnalyticsManagerProtocol.self)!)
            }
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
        
        defaultContainer.storyboardInitCompleted(SlideController.self) { (Resolver, C) in
            C.loginScreen = Resolver.resolve(LoginScreenProtocol.self)!
        }
        
        defaultContainer.storyboardInitCompleted(SubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = SFXManager.sharedInstance
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
            C.dataManager = ResolverType.resolve(DataManagerProtocol.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.adManager = AdManager.sharedInstance
        })
        
        defaultContainer.storyboardInitCompleted(CommentsViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = SFXManager.sharedInstance
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.dataManager = ResolverType.resolve(DataManagerProtocol.self)!
            C.adManager = AdManager.sharedInstance
            C.loginScreen = ResolverType.resolve(LoginScreenProtocol.self)!
        })
        
        defaultContainer.storyboardInitCompleted(FindSubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.sfxManager = SFXManager.sharedInstance
        })
        
        defaultContainer.storyboardInitCompleted(LeftMenuController.self) { (ResolverType, C) in
            C.dataManager = ResolverType.resolve(DataManagerProtocol.self)!
            C.analyticsManager = ResolverType.resolve(AnalyticsManagerProtocol.self)!
            C.inAppPurchaseManager = InAppPurchaseManager.sharedInstance
            C.authHandler = OAuth2Handler.sharedInstance
            C.sfxManager = SFXManager.sharedInstance
        }
        
        defaultContainer.storyboardInitCompleted(LoginController.self) { (ResolverType, C) in
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
        }
        
        defaultContainer.storyboardInitCompleted(ComposeCommentViewController.self) { (Resolver, controller) in
            controller.dataProvider = Resolver.resolve(DataProviderType.self)!
            controller.sfxManager = SFXManager.sharedInstance
        }
        
        defaultContainer.storyboardInitCompleted(NativeAdViewController.self) { (Resolver, controller) in
            controller.sfxManager = SFXManager.sharedInstance
        }
    }
}



