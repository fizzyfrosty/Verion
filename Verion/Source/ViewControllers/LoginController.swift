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

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var signinButton: UIButton!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBAction func pressedSignIn(_ sender: Any) {
        self.performSignIn()
    }
    
    @IBAction func pressedCancel(_ sender: Any) {
        
        self.dismissKeyboard()
        
        // Dismiss on cancel
        self.dismiss(animated: true) {
        }
    }
    
    
    weak var delegate: LoginControllerDelegate?
    
    // Dependencies
    var dataProvider: DataProviderType?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextfield.delegate = self
        self.passwordTextfield.delegate = self
        self.registerKeyboardNotifications()
        self.setFocusForUsernameTextfield()
        
    }
    
    private func setFocusForUsernameTextfield() {
        self.usernameTextfield.becomeFirstResponder()
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // Moving Keyboard up
    //http://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                
                var heightToShift = keyboardSize.height - self.getHeightOfEmptySpaceToView()
                if heightToShift < 0 { heightToShift = 0 }
                
                self.view.frame.origin.y -= heightToShift
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                var heightToShift = keyboardSize.height - self.getHeightOfEmptySpaceToView()
                if heightToShift < 0 { heightToShift = 0 }
                
                self.view.frame.origin.y += heightToShift
            }
        }
    }
    
    private func getHeightOfEmptySpaceToView() -> CGFloat {
        var height: CGFloat = 0
        
        let screenHeight = UIScreen.main.bounds.size.height
        let bgViewHeight = self.backgroundImageView.frame.size.height
        
        height = (screenHeight - bgViewHeight)/2.0
        
        
        return height
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Dismiss keyboard whenever rotated
        self.dismissKeyboard()
        
        // Finished rotating
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            
            
        })
    }

    private func performSignIn() {
        self.dismissKeyboard()
        
        // FIXME: implement
        // Perform Sign In
        
        // Dismiss on completion
        
        
        self.notifyDelegateDidSignIn(username: self.usernameTextfield.text!)
        
        self.dismiss(animated: true) {
        }
    }
    
    private func notifyDelegateDidSignIn(username: String) {
        if let _ = self.delegate?.loginControllerDidLogIn(loginController: self, username: username) {
            
        } else {
            #if DEBUG
            print("Warning: LoginController's delegate may not be set.")
            #endif
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Textfield delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.usernameTextfield {
            
            // Give focus to password
            self.passwordTextfield.becomeFirstResponder()
        } else if textField == self.passwordTextfield {
            
            // Perform Sign In
            self.performSignIn()
        }
        
        return true
    }
}
