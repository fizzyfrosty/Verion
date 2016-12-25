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
    var isMinimized = false
    
    var children: [CommentCellViewModelInitData] = []
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
    
    var children: [CommentCellViewModel] = []
    
    // Cell Height
    let CELL_VERTICAL_MARGINS: CGFloat = 55.0
    private let CELL_HORIZONTAL_MARGINS: CGFloat = 40.0
    private let CELL_MAX_HEIGHT: CGFloat = 9999.0
    private let CELL_MINIMIZED_HEIGHT: CGFloat = 30.0
    
    var numOfVisibleChildren: Int {
        get {
            // Count each child, and for each child of theirs, go into and count if visible
            var numOfChildren = 0
            
            for child in self.children {
                numOfChildren += 1
                
                if child.isMinimized.value == false {
                    numOfChildren += child.numOfVisibleChildren
                }
            }
            
            return numOfChildren
        }
    }
    
    var textHeight: CGFloat {
        get {
            let width: CGFloat = UIScreen.main.bounds.size.width - self.CELL_HORIZONTAL_MARGINS
            let textSize = CellHeightCalculator.sizeForAttributedText(text: self.attributedTextString, maxSize: CGSize(width: width, height: self.CELL_MAX_HEIGHT))
            
            return textSize.height
        }
    }
    var cellHeight: CGFloat{
        get {
            
            guard self.isMinimized.value != true else {
                return self.CELL_MINIMIZED_HEIGHT
            }
            
            let textHeight = self.textHeight
            
            let height = textHeight + self.CELL_VERTICAL_MARGINS
            
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
        self.isMinimized.value = initData.isMinimized
        
        // Load children
        for childInitData in initData.children {
            let viewModel = CommentCellViewModel()
            viewModel.loadInitData(initData: childInitData)
            self.children.append(viewModel)
        }
        
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
