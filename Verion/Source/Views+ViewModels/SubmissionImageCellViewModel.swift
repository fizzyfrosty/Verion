//
//  SubmissionImageCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionImageCellViewModel {
    
    private(set) var imageLink = ""
    private(set) var image: UIImage?

    
    init(imageLink: String) {
        self.imageLink = imageLink
        
        // TODO: Bind image loading?
    }
}
