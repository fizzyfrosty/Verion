//
//  SubmissionCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/1/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

struct SubmissionCellViewModelInitData {
    var titleString: String = "This is a Sample Title for a Submission"
    var linkShortString: String = "(sample.com)"
    var thumbnailLink: String = "" // No thumbnail string, because can be self-post
    var commentCount: Int = 123
    var voteCountTotal: Int = 4331
    var upvoteCount: Int = 211
    var downvoteCount: Int = 154
    var voteValue: VoteValue = .none
    var username: String = "SampleUsername"
    var subverseName: String = "SampleSubverse"
    var date: Date = Date()
    var rank: Double = 3.322
    var isNsfw = false // not yet used
}

class SubmissionCellViewModel{
    
    private let USERNAME_LABEL_FONT_SIZE: CGFloat = 12
    private let textFormatter = SubmissionTextFormatter()
    
    // For autosizing of cell
    private let CELL_TITLE_FONT_NAME = "AmericanTypewriter-Bold"
    private let CELL_TITLE_FONT_SIZE: CGFloat = 18
    private let MAX_CELL_HEIGHT: CGFloat = 999
    private let MINIMUM_CELL_HEIGHT_WITH_IMAGE: CGFloat = 130.0
    private let MINIMUM_CELL_HEIGHT_NO_IMAGE: CGFloat = 80.0
    
    // Variables for binding to UI
    private(set) var linkShortString: String = ""
    var thumbnailLink = Observable<String>("")
    private(set) var titleString: String = ""

    var voteCountTotal = Observable<Int>(0)
    private(set) var voteSeparatedCountString = Observable<String>("")

    // Data Provider Bindings
    var dataProviderBindings: [Disposable] = [] // for external use
    
    private(set) var didRequestUpvote = Observable<Bool>(false)
    private(set) var didRequestDownvote = Observable<Bool>(false)
    
    var viewBindings: [Disposable] = [] // for external use
    
    var voteValue = Observable<VoteValue>(.none)
    
    var commentCount = 0
    
    private(set) var submittedByString = NSMutableAttributedString()
    private(set) var submittedToSubverseString = NSMutableAttributedString()
    
    private(set) var thumbnailImage: UIImage?
    private(set) var isNsfw = false // not yet used
    private let NSFW_IMAGE_NAME = "nsfw_icon"
    
    // Variables - additional
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
    
    private(set) var username: String = ""
    private(set) var subverseName: String = ""
    
    private(set) var date: Date?
    private(set) var dateSubmittedString = ""
    private(set) var rank: Double = 0.0
    
    var cellHeight: CGFloat {
        get {
            let minCellHeight = self.getMinimumCellHeight(dependingOnThumbnailLink: self.thumbnailLink.value)
            return self.getCellHeight(withTitleString: self.titleString, minCellHeight: minCellHeight, maxCellHeight: self.MAX_CELL_HEIGHT)
        }
    }
    
    // A reference to the corresponding data model
    weak var dataModel: SubmissionDataModelProtocol?
    
    // Lazy initialization
    init() {
        self.setupInternalBindings()
        self.loadInitData(subCellVmInitData: SubmissionCellViewModelInitData())
    }
    
    init(withoutAnything: Bool) {
        self.setupInternalBindings()
        //self.loadInitData(subCellVmInitData: SubmissionCellViewModelInitData())
    }
    
    // Custom initialization
    init(subCellVmInitData: SubmissionCellViewModelInitData) {
        self.setupInternalBindings()
        self.loadInitData(subCellVmInitData: subCellVmInitData)
    }
    
    
    func loadInitData(subCellVmInitData: SubmissionCellViewModelInitData) {
        self.titleString = subCellVmInitData.titleString
        self.linkShortString = subCellVmInitData.linkShortString
        self.thumbnailLink.value = subCellVmInitData.thumbnailLink
        self.commentCount = subCellVmInitData.commentCount
        self.voteCountTotal.value = subCellVmInitData.voteCountTotal
        self._upvoteCount.value = subCellVmInitData.upvoteCount
        self._downvoteCount.value = subCellVmInitData.downvoteCount
        self.username = subCellVmInitData.username
        self.subverseName = subCellVmInitData.subverseName
        self.date = subCellVmInitData.date
        self.rank = subCellVmInitData.rank
        self.isNsfw = subCellVmInitData.isNsfw
        self.voteValue.value = subCellVmInitData.voteValue
        self.dateSubmittedString = self.textFormatter.createDateSubmittedString(gmtDate: subCellVmInitData.date)
        self.submittedByString = self.textFormatter.createSubmittedByUsernameString(username: subCellVmInitData.username, fontSize: self.USERNAME_LABEL_FONT_SIZE)
        
        self.submittedToSubverseString = self.textFormatter.createSubmittedToSubverseString(dateSubmittedString: self.dateSubmittedString, subverseName: self.subverseName)
    }
    
    // Use externally for whoever is doing the binding to separate/optimize loading
    func createThumbnailImage(shouldUseNsfwThumbnailIfApplicable: Bool) {
        
        if shouldUseNsfwThumbnailIfApplicable == true {
            self.thumbnailImage = self.createThumbnailImage(urlString: self.thumbnailLink.value, isNsfw: self.isNsfw)
        } else {
            self.thumbnailImage = self.createThumbnailImage(urlString: self.thumbnailLink.value, isNsfw: false)
        }
        
    }
    
    // External use
    func resetDataProviderBindings() {
        for binding in self.dataProviderBindings {
            binding.dispose()
        }
        
        self.dataProviderBindings.removeAll()
    }
    
    func resetViewBindings() {
        for binding in self.viewBindings {
            binding.dispose()
        }
        
        self.viewBindings.removeAll()
    }
    
    private func setupInternalBindings() {
        // Bindings for upvotes and downvotes to update votecount separated string and total vote count
        _ = self._upvoteCount.observeNext {[weak self] _ in
            self?.voteCountTotal.value = (self?.upvoteCount)! - (self?.downvoteCount)!
            
            self?.voteSeparatedCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount)!, downvoteCount: (self?.downvoteCount)!))!
        }
        
        
        _ = self._downvoteCount.observeNext { [weak self] _ in
            self?.voteCountTotal.value = (self?.upvoteCount)! - (self?.downvoteCount)!
            
            self?.voteSeparatedCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount)!, downvoteCount: (self?.downvoteCount)!))!
        }
        
        _ = self.voteValue.observeNext { [weak self] voteValue in
            // Whenever vote value is set, recalculate upvote/downvote counts
            self?._downvoteCount.value = (self?._downvoteCount.value)!
            self?._upvoteCount.value = (self?._upvoteCount.value)!
        }
    }
    
    // Minimum Cell Height
    private func getMinimumCellHeight(dependingOnThumbnailLink thumbnailLink: String) -> CGFloat {
        if thumbnailLink != "" {
            return self.MINIMUM_CELL_HEIGHT_WITH_IMAGE
        }
        
        return self.MINIMUM_CELL_HEIGHT_NO_IMAGE
    }
    
    // Cell height
    private func getCellHeight(withTitleString titleString:String, minCellHeight: CGFloat, maxCellHeight: CGFloat) -> CGFloat {
        var cellHeight: CGFloat = 0
        
        // Width of label is screensize.width minus the imageSize and its margins
        var imageViewHorizontalMargins: CGFloat = 25
        var imageViewWidth: CGFloat = 75
        
        // Only change margins for computing height if there is absolutely no thumbnail
        if self.thumbnailImage == nil && self.thumbnailLink.value == "" {
            imageViewWidth = 0
            imageViewHorizontalMargins = 25
        }
        
        let titleWidth = UIScreen.main.bounds.size.width - imageViewWidth - imageViewHorizontalMargins
        let titleSize = CellHeightCalculator.sizeForText(text: titleString, font: UIFont.init(name: self.CELL_TITLE_FONT_NAME, size: self.CELL_TITLE_FONT_SIZE)!, maxSize: CGSize(width: titleWidth, height: maxCellHeight))
        
        let titleHeight = titleSize.height
        let titleTopMargin: CGFloat = 10
        let titleBottomMargin: CGFloat = 10
        let submittedByTextHeight: CGFloat = 55
        
        cellHeight = titleHeight + titleTopMargin + titleBottomMargin + submittedByTextHeight
        
        cellHeight = max(cellHeight, minCellHeight)
        
        return cellHeight
    }
    
    // Thumbnail Image
    private func createThumbnailImage(urlString: String, isNsfw: Bool) -> UIImage? {
        let image: UIImage?
        if self.shouldShowNSFW(isNsfw: isNsfw, urlString: urlString){
            image = self.getNsfwImage()
        } else {
            image = ImageDownloader.downloadImage(urlString: urlString)
        }
        
        return image
    }
    
    private func getNsfwImage()-> UIImage {
        let image = UIImage.init(named: self.NSFW_IMAGE_NAME)
        
        return image!
    }
    
    private func shouldShowNSFW(isNsfw: Bool, urlString: String) -> Bool {
        if isNsfw == true && urlString != "" {
            return true
        }
        
        return false
    }
    
    deinit {
        #if DEBUG
        //print("deallocating SubverseViewModel")
        #endif
    }
    
}
