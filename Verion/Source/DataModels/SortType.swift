//
//  SortType.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import Foundation

enum SortTypeComments: String {
    case top = "Top"
    case new = "New"
    
    static let allValues = [top, new]
}

enum SortTypeSubmissions: String {
    case hot = "Hot"
    case top = "Top"
    case new = "New"
    
    static let allValues = [new, top, hot]
}
