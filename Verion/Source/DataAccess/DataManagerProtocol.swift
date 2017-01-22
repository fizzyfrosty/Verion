//
//  DataManagerProtocol.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol DataManagerProtocol: class {
    func getSavedData()->VerionDataModel
    func saveData(dataModel: VerionDataModel)
    
    func saveUsernameToKeychain(username: String)
    func savePasswordToKeychain(password: String)
    func getUsernameFromKeychain() -> String
    func getPasswordFromKeychain() -> String
}
