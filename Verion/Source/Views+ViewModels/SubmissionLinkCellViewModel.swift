//
//  SubmissionLinkCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

struct SubmissionLinkCellViewModelInitData {
    var thumbnailLink = ""
    var link = ""
    var domainString = ""
    var endpointString = ""
}

class SubmissionLinkCellViewModel {
    
    private(set) var thumbnailImage: UIImage?
    
    private(set) var thumbnailLink = ""
    private(set) var domainString = ""
    private(set) var endpointString = ""
    private(set) var link = ""
    
    init() {
        self.loadInitData(subLinkCellVMInitData: SubmissionLinkCellViewModelInitData())
    }
    
    init(subLinkCellVMInitData: SubmissionLinkCellViewModelInitData) {
        self.loadInitData(subLinkCellVMInitData: subLinkCellVMInitData)
    }
    
    func loadInitData(subLinkCellVMInitData: SubmissionLinkCellViewModelInitData) {
        self.thumbnailLink = subLinkCellVMInitData.thumbnailLink
        self.domainString = subLinkCellVMInitData.domainString
        self.endpointString = subLinkCellVMInitData.endpointString
        self.link = subLinkCellVMInitData.link
    }
    
    func downloadThumbnail() {
        self.thumbnailImage = ImageDownloader.downloadImage(urlString: thumbnailLink)
    }
    
}
