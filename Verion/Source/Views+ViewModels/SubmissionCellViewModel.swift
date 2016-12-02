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
    var thumbnailString: String = ""
    var titleString: String = ""

    var voteCountTotal = Observable<Int>(0)
    var voteSeparatedCountString = Observable<String>("")
    
    var didUpvote = Observable<Bool>(false)
    var didDownvote = Observable<Bool>(false)
    
    var commentCount = 0
    
    var submittedByString: String = ""
    var submittedToSubverseString: String = ""
    
    // Variables - additional
    var upvoteCount = Observable<Int>(0)
    var downvoteCount = Observable<Int>(0)
    var username: String = ""
    var subverseName: String = ""
    //let date: NSDate?
    
    
    // Lazy initialization
    init() {
        self.initializeBindings()
        self.loadInitData(subCellVmInitData: SubmissionCellViewModelInitData())
    }
    
    // Custom initialization
    init(subCellVmInitData: SubmissionCellViewModelInitData) {
        self.initializeBindings()
        self.loadInitData(subCellVmInitData: subCellVmInitData)
    }
    
    
    func loadInitData(subCellVmInitData: SubmissionCellViewModelInitData) {
        self.titleString = subCellVmInitData.titleString
        self.thumbnailString = subCellVmInitData.thumnailString
        self.commentCount = subCellVmInitData.commentCount
        self.voteCountTotal.value = subCellVmInitData.voteCountTotal
        self.upvoteCount.value = subCellVmInitData.upvoteCount
        self.downvoteCount.value = subCellVmInitData.downvoteCount
        self.username = subCellVmInitData.username
        self.subverseName = subCellVmInitData.subverseName
        
        
        self.submittedByString = self.createSubmittedByUsernameString(username: self.username)
        
        // TODO: Add date to format
        self.submittedToSubverseString = self.createSubmittedToSubverseString(subverseName: self.subverseName)
    }
    
    private func initializeBindings() {
        // Bindings for upvotes and downvotes to update votecount separated string
        _ = self.upvoteCount.observeNext { _ in
            self.voteSeparatedCountString.value = self.createVoteCountSeparatedString(upvoteCount: self.upvoteCount.value, downvoteCount: self.downvoteCount.value)
        }
        
        _ = self.downvoteCount.observeNext { _ in
            self.voteSeparatedCountString.value = self.createVoteCountSeparatedString(upvoteCount: self.upvoteCount.value, downvoteCount: self.downvoteCount.value)
        }
    }
    
    // Submitted by username string
    private func createSubmittedByUsernameString(username: String?) -> String {
        return "submitted by \(username)"
    }
    
    // Submitted to subverse string
    private func createSubmittedToSubverseString(subverseName: String?) -> String {
        return "to \(subverseName)"
    }
    
    // Vote Count Separated String
    private func createVoteCountSeparatedString(upvoteCount: Int, downvoteCount: Int) -> String {
        
        // Should appear to be (+1|-5)
        return "(+\(upvoteCount)|-\(downvoteCount))"
    }
    
}
