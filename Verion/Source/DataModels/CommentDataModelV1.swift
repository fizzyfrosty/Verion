//
//  CommentDataModelV1.swift
//  Verion
//
//  Created by Simon Chen on 12/24/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class CommentDataModelV1: CommentDataModelProtocol {
    var apiVersion: APIVersion = .v1
    var id: Int64 = 0
    var parentId: Int64 = 0
    var submissionId: Int64 = 0
    
    var childCount = 0
    var content = ""
    var formattedContent = ""
    var creationDateString = ""
    var lastEditDateString = ""
    
    var isAnonymized = false
    var isCollapsed = false
    var isDeleted = false
    var isSaved = false
    var isSubmitter = false
    var isDistinguished = false
    var isOwner = false
    
    var subverseName = ""
    var username = ""
    var vote = ""
    var upvoteCount = 0
    var downvoteCount = 0
    var voteCountTotal = 0
    
    var hasMore = false
    var endingIndex = 0
    var remainingChildrenCount = 0
    
    var children: [CommentDataModelV1] = []
    
}
