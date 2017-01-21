//
//  LoginController.swift
//  Verion
//
//  Created by Simon Chen on 1/21/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol LoginControllerDelegate: class {
    func loginControllerDidLogIn(loginController: LoginController, username: String)
    func loginControllerFailedLogin(loginController: LoginController)
}

class LoginController: UIViewController {
    @IBOutlet var usernameTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var signinButton: UIButton!
    
    @IBAction func pressedSignIn(_ sender: Any) {
        
        // FIXME: implement
        // Perform Sign In
        
        // Dismiss on completion
        
        
        self.notifyDelegateDidSignIn(username: self.usernameTextfield.text!)
    }
    
    @IBAction func pressedCancel(_ sender: Any) {
        
        // Dismiss on cancel
        self.dismiss(animated: true) {
        }
    }
    
    
    weak var delegate: LoginControllerDelegate?
    
    // Dependencies
    var dataProvider: DataProviderType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notifyDelegateDidSignIn(username: String) {
        if let _ = self.delegate?.loginControllerDidLogIn(loginController: self, username: username) {
            
        } else {
            #if DEBUG
            print("Warning: LoginController's delegate may not be set.")
            #endif
        }
    }
    
}
