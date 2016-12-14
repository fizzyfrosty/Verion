//
//  SubmissionTitleCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

struct SubmissionTitleCellViewModelInitData {
    var titleString = ""
    var voteTotalCount: Int = 0
    var upvoteCount: Int = 0
    var downvoteCount: Int = 0
    var usernameString = ""
    var date: Date?
    var subverseString = ""
}


class SubmissionTitleCellViewModel {
    
    private var titleString = ""
    private var voteCountTotal: Int = 0
    private var upvoteCount: Int = 0
    private var downvoteCount: Int = 0
    private var usernameString = ""

    private var date: Date?
    private var subverseString = ""
    
    // Additional variables connected to the cell to be calculated
    private var dateString = "" // eg: 9 hours ago
    private(set) var timeAndSubverseString = ""
    
    init() {
        self.loadInitData(subTitleCellVMInitData: SubmissionTitleCellViewModelInitData())
    }
    
    init(subTitleCellVMInitData: SubmissionTitleCellViewModelInitData) {
        self.loadInitData(subTitleCellVMInitData: subTitleCellVMInitData)
    }
    
    func loadInitData(subTitleCellVMInitData: SubmissionTitleCellViewModelInitData){
        
        self.titleString = subTitleCellVMInitData.titleString
        self.voteCountTotal = subTitleCellVMInitData.voteTotalCount
        self.upvoteCount = subTitleCellVMInitData.upvoteCount
        self.downvoteCount = subTitleCellVMInitData.downvoteCount
        self.usernameString = subTitleCellVMInitData.usernameString
        self.date = subTitleCellVMInitData.date
        self.subverseString = subTitleCellVMInitData.subverseString
        
        // TODO: calculate date string
        self.dateString = ""
        self.timeAndSubverseString = ""
        
    }
    
}
