//
//  VerionDataModel.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class VerionDataModel: NSObject, NSCoding {
    
    struct Keys {
        static let subversesVisited = "subverses_visted"
    }
    
    var subversesVisited: [String] = []
    
    override init() {
        
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.subversesVisited = aDecoder.decodeObject(forKey: Keys.subversesVisited) as! [String]
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.subversesVisited, forKey: Keys.subversesVisited)
    }
    
    
}
