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
    var linkShortString: String = "(sample.com)"
    var thumbnailLink: String = "" // No thumbnail string, because can be self-post
    var commentCount: Int = 123
    var voteCountTotal: Int = 4331
    var upvoteCount: Int = 211
    var downvoteCount: Int = 154
    var username: String = "SampleUsername"
    var subverseName: String = "SampleSubverse"
    var date: Date = Date()
    var rank: Double = 3.322
}

class SubmissionCellViewModel{
    
    private let USERNAME_LABEL_FONT_SIZE: CGFloat = 12
    private let textFormatter = SubmissionTextFormatter()
    
    // For autosizing of cell
    private let CELL_TITLE_FONT_NAME = "AmericanTypewriter-Bold"
    private let CELL_TITLE_FONT_SIZE: CGFloat = 18
    private let MAX_CELL_HEIGHT: CGFloat = 999
    private let MINIMUM_CELL_HEIGHT_WITH_IMAGE: CGFloat = 125.0
    private let MINIMUM_CELL_HEIGHT_NO_IMAGE: CGFloat = 80.0
    
    // Variables for binding to UI
    private(set) var linkShortString: String = ""
    var thumbnailLink = Observable<String>("")
    private(set) var titleString: String = ""

    var voteCountTotal = Observable<Int>(0)
    private(set) var voteSeparatedCountString = Observable<String>("")
    
    private(set) var didUpvote = Observable<Bool>(false)
    private(set) var didDownvote = Observable<Bool>(false)
    
    var commentCount = 0
    
    private(set) var submittedByString = NSMutableAttributedString()
    private(set) var submittedToSubverseString = NSMutableAttributedString()
    
    private(set) var thumbnailImage: UIImage?
    
    // Variables - additional
    var upvoteCount = Observable<Int>(0)
    var downvoteCount = Observable<Int>(0)
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
        self.upvoteCount.value = subCellVmInitData.upvoteCount
        self.downvoteCount.value = subCellVmInitData.downvoteCount
        self.username = subCellVmInitData.username
        self.subverseName = subCellVmInitData.subverseName
        self.date = subCellVmInitData.date
        self.rank = subCellVmInitData.rank
        self.dateSubmittedString = self.textFormatter.createDateSubmittedString(gmtDate: subCellVmInitData.date)
        self.submittedByString = self.textFormatter.createSubmittedByUsernameString(username: subCellVmInitData.username, fontSize: self.USERNAME_LABEL_FONT_SIZE)
        
        self.submittedToSubverseString = self.textFormatter.createSubmittedToSubverseString(dateSubmittedString: self.dateSubmittedString, subverseName: self.subverseName)
    }
    
    // Use externally for whoever is doing the binding to separate/optimize loading
    func createThumbnailImage() {
        self.thumbnailImage = self.createThumbnailImage(urlString: self.thumbnailLink.value)
    }
    
    private func setupInternalBindings() {
        // Bindings for upvotes and downvotes to update votecount separated string and total vote count
        _ = self.upvoteCount.observeNext {[weak self] _ in
            self?.voteCountTotal.value = (self?.upvoteCount.value)! - (self?.downvoteCount.value)!
            
            self?.voteSeparatedCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount.value)!, downvoteCount: (self?.downvoteCount.value)!))!
        }
        
        
        _ = self.downvoteCount.observeNext { [weak self] _ in
            self?.voteCountTotal.value = (self?.upvoteCount.value)! - (self?.downvoteCount.value)!
            
            self?.voteSeparatedCountString.value = (self?.textFormatter.createVoteCountSeparatedString(upvoteCount: (self?.upvoteCount.value)!, downvoteCount: (self?.downvoteCount.value)!))!
        }
    }
    
    private func cleanupInternalBindings() {
        _ = self.upvoteCount.observeNext { _ in
        }
        _ = self.downvoteCount.observeNext { _ in
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
        var imageViewHorizontalMargins: CGFloat = 30
        var imageViewWidth: CGFloat = 75
        
        // Only change margins for computing height if there is absolutely no thumbnail
        if self.thumbnailImage == nil && self.thumbnailLink.value == "" {
            imageViewWidth = 0
            imageViewHorizontalMargins = 50
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
    private func createThumbnailImage(urlString: String) -> UIImage? {
        
        let image = ImageDownloader.downloadImage(urlString: urlString)
        
        return image
    }
    
    deinit {
        #if DEBUG
        //print("deallocating SubverseViewModel")
        #endif
    }
    
}
