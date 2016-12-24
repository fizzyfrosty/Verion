//
//  SubverseSearchResultDataModelV1.swift
//  Verion
//
//  Created by Simon Chen on 12/24/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubverseSearchResultDataModelV1: SubverseSearchResultDataModelProtocol {
    var apiVersion = APIVersion.v1
    
    var createdByUsername = ""
    var creationDateString = ""
    var description = ""
    var name = ""
    var sidebarDescription = ""
    var formattedSidebarDescription = ""
    var title = "" // usually has a /v/ prepended
    var type = ""
    var isAnonymized = false
    var isAdult = false
    
}
