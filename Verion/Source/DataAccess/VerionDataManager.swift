//
//  VerionDataManager.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class VerionDataManager: DataManagerProtocol {
    let FILE_NAME = "1"
    let EXTENSION_NAME = ".verionData"
    let dataManagerHelper = DataManagerHelper()
    
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
        
    }
    
    func savePasswordToKeychain(password: String) {
        <#code#>
    }
}
