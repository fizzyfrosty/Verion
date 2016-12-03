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
    var commentCount: Int = 123
    var voteCountTotal: Int = 4331
    var upvoteCount: Int = 211
    var downvoteCount: Int = 154
    var username: String = "SampleUsername"
    var subverseName: String = "SampleSubverse"
}

class SubmissionCellViewModel{
    
    private let USERNAME_LABEL_FONT_SIZE: CGFloat = 12
    
    
    // Variables for binding to UI
    private(set) var thumbnailString: String = ""
    var thumbnailLink = Observable<String>("")
    private(set) var titleString: String = ""

    var voteCountTotal = Observable<Int>(0)
    private(set) var voteSeparatedCountString = Observable<String>("")
    
    private(set) var didUpvote = Observable<Bool>(false)
    private(set) var didDownvote = Observable<Bool>(false)
    
    var commentCount = 0
    
    private(set) var submittedByString = NSMutableAttributedString()
    private(set) var submittedToSubverseString = NSMutableAttributedString()
    
    // Variables - additional
    var upvoteCount = Observable<Int>(0)
    var downvoteCount = Observable<Int>(0)
    private(set) var username: String = ""
    private(set) var subverseName: String = ""
    //let date: NSDate?
    
    
    // Lazy initialization
    init() {
        self.setupInternalBindings()
        self.loadInitData(subCellVmInitData: SubmissionCellViewModelInitData())
    }
    
    // Custom initialization
    init(subCellVmInitData: SubmissionCellViewModelInitData) {
        self.setupInternalBindings()
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
    
    private func setupInternalBindings() {
        // Bindings for upvotes and downvotes to update votecount separated string and total vote count
        _ = self.upvoteCount.observeNext { _ in
            self.voteCountTotal.value = self.upvoteCount.value - self.downvoteCount.value
            
            self.voteSeparatedCountString.value = self.createVoteCountSeparatedString(upvoteCount: self.upvoteCount.value, downvoteCount: self.downvoteCount.value)
        }
        
        _ = self.downvoteCount.observeNext { _ in
            self.voteCountTotal.value = self.upvoteCount.value - self.downvoteCount.value
            
            self.voteSeparatedCountString.value = self.createVoteCountSeparatedString(upvoteCount: self.upvoteCount.value, downvoteCount: self.downvoteCount.value)
        }
    }
    
    // "by username" string
    private func createSubmittedByUsernameString(username: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString()
        _ = attrString.normal(text: "by ").bold(text: username, fontSize: self.USERNAME_LABEL_FONT_SIZE)
        return attrString
    }
    
    // "to subverse" string
    private func createSubmittedToSubverseString(subverseName: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString()
        _ = attrString.normal(text: "to /v/\(subverseName)")
        return attrString
    }
    
    // Vote Count Separated String
    private func createVoteCountSeparatedString(upvoteCount: Int, downvoteCount: Int) -> String {
        
        // Should appear to be (+1|-5)
        return "(+\(upvoteCount)|-\(downvoteCount))"
    }
    
}
