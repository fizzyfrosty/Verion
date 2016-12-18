//
//  SubmissionDataModel.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionDataModelLegacy: SubmissionDataModelProtocol {
    
    var apiVersion: APIVersion = APIVersion.legacy
    var id: Int64 = 0
    
    var commentCount = 0
    var dateString = ""
    var lastEditDateString = ""
    
    var downvoteCount = 0
    var upvoteCount = 0
    var voteCount = 0
    
    
    
    var linkDescription = ""
    var messageContent = ""
    var username = ""
    
    var rank: Double = 0
    var subverseName = ""
    var thumbnailLink = ""
    
    var title = ""
    var type = 0
    
}
