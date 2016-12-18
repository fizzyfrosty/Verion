//
//  CommentCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

struct CommentCellViewModelInitData {
    var dateString = ""
    var date: Date = Date()
    
    var voteCountTotal = 0
    var upvoteCount = 0
    var downvoteCount = 0
    
    var usernameString = ""
}

class CommentCellViewModel {

    var dateString = ""
    var date: Date?
    
    var voteCountTotal = Observable<Int>(0)
    var upvoteCount = Observable<Int>(0)
    var downvoteCount = Observable<Int>(0)
    
    var usernameString = ""
    
    
}
