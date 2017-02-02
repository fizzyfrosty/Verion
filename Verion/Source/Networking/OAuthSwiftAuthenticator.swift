//
//  OAuthSwiftAuthenticator.swift
//  Verion
//
//  Created by Simon Chen on 1/27/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON
import SafariServices

class OAuthSwiftAuthenticator: NSObject, LoginScreenProtocol, SFSafariViewControllerDelegate {
    
    let CLIENT_ID = OAuth2Handler.CLIENT_ID
    let CLIENT_SECRET = OAuth2Handler.CLIENT_SECRET
    let AUTH_ENDPOINT = OAuth2Handler.AUTH_ENDPOINT
    let TOKEN_ENDPOINT = OAuth2Handler.TOKEN_ENDPOINT
    let CALLBACK_URL = OAuth2Handler.CALLBACK_URL
    
    var oauthHandle: OAuthSwiftRequestHandle?
    private var completion: (_ username: String, _ error: Error?) -> ()
    
    enum OAuthError: Error {
        case cancelledLogin
    }
    
    // Dependencies
    private var authHandler: OAuth2Handler?
    private var dataManager: DataManagerProtocol?
    
    required init(authHandler: OAuth2Handler, dataManager: DataManagerProtocol) {
        self.authHandler = authHandler
        self.dataManager = dataManager
        self.completion = { _, _ in}
    }

    func presentLogin(rootViewController: UIViewController, showConfirmation: Bool, completion: @escaping (_ username: String, Error?) -> ()) {
        
        self.completion = completion
        let signInClosure: ()->() = { [weak self] in
            self?.useOauthSwift(rootViewController: rootViewController)
        }
        
        if showConfirmation {
            // Ask user if they want to log in
            let message = "This feature requires you to sign-in to your Voat account. Would you like to sign in now?"
            let loginAlert = UIAlertController.init(title: "Sign In", message: message, preferredStyle: .alert)
            
            let signInAction = UIAlertAction.init(title: "Sign In", style: .default) { (action) in
                // Sign In
                signInClosure()
            }
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                self.completion("", OAuthError.cancelledLogin)
            }
            
            loginAlert.addAction(signInAction)
            loginAlert.addAction(cancelAction)
            
            rootViewController.present(loginAlert, animated: true, completion: nil)
        } else {
            // No confirmation required, sign in
            signInClosure()
        }
        
        
    }
    
    
    private func useOauthSwift(rootViewController: UIViewController) {
        let oauth = OAuth2Swift(consumerKey: self.CLIENT_ID,
                                consumerSecret: self.CLIENT_SECRET,
                                authorizeUrl: self.AUTH_ENDPOINT,
                                accessTokenUrl: self.TOKEN_ENDPOINT,
                                responseType: "code")
        
        let safariHandler = SafariURLHandler(viewController: rootViewController, oauthSwift: oauth)
        safariHandler.delegate = self
        oauth.authorizeURLHandler = safariHandler
        self.oauthHandle = oauth.authorize(withCallbackURL: URL(string: self.CALLBACK_URL)!,
                                           scope: "",
                                           state: "VOATIFY",
                                           success: { [weak self] (credential, response, parameters) in
                                            print ("Successfully Authenticated!")
                                            
                                            let accessToken = credential.oauthToken
                                            let refreshToken = credential.oauthRefreshToken
                                            let username = self?.getUsername(fromResponse: response!)
                                            
                                            self?.saveUserData(username: username!, accessToken: accessToken, refreshToken: refreshToken)
                                            
                                            self?.authHandler?.accessToken = accessToken
                                            self?.authHandler?.refreshToken = refreshToken
                                            
                                            ActivityIndicatorProvider.showNotification(message: "Success!", view: rootViewController.view) {

                                            }
                                            
                                            self?.completion(username!, nil)
                                            
        }) { (error) in
            print ("Failed Authentication!")
            print(error.localizedDescription)
            // Do not return with completion. Only return on pressing Close on Safari
        }
    }
    
    private func getUsername(fromResponse response: OAuthSwiftResponse) -> String {
        
        let json = JSON(data: response.data)
        let username = json["userName"].stringValue
        
        return username
    }
    
    private func saveUserData(username: String, accessToken: String, refreshToken: String) {
        let verionDataModel = self.dataManager?.getSavedData()
        verionDataModel?.isLoggedIn = true
        self.dataManager?.saveData(dataModel: verionDataModel!)
        
        
        self.dataManager?.saveUsernameToKeychain(username: username)
        self.dataManager?.saveAccessTokenToKeychain(accessToken: accessToken)
        self.dataManager?.saveRefreshTokenToKeychain(refreshToken: refreshToken)
    }
    
    // Safari delegates
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        #if DEBUG
            print("Safari View Controller pressed Close")
        #endif
        
        self.completion("", OAuthError.cancelledLogin)
    }
    
}
