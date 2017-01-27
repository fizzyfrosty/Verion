//
//  LoginScreenProtocol.swift
//  Verion
//
//  Created by Simon Chen on 1/27/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol LoginScreenProtocol: class {

    var authHandler: OAuth2Handler? {get set}
    
    init(authHandler: OAuth2Handler)
    func presentLogin(rootViewController: UIViewController, completion: @escaping (_ username: String, _ error: Error? ) ->())
}
