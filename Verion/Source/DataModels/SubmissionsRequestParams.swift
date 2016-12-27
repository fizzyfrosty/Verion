//
//  SubmissionsRequestParams.swift
//  Verion
//
//  Created by Simon Chen on 12/27/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

enum TopSortTypeTime {
    case day
    case week
    case month
    case year
    case all
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
