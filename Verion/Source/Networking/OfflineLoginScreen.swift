//
//  OfflineLoginScreen.swift
//  Verion
//
//  Created by Simon Chen on 1/27/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwinjectStoryboard

class OfflineLoginScreen: LoginScreenProtocol, LoginControllerDelegate {
    
    enum OfflineLoginError: Error {
        case failedLogin
        case cancelledLogin
    }
    
    // Dependencies
    private var authHandler: OAuth2Handler?
    private var dataManager: DataManagerProtocol?
    
    private var completion: (_ username: String, _ error: Error?) -> ()

    
    required init(authHandler: OAuth2Handler, dataManager: DataManagerProtocol) {
        self.authHandler = authHandler
        self.dataManager = dataManager
        self.completion = { username, error in
        }
    }
    
    
    func presentLogin(rootViewController: UIViewController, completion: @escaping (String, Error?) -> ()) {
        
        // Initialize storyboard, view controller
        let storyboard = SwinjectStoryboard.create(name: "Login", bundle: nil)
        let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        loginController.delegate = self
        self.completion = completion
        
        // Push Controller
        rootViewController.present(loginController, animated: true) {
            
        }
    }
    
    func loginControllerDidLogIn(loginController: LoginController, username: String, accessToken: String, refreshToken: String) {
        
        // FIXME: Set access and refresh token to auth handler here
        
        #if DEBUG
            print("Signed In with username: \(username)")
        #endif
        
        self.saveUserData(username: username, accessToken: accessToken, refreshToken: refreshToken)
        
        self.completion(username, nil)
    }
    
    func loginControllerFailedLogin(loginController: LoginController) {
        self.completion("", OfflineLoginError.failedLogin)
    }

    func loginControllerCancelledLogin(loginController: LoginController) {
        self.completion("", OfflineLoginError.cancelledLogin)
    }
    
    private func saveUserData(username: String, accessToken: String, refreshToken: String) {
        let verionDataModel = self.dataManager?.getSavedData()
        verionDataModel?.isLoggedIn = true
        self.dataManager?.saveData(dataModel: verionDataModel!)
        
        
        self.dataManager?.saveUsernameToKeychain(username: username)
        self.dataManager?.saveAccessTokenToKeychain(accessToken: accessToken)
        self.dataManager?.saveRefreshTokenToKeychain(refreshToken: refreshToken)
    }

}
