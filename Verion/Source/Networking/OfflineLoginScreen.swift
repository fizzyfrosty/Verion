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
    
    
    func presentLogin(rootViewController: UIViewController, showConfirmation: Bool, completion: @escaping (String, Error?) -> ()) {
        
        let signInClosure: ()->() = { [weak self] in
            // Initialize storyboard, view controller
            let storyboard = SwinjectStoryboard.create(name: "Login", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
            loginController.delegate = self
            self?.completion = completion
            
            // Push Controller
            rootViewController.present(loginController, animated: true) {
                
            }
        }
        
        if showConfirmation {
            // Ask user if they want to log in
            let message = "This feature requires you to sign-in to your Voat account. Would you like to sign in now?"
            let loginAlert = UIAlertController.init(title: "Sign In", message: message, preferredStyle: .alert)
            
            let signInAction = UIAlertAction.init(title: "Sign In", style: .default) { (action) in
                // Sign In
                signInClosure()
            }
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            
            loginAlert.addAction(signInAction)
            loginAlert.addAction(cancelAction)
            
            rootViewController.present(loginAlert, animated: true, completion: nil)
        } else {
            // No confirmation required, sign in
            signInClosure()
        }
    }
    
    func loginControllerDidLogIn(loginController: LoginController, username: String, accessToken: String, refreshToken: String) {
        
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
