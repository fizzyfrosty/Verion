//
//  SubverseSearchResultDataModelLegacy.swift
//  Verion
//
//  Created by Simon Chen on 12/17/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubverseSearchResultDataModelLegacy: SubverseSearchResultDataModelProtocol {
    var apiVersion = APIVersion.legacy
    
    var subverseName = ""
    var subverseDescription = ""
    var subscriberCount: Int = 0
}
