
//
//  DataProviderType.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

/*
 
 # Overview
 
 This protocol should mirror the Voat API. 
 Implementations will mirror each version of the API. 
 Each version, v1, v2, will have its own class. 
 
 */

import UIKit

protocol DataProviderType {
    
    func requestSubverseSubmissions(completion:([SubmissionDataModelType])->Void) -> Void
    
}
