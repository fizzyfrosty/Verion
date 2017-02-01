//
//  LoginScreenProtocol.swift
//  Verion
//
//  Created by Simon Chen on 1/27/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol LoginScreenProtocol: class {
    
    init(authHandler: OAuth2Handler, dataManager: DataManagerProtocol)
    func presentLogin(rootViewController: UIViewController, showConfirmation: Bool, completion: @escaping (_ username: String, _ error: Error? ) ->())
}
