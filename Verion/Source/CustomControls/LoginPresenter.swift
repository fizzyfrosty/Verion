//
//  LoginPresenter.swift
//  Verion
//
//  Created by Simon Chen on 1/21/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwinjectStoryboard

class LoginPresenter {
    
    static let sharedInstance: LoginPresenter = {
        let instance = LoginPresenter.init()
        return instance
    }()
    
    var completion: (_ username: String, _ accessToken: String, _ refreshToken: String, _ error: Error?) -> ()
    
    init() {
        self.completion = { username, accessToken, refreshToken, error in
            
        }
    }
    
    func presentLogin(rootViewController: UIViewController, completion: @escaping (_ username: String, _ accessToken: String, _ refreshToken: String, _ error: Error?
        )->() ) {
        
        
        
        // Receive Login credentials
        
        // Make request to Log in 
        
        // Save the login credentials to keychain and data file
        
        // On complete, call completion closure
        self.completion = completion
    }
    
    enum LoginError: Error {
        case cancelled
        case failed
    }
}
