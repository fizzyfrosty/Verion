//
//  CommentDataModelLegacy.swift
//  Verion
//
//  Created by Simon Chen on 12/18/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class CommentDataModelLegacy: CommentDataModelProtocol {
    var apiVersion: APIVersion = .legacy
    
    var id: Int64 = 0
    var dateString = ""
    var upvoteCount: Int = 0
    var downvoteCount: Int = 0
    var commentContent = ""
    var parentId: Int64 = 0
    var messageId: Int64 = 0
    var username = ""
}
