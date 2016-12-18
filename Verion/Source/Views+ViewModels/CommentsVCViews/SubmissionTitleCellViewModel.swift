//
//  SubmissionTitleCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

struct SubmissionTitleCellViewModelInitData {
    var titleString = ""
    var voteTotalCount: Int = 0
    var upvoteCount: Int = 0
    var downvoteCount: Int = 0
    var usernameString = ""
    var date = Date()
    var subverseString = ""
}


class SubmissionTitleCellViewModel {
    private var textFormatter = SubmissionTextFormatter()
    
    private(set) var titleString = ""
    private(set) var voteCountTotal = Observable<Int>(0)
    private(set) var upvoteCount = Observable<Int>(0)
    private(set) var downvoteCount = Observable<Int>(0)
    private(set) var voteSeparatedCountString = Observable<String>("")
    private(set) var usernameString = ""

    private(set) var date: Date?
    private(set) var subverseString = ""
    
    // Additional variables connected to the cell to be calculated
    private(set) var dateString = "" // eg: 9 hours ago
    private(set) var timeAndSubverseString = NSMutableAttributedString()
    
    // Cell Height
    var cellHeight: CGFloat {
        set {
            self.cellHeight = newValue
        }
        get {
            return self.getCellHeight(titleString: self.titleString)
        }
    }
    
    let CELL_TITLE_FONT_NAME = "AmericanTypewriter-Semibold"
    let CELL_TITLE_FONT_SIZE: CGFloat = 14.0
    let TITLE_MARGINS: CGFloat = 16.0
    let MAX_CELL_HEIGHT: CGFloat = 999.0
    let CELL_VERTICAL_OFFSET: CGFloat = 30.0 // Represents everything vertically that isn't the title.
    
    init() {
        self.loadInitData(subTitleCellVMInitData: SubmissionTitleCellViewModelInitData())
        self.setupInternalBindings()
    }
    
    init(subTitleCellVMInitData: SubmissionTitleCellViewModelInitData) {
        self.loadInitData(subTitleCellVMInitData: subTitleCellVMInitData)
        self.setupInternalBindings()
    }
    
    func loadInitData(subTitleCellVMInitData: SubmissionTitleCellViewModelInitData){
        
        self.titleString = subTitleCellVMInitData.titleString
        self.voteCountTotal.value = subTitleCellVMInitData.voteTotalCount
        self.upvoteCount.value = subTitleCellVMInitData.upvoteCount
        self.downvoteCount.value = subTitleCellVMInitData.downvoteCount
        self.usernameString = subTitleCellVMInitData.usernameString
        self.date = subTitleCellVMInitData.date
        self.subverseString = subTitleCellVMInitData.subverseString
        
        // TODO: calculate date string
        self.dateString = self.textFormatter.createDateSubmittedString(gmtDate: self.date!)
        self.timeAndSubverseString = self.textFormatter.createSubmittedToSubverseString(dateSubmittedString: self.dateString, subverseName: self.subverseString)
        
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
    
    // Vote Count Separated String
    private func createVoteCountSeparatedString(upvoteCount: Int, downvoteCount: Int) -> String {
        
        // Should appear to be (+1|-5)
        return "(+\(upvoteCount)|-\(downvoteCount))"
    }
    
    private func getCellHeight(titleString: String) -> CGFloat {
        
        let titleWidth = UIScreen.main.bounds.width - self.TITLE_MARGINS
        
        let titleSize = CellHeightCalculator.sizeForText(text: titleString, font: UIFont.init(name: self.CELL_TITLE_FONT_NAME, size: self.CELL_TITLE_FONT_SIZE)!, maxSize: CGSize(width: titleWidth, height: self.MAX_CELL_HEIGHT))
        
        let cellHeight = titleSize.height + self.CELL_VERTICAL_OFFSET
        
        return cellHeight
    }
    
}
