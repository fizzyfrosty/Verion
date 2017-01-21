//
//  LoginPresenter.swift
//  Verion
//
//  Created by Simon Chen on 1/21/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwinjectStoryboard

class LoginPresenter: LoginControllerDelegate {
    
    static let sharedInstance: LoginPresenter = {
        let instance = LoginPresenter.init()
        return instance
    }()
    
    var completion: (_ username: String, _ error: Error?) -> ()
    
    init() {
        self.completion = { username, error in
            
        }
    }
    
    func presentLogin(rootViewController: UIViewController, completion: @escaping (_ username: String, _ error: Error?
        )->() ) {
        
        // Initialize storyboard, view controller
        let storyboard = SwinjectStoryboard.create(name: "Login", bundle: nil)
        let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        loginController.delegate = self
        
        // Push Controller
        rootViewController.present(loginController, animated: true) { 
            
        }
        
        // Receive Login credentials
        
        // Make request to Log in 
        
        // Save the login credentials to keychain and data file
        
        // On complete, call completion closure
        self.completion = completion
    }
    
    
    
    func loginControllerDidLogIn(loginController: LoginController, username: String) {
        
        #if DEBUG
            print("Signed In with username: \(username)")
        #endif
        
        self.completion(username, nil)
    }
    
    func loginControllerFailedLogin(loginController: LoginController) {
        
    }
    
    
}
