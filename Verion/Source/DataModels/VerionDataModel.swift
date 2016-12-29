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
        static let sortType = "sort_type"
        static let isRemoveAdsPurchased = "is_remove_ads_purchased"
    }
    
    var subversesVisited: [String]?
    var sortType: SortTypeSubmissions?
    var isRemoveAdsPurchased: Bool = false
    
    override init() {
        self.subversesVisited = []
        self.sortType = .hot
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.subversesVisited = aDecoder.decodeObject(forKey: Keys.subversesVisited) as? [String]
        if self.subversesVisited == nil {
            self.subversesVisited = []
        }
        
        
        let sortTypeRawValue = aDecoder.decodeObject(forKey: Keys.sortType) as? String
        if sortTypeRawValue == nil {
            self.sortType = .hot
        } else {
            for sortType in SortTypeSubmissions.allValues {
                if sortType.rawValue == sortTypeRawValue {
                    self.sortType = sortType
                    break
                }
            }
        }
        
        self.isRemoveAdsPurchased = aDecoder.decodeBool(forKey: Keys.isRemoveAdsPurchased)
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.subversesVisited, forKey: Keys.subversesVisited)
        aCoder.encode(self.sortType?.rawValue, forKey: Keys.sortType)
        aCoder.encode(self.isRemoveAdsPurchased, forKey: Keys.isRemoveAdsPurchased)
    }
    
    
}
