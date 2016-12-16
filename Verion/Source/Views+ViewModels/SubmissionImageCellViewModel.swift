//
//  SubmissionImageCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionImageCellViewModel {
    
    var imageLink = ""
    private(set) var image: UIImage?

    var cellHeight: CGFloat {
        get {
            return self.CELL_HEIGHT
        }
    }
    private let CELL_HEIGHT: CGFloat = 100.0
    
    init(imageLink: String) {
        self.imageLink = imageLink
        
        // TODO: Bind image loading?
    }
    
    func downloadImage() {
        self.image = ImageDownloader.downloadImage(urlString: self.imageLink)
    }
    
}
