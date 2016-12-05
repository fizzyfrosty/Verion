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
}

class SubmissionCellViewModel{
    
    private let USERNAME_LABEL_FONT_SIZE: CGFloat = 12
    
    // For autosizing of cell
    private let CELL_TITLE_FONT_NAME = "AmericanTypewriter-Bold"
    private let CELL_TITLE_FONT_SIZE: CGFloat = 18
    private let MAX_CELL_HEIGHT: CGFloat = 999
    private let MINIMUM_CELL_HEIGHT_WITH_IMAGE: CGFloat = 140.0
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
    
    var cellHeight: CGFloat {
        set {
            self.cellHeight = newValue
        }
        get {
            let minCellHeight = self.getMinimumCellHeight(dependingOnThumbnailLink: self.thumbnailLink.value)
            return self.getCellHeight(withTitleString: self.titleString, minCellHeight: minCellHeight, maxCellHeight: self.MAX_CELL_HEIGHT)
        }
    }
    
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
        self.linkShortString = subCellVmInitData.linkShortString
        self.thumbnailLink.value = subCellVmInitData.thumbnailLink
        self.commentCount = subCellVmInitData.commentCount
        self.voteCountTotal.value = subCellVmInitData.voteCountTotal
        self.upvoteCount.value = subCellVmInitData.upvoteCount
        self.downvoteCount.value = subCellVmInitData.downvoteCount
        self.username = subCellVmInitData.username
        self.subverseName = subCellVmInitData.subverseName
        self.date = subCellVmInitData.date
        self.dateSubmittedString = self.createDateSubmittedString(gmtDate: subCellVmInitData.date)
        self.submittedByString = self.createSubmittedByUsernameString(username: subCellVmInitData.username)
        
        self.submittedToSubverseString = self.createSubmittedToSubverseString(dateSubmittedString: self.dateSubmittedString, subverseName: self.subverseName)
    }
    
    // Use externally for whoever is doing the binding to separate/optimize loading
    func createThumbnailImage() {
        self.thumbnailImage = self.createThumbnailImage(urlString: self.thumbnailLink.value)
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
        
        if self.thumbnailImage == nil {
            imageViewWidth = 0
            imageViewHorizontalMargins = 50
        }
        
        let titleWidth = UIScreen.main.bounds.size.width - imageViewWidth - imageViewHorizontalMargins
        let titleSize = self.sizeForText(text: titleString, font: UIFont.init(name: self.CELL_TITLE_FONT_NAME, size: self.CELL_TITLE_FONT_SIZE)!, maxSize: CGSize(width: titleWidth, height: maxCellHeight))
        
        let titleHeight = titleSize.height
        let titleTopMargin: CGFloat = 10
        let titleBottomMargin: CGFloat = 10
        let submittedByTextHeight: CGFloat = 50
        
        cellHeight = titleHeight + titleTopMargin + titleBottomMargin + submittedByTextHeight
        
        cellHeight = max(cellHeight, minCellHeight)
        
        return cellHeight
    }
    
    // Thumbnail Image
    private func createThumbnailImage(urlString: String) -> UIImage? {
        
        guard let url = URL.init(string: urlString) else {
            // Empty or nil string returns nothing
            return nil
        }
        
        var image: UIImage?
    
        do {
            let imageData = try Data.init(contentsOf: url)
            image = UIImage.init(data: imageData)
        } catch {
            // TODO: load image with a "image not available" image
            image = UIImage.init(named: "noimageavailable")
            #if DEBUG
                print("No Image found for thumbnail url: \(urlString)")
            #endif
        }
        
        return image
    }
    
    /*
    func getResizedImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }*/
    
    // "by username" string
    private func createSubmittedByUsernameString(username: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString()
        _ = attrString.normal(text: "by ").bold(text: username, fontSize: self.USERNAME_LABEL_FONT_SIZE)
        return attrString
    }
    
    // "to subverse" string
    private func createSubmittedToSubverseString(dateSubmittedString: String, subverseName: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString()
        
        // eg: 9 hours ago to /v/whatever
        _ = attrString.normal(text: "\(dateSubmittedString) ago to /v/\(subverseName)")
        return attrString
    }
    
    private func createDateSubmittedString(gmtDate: Date) -> String {
        let currentDate = Date()
        let dateComponents: Set<Calendar.Component> = [Calendar.Component.year, .month, .day, .hour, .minute, .second]
        let differenceComponents = Calendar.current.dateComponents(dateComponents, from: gmtDate, to: currentDate)
        
        let dateSubmittedString: String
        let dateUnitString: String
        if differenceComponents.year != 0 {
            if differenceComponents.year! > 1 {
                dateUnitString = "years"
            } else {
                dateUnitString = "year"
            }
            // eg: 1 yr or 2 years
            dateSubmittedString = "\(differenceComponents.year!) \(dateUnitString)"
            
        } else if differenceComponents.month != 0{
            if differenceComponents.month! > 1 {
                dateUnitString = "months"
            } else {
                dateUnitString = "month"
            }
            // eg: 1 month, 2 months
            dateSubmittedString = "\(differenceComponents.month!) \(dateUnitString)"
            
        } else if differenceComponents.day != 0 {
            if differenceComponents.day! > 1 {
                dateUnitString = "days"
            } else {
                dateUnitString = "day"
            }
            // eg: 1 day, 2 days
            dateSubmittedString = "\(differenceComponents.day!) \(dateUnitString)"
            
        } else if differenceComponents.hour != 0 {
            if differenceComponents.hour! > 1 {
                dateUnitString = "hours"
            } else {
                dateUnitString = "hour"
            }
            // eg: 1 hour, 2 hours
            dateSubmittedString = "\(differenceComponents.hour!) \(dateUnitString)"
            
        } else if differenceComponents.minute != 0 {
            dateUnitString = "min"
            
            // eg: 1 min, 2 min
            dateSubmittedString = "\(differenceComponents.minute!) \(dateUnitString)"
        } else {
            dateUnitString = "sec"
            
            // eg: 1 sec, 34 sec
            dateSubmittedString = "\(differenceComponents.second!) \(dateUnitString)"
        }
        
        return dateSubmittedString
    }
    
    // Vote Count Separated String
    private func createVoteCountSeparatedString(upvoteCount: Int, downvoteCount: Int) -> String {
        
        // Should appear to be (+1|-5)
        return "(+\(upvoteCount)|-\(downvoteCount))"
    }
    
    
    func sizeForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.width, height: rect.height)
        
        return size
    }
    
}
