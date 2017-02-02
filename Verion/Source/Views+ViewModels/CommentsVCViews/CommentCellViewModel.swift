//
//  CommentCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/6/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

struct CommentCellViewModelInitData {
    var date: Date = Date()
    var id: Int64 = 0
    var parentId: Int64 = 0
    
    var voteCountTotal = 0
    var upvoteCount = 0
    var downvoteCount = 0
    
    var usernameString = ""
    var textString = ""
    var isMinimized = false
    
    var isUserOP = false
    var voteValue: VoteValue = .none
    
    var hasMoreUnloadedChildren = false
    var remainingChildrenCount = 0
    var latestChildIndex = 0
    
    var children: [CommentCellViewModelInitData] = []
}

class CommentCellViewModel {

    private(set) var dateString = ""
    private(set) var date: Date?
    private(set) var id: Int64 = 0
    private(set) var parentId: Int64 = 0
    var parentChildrenArrayIndex = 0 // for setting externally, this is the index where it resides in the parent's children array
    
    private(set) var voteCountTotal = Observable<Int>(0)
    var upvoteCount: Int {
        get {
            var upvoteCount = self._upvoteCount.value
            
            if self.voteValue.value == .up {
                // Add 1 upvote count
                upvoteCount += 1
            }
            
            return upvoteCount
        }
    }
    
    var downvoteCount: Int {
        get {
            var downvoteCount = self._downvoteCount.value
            
            if self.voteValue.value == .down {
                // Add 1 to downvote count
                downvoteCount += 1
            }
            
            return downvoteCount
        }
    }
    
    private(set) var _upvoteCount = Observable<Int>(0)
    private(set) var _downvoteCount = Observable<Int>(0)
    
    var voteValue = Observable<VoteValue>(.none)
    
    private(set) var usernameString = ""
    var textString = ""
    var attributedTextString = NSAttributedString()
    
    var separatedVoteCountString = Observable<String>("")
    var textFormatter = SubmissionTextFormatter()
    
    private(set) var children: [CommentCellViewModel] = []
    weak var parent: CommentCellViewModel?
    
    var viewBindings: [Disposable] = [] // for external use
    var dataProviderBindings: [Disposable] = []
    
    private(set) var didRequestUpvote = Observable<Bool>(false)
    private(set) var didRequestDownvote = Observable<Bool>(false)
    private(set) var didRequestNoVote = Observable<Bool>(false)
    
    private(set) var isUpvoted = Observable<Bool>(false)
    private(set) var isDownvoted = Observable<Bool>(false)
    
    // Cell Height
    let CELL_VERTICAL_MARGINS: CGFloat = 55.0
    private let CELL_HORIZONTAL_MARGINS: CGFloat = 30.0
    private let CELL_MAX_HEIGHT: CGFloat = 9999.0
    private let CELL_MINIMIZED_HEIGHT: CGFloat = 30.0
    private let BOTTOM_BUTTONS_HEIGHT: CGFloat = 35.0
    
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
            let width: CGFloat = UIScreen.main.bounds.size.width - self.CELL_HORIZONTAL_MARGINS - CGFloat(self.childDepthIndex)*self.COMMENT_CHILD_ALIGNMENTVIEWS_WIDTH
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
            
            let height = CGFloat(Int(textHeight + self.CELL_VERTICAL_MARGINS + self.BOTTOM_BUTTONS_HEIGHT))
            
            return height
        }
    }
    
    // Minimized/Maximized
    var isMinimized = Observable<Bool>(false)
    
    // Block
    var isBlocked = false
    
    // For left-right shifting to align with nested comments. Set externally
    var childDepthIndex = 0
    let COMMENT_CHILD_ALIGNMENTVIEWS_WIDTH: CGFloat = 10.0
    
    init() {
        let initData = CommentCellViewModelInitData()
        self.loadInitData(initData: initData)
    }
    
    // User
    var isUserOP = false
    
    // Loading children
    var hasMoreUnloadedChildren = false
    var isLoadMoreCell = false // for external setting
    var remainingChildrenCount = 0 // hidden children, unloaded
    var latestChildIndex = 0
    
    
    func loadInitData(initData: CommentCellViewModelInitData) {
        self.date = initData.date
        self.id = initData.id
        self.voteCountTotal.value = initData.voteCountTotal
        self._upvoteCount.value = initData.upvoteCount
        self._downvoteCount.value = initData.downvoteCount
        self.usernameString = initData.usernameString
        self.textString = initData.textString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.attributedTextString = MarkdownParser.attributedString(fromMarkdownString: self.textString)
        
        self.separatedVoteCountString.value = self.textFormatter.createVoteCountSeparatedString(upvoteCount: self.upvoteCount, downvoteCount: self.downvoteCount)
        self.dateString = self.textFormatter.createDateSubmittedString(gmtDate: self.date!) + " ago"
        self.isMinimized.value = initData.isMinimized
        self.isUserOP = initData.isUserOP
        self.hasMoreUnloadedChildren = initData.hasMoreUnloadedChildren
        self.remainingChildrenCount = initData.remainingChildrenCount
        self.latestChildIndex = initData.latestChildIndex
        self.parentId = initData.parentId
        self.voteValue.value = initData.voteValue
        
        // Load children
        for childInitData in initData.children {
            let childViewModel = CommentCellViewModel()
            childViewModel.childDepthIndex = self.childDepthIndex+1 // This must be set before its children gets initialized
            childViewModel.loadInitData(initData: childInitData)
            self.addChild(viewModel: childViewModel)
        }
        
        self.setupBindings()
    }
    
    private func setupBindings() {
        // Bindings
        _ = self._upvoteCount.observeNext() { [weak self] upvoteCount in
            
            self?.separatedVoteCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount)!, downvoteCount: (self?.downvoteCount)!))!
            
            
            self?.voteCountTotal.value = (self?.getVoteCountTotal(upvoteCount: (self?.upvoteCount)!, downvoteCount: (self?.downvoteCount)!))!
        }
        
        _ = self._downvoteCount.observeNext() { [weak self] downvoteCount in
            self?.separatedVoteCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount)!, downvoteCount: (self?.downvoteCount)!))!
            
            self?.voteCountTotal.value = (self?.getVoteCountTotal(upvoteCount: (self?.upvoteCount)!, downvoteCount: (self?.downvoteCount)!))!
        }
        
        _ = self.voteValue.observeNext { [weak self] voteValue in
            // Whenever vote value is set, recalculate upvote/downvote counts
            self?._downvoteCount.value = (self?._downvoteCount.value)!
            self?._upvoteCount.value = (self?._upvoteCount.value)!
        }
    }
    
    func addChild(viewModel: CommentCellViewModel) {
        self.children.append(viewModel)
        viewModel.parent = self
        viewModel.parentChildrenArrayIndex = self.children.count-1
        viewModel.childDepthIndex = self.childDepthIndex+1
    }
    
    func removeLastChild() {
        self.children.removeLast()
    }
    
    func removeFromParent() {
        self.parent?.children.remove(at: self.parentChildrenArrayIndex)
    }
    
    func toggleMinimized() {
        self.isMinimized.value = !self.isMinimized.value
    }
    
    func resetViewBindings() {
        for binding in self.viewBindings {
            binding.dispose()
        }
        
        self.viewBindings.removeAll()
    }
    
    func resetDataProviderBindings() {
        for binding in self.dataProviderBindings {
            binding.dispose()
        }
        
        self.dataProviderBindings.removeAll()
    }
    
    private func getVoteCountTotal( upvoteCount: Int, downvoteCount: Int) -> Int {
        return upvoteCount - downvoteCount
    }
    
    deinit {
        #if DEBUG
            print("Deallocated a CommentCellViewModel")
        #endif
    }
}
