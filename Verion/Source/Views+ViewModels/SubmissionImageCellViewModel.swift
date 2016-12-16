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
            if self.image == nil {
                return self.CELL_HEIGHT
            }
            else {
                return self.getAspectFitHeight(forImage: self.image!)
            }
        }
    }
    private let CELL_HEIGHT: CGFloat = 100.0
    
    init(imageLink: String) {
        self.imageLink = imageLink
        
        // TODO: Bind image loading?
    }
    
    func downloadImage(completion: @escaping ()->()) {
        self.image = ImageDownloader.downloadImage(urlString: self.imageLink)
        
        completion()
    }
    
    private func getAspectFitHeight(forImage image: UIImage) -> CGFloat {
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let screenWidth = UIScreen.main.bounds.width
        let aspectRatio = imageWidth/imageHeight
        
        
        let height: CGFloat = screenWidth / aspectRatio
        
        return height
    }
    
}
