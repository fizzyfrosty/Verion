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
    var imageData: Data? {
        didSet {
            self.image = UIImage.init(data: self.imageData!)
        }
    }
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
    private let CELL_HEIGHT: CGFloat = 0.0
    
    init () {
        
    }
    
    init(imageData: Data) {
        self.imageData = imageData
        self.image = UIImage.init(data: self.imageData!)
    }
    
    init(imageLink: String) {
        self.imageLink = imageLink
        
        // TODO: Bind image loading?
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
