//
//  VerionDataManager.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class VerionDataManager: DataManagerProtocol {
    private let FILE_NAME = "1"
    private let EXTENSION_NAME = ".verionData"
    private let dataManagerHelper = DataManagerHelper()
    private let USERNAME_KEY = "verion_username"
    private let PASSWORD_KEY = "verion_password"
    
    func getSavedData() -> VerionDataModel {
        let filename = self.getSaveFilepath()
        var dataModel = NSKeyedUnarchiver.unarchiveObject(withFile: filename) as? VerionDataModel
        if dataModel == nil {
            dataModel = VerionDataModel()
        }
        return dataModel!
    }
    
    func saveData(dataModel: VerionDataModel) {
        let filename = self.getSaveFilepath()
        NSKeyedArchiver.archiveRootObject(dataModel, toFile: filename)
        
        #if DEBUG
        print("Saved data to: " + filename)
        #endif
    }
    
    private func getSaveFilepath() -> String {
        let filename = self.dataManagerHelper.getStorageDirectory(withFilename: self.FILE_NAME, ext: self.EXTENSION_NAME)
        
        return filename
    }
    
    func saveUsernameToKeychain(username: String) {
        let isSaveSuccessful = KeychainWrapper.standard.set(username, forKey: self.USERNAME_KEY)
        
        if isSaveSuccessful {
            #if DEBUG
                print("Saved to Keychain username: " + username)
            #endif
        } else {
            #if DEBUG
                print("Failed to save to Keychain username: " + username)
            #endif
        }
    }
    
    func savePasswordToKeychain(password: String) {
        let isSaveSuccessful = KeychainWrapper.standard.set(password, forKey: self.PASSWORD_KEY)
        
        if isSaveSuccessful {
            #if DEBUG
                print("Saved password to Keychain")
            #endif
        } else {
            #if DEBUG
                print("Failed to save password to Keychain")
            #endif
        }
    }
    
    func getUsernameFromKeychain() -> String {
        var username = KeychainWrapper.standard.string(forKey: self.USERNAME_KEY)
        
        if username == nil {
            username = ""
        }
        
        return username!
    }
    
    func getPasswordFromKeychain() -> String {
        var password = KeychainWrapper.standard.string(forKey: self.PASSWORD_KEY)
        
        if password == nil {
            password = ""
        }
        
        return password!
    }
}
