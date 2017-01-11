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
        static let shouldHideNsfw = "should_hide_nsfw"
        static let shouldUseNsfwThumbnails = "should_use_nsfw_thumbs"
        static let shouldFilterLanguage = "should_filter_language"
        static let versionNumber = "version_number"
        static let blockedUsers = "blocked_users"
    }
    
    var subversesVisited: [String]?
    var sortType: SortTypeSubmissions?
    var isRemoveAdsPurchased: Bool = false
    var shouldHideNsfw = true
    var shouldUseNsfwThumbnail = true
    var shouldFilterLanguage = true
    var versionNumber: Float = 1.0
    var blockedUsers: Set<String> = []
    
    override init() {
        self.subversesVisited = []
        self.sortType = .hot
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.versionNumber = aDecoder.decodeFloat(forKey: Keys.versionNumber)
        
        // Version 1.0
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
        
        self.shouldHideNsfw = aDecoder.decodeBool(forKey: Keys.shouldHideNsfw)
        self.shouldUseNsfwThumbnail = aDecoder.decodeBool(forKey: Keys.shouldUseNsfwThumbnails)
        self.shouldFilterLanguage = aDecoder.decodeBool(forKey: Keys.shouldFilterLanguage)
        
        self.blockedUsers = aDecoder.decodeObject(forKey: Keys.blockedUsers) as! Set<String>
        
        // Version 1.01
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.versionNumber, forKey: Keys.versionNumber)
        aCoder.encode(self.subversesVisited, forKey: Keys.subversesVisited)
        aCoder.encode(self.sortType?.rawValue, forKey: Keys.sortType)
        aCoder.encode(self.isRemoveAdsPurchased, forKey: Keys.isRemoveAdsPurchased)
        
        aCoder.encode(self.shouldHideNsfw, forKey: Keys.shouldHideNsfw)
        aCoder.encode(self.shouldUseNsfwThumbnail, forKey: Keys.shouldUseNsfwThumbnails)
        aCoder.encode(self.shouldFilterLanguage, forKey: Keys.shouldFilterLanguage)
        
        aCoder.encode(self.blockedUsers, forKey: Keys.blockedUsers)
    }
    
    
}
