//
//  OAuthSwiftAuthenticator.swift
//  Verion
//
//  Created by Simon Chen on 1/27/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import OAuthSwift

class OAuthSwiftAuthenticator: LoginScreenProtocol {
    
    let CLIENT_ID = "VO0FEEE221244B41B7B3686098AA4EA227AT"
    let CLIENT_SECRET = "F80C9D5D732048E0B0928FCA8F71DA5AB8170FE1451B4967BD738D5F47C7CEC0"
    let AUTH_ENDPOINT = "https://api.voat.co/oauth/authorize"
    let TOKEN_ENDPOINT = "https://api.voat.co/oauth/token"
    let CALLBACK_URL = "voatify://oauth-callback-url"
    
    let AUTHORIZATION_BASIC_HEADER_VALUE = "Vk8wRkVFRTIyMTI0NEI0MUI3QjM2ODYwOThBQTRFQTIyN0FUOkY4MEM5RDVENzMyMDQ4RTBCMDky"
    
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
                                            
                                            self?.completion(username!, nil)
                                            
        }) { [weak self] (error) in
            print ("Failed Authentication!")
            print(error.localizedDescription)
            
            self?.completion("", error)
        }
    }
    
    private func getUsername(fromResponse: OAuthSwiftResponse) -> String {
        var username = "TestUsername"
        
        // FIXME: Get username from response
        
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
