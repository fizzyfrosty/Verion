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
    private let ACCESS_TOKEN_KEY = "verion_access_token"
    private let REFRESH_TOKEN_KEY = "verion_refresh_token"
    
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
                print("Saved username to Keychain: " + username)
            #endif
        } else {
            #if DEBUG
                print("Failed to save username to Keychain: " + username)
            #endif
        }
    }
    
    func saveAccessTokenToKeychain(accessToken: String) {
        let isSaveSuccessful = KeychainWrapper.standard.set(accessToken, forKey: self.ACCESS_TOKEN_KEY)
        
        if isSaveSuccessful {
            #if DEBUG
                print("Saved access token to Keychain")
            #endif
        } else {
            #if DEBUG
                print("Failed to save access token to Keychain")
            #endif
        }
    }
    
    func saveRefreshTokenToKeychain(refreshToken: String) {
        let isSaveSuccessful = KeychainWrapper.standard.set(refreshToken, forKey: self.REFRESH_TOKEN_KEY)
        
        if isSaveSuccessful {
            #if DEBUG
                print("Saved refresh token to Keychain")
            #endif
        } else {
            #if DEBUG
                print("Failed to save refresh token to Keychain")
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
    
    func getAccessTokenFromKeychain() -> String {
        var accessToken = KeychainWrapper.standard.string(forKey: self.ACCESS_TOKEN_KEY)
        
        if accessToken == nil {
            accessToken = ""
        }
        
        return accessToken!
    }
    
    func getRefreshTokenFromKeychain() -> String {
        var refreshToken = KeychainWrapper.standard.string(forKey: self.REFRESH_TOKEN_KEY)
        
        if refreshToken == nil {
            refreshToken = ""
        }
        
        return refreshToken!
    }
}
