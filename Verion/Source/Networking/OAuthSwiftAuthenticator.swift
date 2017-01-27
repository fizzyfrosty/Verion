//
//  OAuthSwiftAuthenticator.swift
//  Verion
//
//  Created by Simon Chen on 1/27/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

class OAuthSwiftAuthenticator: LoginScreenProtocol {
    var authHandler: OAuth2Handler?
    
    required init(authHandler: OAuth2Handler) {
        self.authHandler = authHandler
    }

    func presentLogin(rootViewController: UIViewController, completion: @escaping (String, Error?) -> ()) {
        
    }
}
