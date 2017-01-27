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
    
    var authHandler: OAuth2Handler?
    
    private var completion: (_ username: String, _ error: Error?) -> ()

    
    required init(authHandler: OAuth2Handler) {
        self.authHandler = authHandler
        self.completion = { username, error in
        }
    }
    
    
    func presentLogin(rootViewController: UIViewController, completion: @escaping (String, Error?) -> ()) {
        
        // Initialize storyboard, view controller
        let storyboard = SwinjectStoryboard.create(name: "Login", bundle: nil)
        let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        loginController.delegate = self
        
        // Push Controller
        rootViewController.present(loginController, animated: true) {
            
        }
    }
    
    func loginControllerDidLogIn(loginController: LoginController, username: String, accessToken: String, refreshToken: String) {
        
        // FIXME: Set access and refresh token to auth handler here
        
        #if DEBUG
            print("Signed In with username: \(username)")
        #endif
        
        self.completion(username, nil)
    }
    
    func loginControllerFailedLogin(loginController: LoginController) {
        // FIXME: return error
    }

    func loginControllerCancelledLogin(loginController: LoginController) {
        // FIXME: return error
    }

}
