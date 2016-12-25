//
//  SubmissionDataModelProtocol.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import Foundation

protocol SubmissionDataModelProtocol: class {
    var apiVersion: APIVersion {get}
    var id: Int64 {get}
    var subverseName: String {get}
}
