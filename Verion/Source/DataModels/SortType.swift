//
//  SortType.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import Foundation

enum SortTypeComments: String {
    case new = "New"
    case top = "Top"
    
    static let allValues = [new, top]
}

enum SortTypeSubmissions: String {
    case hot = "Hot"
    case top = "Top"
    case new = "New"
    
    static let allValues = [hot, top, new]
}
