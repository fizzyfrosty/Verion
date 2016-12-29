//
//  SubmissionsRequestParams.swift
//  Verion
//
//  Created by Simon Chen on 12/27/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

enum TopSortTypeTime: Int {
    case day = 2
    case week = 3
    case month = 4
    case year = 6
    case all = 0
}

struct SubmissionsRequestParams{
    var subverseName = ""
    var page: Int = 0
    var sortType: SortTypeSubmissions = .hot
    var topSortTypeTime: TopSortTypeTime = .all
    
    init(subverse: String, page: Int, sortType: SortTypeSubmissions, topSortTypeTime: TopSortTypeTime) {
        self.subverseName = subverse
        self.page = page
        self.sortType = sortType
        self.topSortTypeTime = topSortTypeTime
    }
    
    init() {
        
    }
}
