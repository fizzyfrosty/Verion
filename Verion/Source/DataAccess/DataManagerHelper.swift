//
//  DataManagerHelper.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class DataManagerHelper: NSObject {

    func getStorageDirectory(withFilename fileName: String, ext: String) -> String {
        let storageDirectoryUrl = self.getStorageDirectoryUrl()
        let fileDirectoryUrl = storageDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension(ext)
        
        return fileDirectoryUrl.path
    }
    
    func getStorageDirectoryUrl() -> URL {
        var defaultDirectory = URL.init(string: "")
        do {
            try defaultDirectory = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        return defaultDirectory!
    }
}
