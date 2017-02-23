//
//  OAuth2Handler.swift
//  Verion
//
//  Created by Simon Chen on 1/22/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit
import Alamofire
import SwinjectStoryboard

class OAuth2Handler: RequestAdapter, RequestRetrier {
    static let CLIENT_ID = "VO0FEEE221244B41B7B3686098AA4EA227AT"
    static let CLIENT_SECRET = "F80C9D5D732048E0B0928FCA8F71DA5AB8170FE1451B4967BD738D5F47C7CEC0"
    static let AUTH_ENDPOINT = "https://api.voat.co/oauth/authorize"
    static let TOKEN_ENDPOINT = "https://api.voat.co/oauth/token"
    static let CALLBACK_URL = "voatify://oauth-callback-url"
    static let BASE_URL_STRING = "https://api.voat.co"
    static let REGISTER_URL_STRING = "https://voat.co/account/register"
    
    static let sharedInstance: OAuth2Handler = {
        
        let dataManager = VerionDataManager()
        let accessToken = dataManager.getAccessTokenFromKeychain()
        let refreshToken = dataManager.getRefreshTokenFromKeychain()
        
        let instance = OAuth2Handler.init(clientID: OAuth2Handler.CLIENT_ID, baseURLString: OAuth2Handler.BASE_URL_STRING, accessToken: accessToken, refreshToken: refreshToken)
        
        return instance
    }()
    
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    var clientID: String
    var baseURLString: String
    var accessToken: String
    var refreshToken: String
        
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init(clientID: String, baseURLString: String, accessToken: String, refreshToken: String) {
        self.clientID = clientID
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            urlRequest.setValue(OAuth2Handler.CLIENT_ID, forHTTPHeaderField: "Voat-ApiKey")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            #if DEBUG
            print("AccessToken failed or expired. Response Status Code: \(response.statusCode)")
            #endif
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    func refreshTokensManually() {
        #if DEBUG
        print("Initiating manual token refresh.")
        #endif
        self.refreshTokens { (succeeded, accessToken, refreshToken) in
        }
    }
    
    // MARK: - Private - Refresh Tokens
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let urlString = OAuth2Handler.TOKEN_ENDPOINT
        
        let parameters: [String: Any] = [
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "client_id": clientID,
            "client_secret": OAuth2Handler.CLIENT_SECRET,
            "grant_type": "refresh_token"
        ]
        
        #if DEBUG
            print("Refreshing token...")
        #endif
        
        sessionManager.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                if
                    let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String,
                    let username = json["userName"] as? String
                {
                #if DEBUG
                    print("Token Refresh Successful!")
                #endif
                    
                    self?.saveData(username: username, accessToken: accessToken, refreshToken: refreshToken)
                
                    completion(true, accessToken, refreshToken)
                } else {
                    
                    #if DEBUG
                        print("Token Refresh Failed. Presenting Login Screen to reauthenticate.")
                    #endif
                    
                    let loginScreen: LoginScreenProtocol = SwinjectStoryboard.defaultContainer.resolve(LoginScreenProtocol.self)!
                    
                    let topViewController = UIApplication.shared.keyWindow?.rootViewController
                    
                    loginScreen.presentLogin(rootViewController: topViewController!, showConfirmation: false, completion: { (username, error) in
                        
                        guard error == nil else {
                            // Failed refresh
                            
                            completion(false, nil, nil)
                            return
                        }
                        
                        // Success
                        // Tokens should be automatically set
                        completion(true, self?.accessToken, self?.refreshToken)
                        
                    })
                }
                
                strongSelf.isRefreshing = false
        }
    }
    
    private func saveData(username: String, accessToken: String, refreshToken: String) {
        let dataManager = VerionDataManager()
        dataManager.saveUsernameToKeychain(username: username)
        dataManager.saveAccessTokenToKeychain(accessToken: accessToken)
        dataManager.saveRefreshTokenToKeychain(refreshToken: refreshToken)
    }
}
