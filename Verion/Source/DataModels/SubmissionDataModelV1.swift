//
//  SubmissionDataModelV1.swift
//  Verion
//
//  Created by Simon Chen on 12/24/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionDataModelV1: SubmissionDataModelProtocol {
    var apiVersion: APIVersion = APIVersion.v1
    var id: Int64 = 0
    
    var subverseName = ""
    var type = "" // "Link" or "Text"
    var username = ""
    
    var title = ""
    var url = ""
    var thumbnailUrl = ""
    var content = ""
    var formattedContent = ""
    
    var commentCount = 0
    var creationDateString = ""
    var lastEditDateString = ""
    
    var isAnonymized = false
    var isDeleted = false
    
    var views: UInt = 0
    var vote = ""
    
    var upvoteCount = 0
    var downvoteCount = 0
    var voteCountTotal = 0
}
