//
//  SubmissionCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/1/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

struct SubmissionCellViewModelInitData {
    var titleString: String = "This is a Sample Title for a Submission"
    var thumnailString: String = "(sample.com)"
    var commentCount: Int = 0
    var voteCountTotal: Int = 0
    var upvoteCount: Int = 0
    var downvoteCount: Int = 0
    var username: String = "SampleUsername"
    var subverseName: String = "/v/SampleSubverse"
}

class SubmissionCellViewModel{
    
    // Variables for binding to UI
    let thumbnailString: String?
    let titleString: String?

    var voteCountTotal = Observable<Int>(0)
    var voteSeparatedCountString = Observable<String>("")
    
    var didUpvote = Observable<Bool>(false)
    var didDownvote = Observable<Bool>(false)
    
    var commentCount = 0
    
    var submittedByString: String?
    var submittedToSubverseString: String?
    
    // Variables - additional
    var upvoteCount = 0
    var downvoteCount = 0
    let username: String?
    let subverseName: String?
    //let date: NSDate?
    
    
    init(subCellVmInitData: SubmissionCellViewModelInitData) {
        self.titleString = subCellVmInitData.titleString
        self.thumbnailString = subCellVmInitData.thumnailString
        self.commentCount = subCellVmInitData.commentCount
        self.voteCountTotal.value = subCellVmInitData.voteCountTotal
        self.upvoteCount = subCellVmInitData.upvoteCount
        self.downvoteCount = subCellVmInitData.downvoteCount
        self.username = subCellVmInitData.username
        self.subverseName = subCellVmInitData.subverseName
        
        self.voteSeparatedCountString.value = self.createVoteCountSeparatedString(upvoteCount: self.upvoteCount, downvoteCount: self.downvoteCount)
        
        self.submittedByString = self.createSubmittedByUsernameString(username: self.username)
        
        // TODO: Add date to format
        self.submittedToSubverseString = self.createSubmittedToSubverseString(subverseName: self.subverseName)
    }
    
    // Submitted by username string
    func createSubmittedByUsernameString(username: String?) -> String {
        return "submitted by \(username)"
    }
    
    // Submitted to subverse string
    func createSubmittedToSubverseString(subverseName: String?) -> String {
        return "to \(subverseName)"
    }
    
    // Vote Count Separated String
    func createVoteCountSeparatedString(upvoteCount: Int, downvoteCount: Int) -> String {
        
        // Should appear to be (+1|-5)
        return "(+\(upvoteCount)|-\(downvoteCount))"
    }
    
    
}
