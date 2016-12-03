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
    var thumbnailString: String = "(sample.com)"
    var thumbnailLink: String = "(http://www.sample.com/abc.jpg)"
    var commentCount: Int = 0
    var voteCountTotal: Int = 0
    var upvoteCount: Int = 0
    var downvoteCount: Int = 0
    var username: String = "SampleUsername"
    var subverseName: String = "/v/SampleSubverse"
}

class SubmissionCellViewModel{
    
    // Variables for binding to UI
    private(set) var thumbnailString: String = ""
    var thumbnailLink = Observable<String>("")
    private(set) var titleString: String = ""

    var voteCountTotal = Observable<Int>(0)
    private(set) var voteSeparatedCountString = Observable<String>("")
    
    private(set) var didUpvote = Observable<Bool>(false)
    private(set) var didDownvote = Observable<Bool>(false)
    
    var commentCount = 0
    
    private(set) var submittedByString: String = ""
    private(set) var submittedToSubverseString: String = ""
    
    // Variables - additional
    var upvoteCount = Observable<Int>(0)
    var downvoteCount = Observable<Int>(0)
    private(set) var username: String = ""
    private(set) var subverseName: String = ""
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
        self.thumbnailString = subCellVmInitData.thumbnailString
        self.thumbnailLink.value = subCellVmInitData.thumbnailLink
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
