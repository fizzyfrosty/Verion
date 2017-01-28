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

class OAuthSwiftAuthenticator: LoginScreenProtocol {
    
    let CLIENT_ID = OAuth2Handler.CLIENT_ID
    let CLIENT_SECRET = OAuth2Handler.CLIENT_SECRET
    let AUTH_ENDPOINT = OAuth2Handler.AUTH_ENDPOINT
    let TOKEN_ENDPOINT = OAuth2Handler.TOKEN_ENDPOINT
    let CALLBACK_URL = OAuth2Handler.CALLBACK_URL
    
    var oauthHandle: OAuthSwiftRequestHandle?
    private var completion: (_ username: String, _ error: Error?) -> ()
    
    // Dependencies
    private var authHandler: OAuth2Handler?
    private var dataManager: DataManagerProtocol?
    
    required init(authHandler: OAuth2Handler, dataManager: DataManagerProtocol) {
        self.authHandler = authHandler
        self.dataManager = dataManager
        self.completion = { _, _ in}
    }

    func presentLogin(rootViewController: UIViewController, completion: @escaping (_ username: String, Error?) -> ()) {
        self.useOauthSwift(rootViewController: rootViewController)
    }
    
    
    private func useOauthSwift(rootViewController: UIViewController) {
        let oauth = OAuth2Swift(consumerKey: self.CLIENT_ID,
                                consumerSecret: self.CLIENT_SECRET,
                                authorizeUrl: self.AUTH_ENDPOINT,
                                accessTokenUrl: self.TOKEN_ENDPOINT,
                                responseType: "code")
        
        let safariHandler = SafariURLHandler(viewController: rootViewController, oauthSwift: oauth)
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
                                            
        }) { [weak self] (error) in
            print ("Failed Authentication!")
            print(error.localizedDescription)
            
            self?.completion("", error)
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
}
