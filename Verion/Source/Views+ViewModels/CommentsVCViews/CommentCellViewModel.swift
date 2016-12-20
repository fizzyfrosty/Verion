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
    var date: Date = Date()
    
    var voteCountTotal = 0
    var upvoteCount = 0
    var downvoteCount = 0
    
    var usernameString = ""
    var textString = ""
}

class CommentCellViewModel {

    private(set) var dateString = ""
    private(set) var date: Date?
    
    private(set) var voteCountTotal = Observable<Int>(0)
    private(set) var upvoteCount = Observable<Int>(0)
    private(set) var downvoteCount = Observable<Int>(0)
    
    private(set) var usernameString = ""
    private(set) var textString = ""
    private(set) var attributedTextString = NSAttributedString()
    
    var separatedVoteCountString = Observable<String>("")
    var textFormatter = SubmissionTextFormatter()
    
    // Cell Height
    private let CELL_VERTICAL_MARGINS: CGFloat = 65.0
    private let CELL_HORIZONTAL_MARGINS: CGFloat = 25.0
    private let CELL_MAX_HEIGHT: CGFloat = 9999.0
    private let CELL_MINIMIZED_HEIGHT: CGFloat = 30.0
    var cellHeight: CGFloat{
        get {
            
            guard self.isMinimized.value != true else {
                return self.CELL_MINIMIZED_HEIGHT
            }
            
            let width: CGFloat = UIScreen.main.bounds.size.width - self.CELL_HORIZONTAL_MARGINS
            let textSize = CellHeightCalculator.sizeForAttributedText(text: self.attributedTextString, maxSize: CGSize(width: width, height: self.CELL_MAX_HEIGHT))
            
            let height = textSize.height + self.CELL_VERTICAL_MARGINS
            
            return height
        }
    }
    
    // Minimized/Maximized
    var isMinimized = Observable<Bool>(false)
    
    init() {
        let initData = CommentCellViewModelInitData()
        self.loadInitData(initData: initData)
    }
    
    
    func loadInitData(initData: CommentCellViewModelInitData) {
        self.date = initData.date
        self.voteCountTotal.value = initData.voteCountTotal
        self.upvoteCount.value = initData.upvoteCount
        self.downvoteCount.value = initData.downvoteCount
        self.usernameString = initData.usernameString
        self.textString = initData.textString
        self.attributedTextString = MarkdownParser.attributedString(fromMarkdownString: self.textString)
        
        self.separatedVoteCountString.value = self.textFormatter.createVoteCountSeparatedString(upvoteCount: self.upvoteCount.value, downvoteCount: self.downvoteCount.value)
        self.dateString = self.textFormatter.createDateSubmittedString(gmtDate: self.date!) + " ago"
        
        // Bindings
        _ = self.upvoteCount.observeNext() { [weak self] upvoteCount in
            self?.separatedVoteCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount.value)!, downvoteCount: (self?.downvoteCount.value)!))!
            
            
            self?.voteCountTotal.value = (self?.getVoteCountTotal(upvoteCount: (self?.upvoteCount.value)!, downvoteCount: (self?.downvoteCount.value)!))!
        }
        
        _ = self.downvoteCount.observeNext() { [weak self] downvoteCount in
            self?.separatedVoteCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount.value)!, downvoteCount: (self?.downvoteCount.value)!))!
            
            self?.voteCountTotal.value = (self?.getVoteCountTotal(upvoteCount: (self?.upvoteCount.value)!, downvoteCount: (self?.downvoteCount.value)!))!
        }
    }
    
    func toggleMinimized() {
        self.isMinimized.value = !self.isMinimized.value
    }
    
    private func getVoteCountTotal( upvoteCount: Int, downvoteCount: Int) -> Int {
        return upvoteCount - downvoteCount
    }
}
