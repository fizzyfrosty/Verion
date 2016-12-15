//
//  ImageDownloader.swift
//  Verion
//
//  Created by Simon Chen on 12/15/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class ImageDownloader: NSObject {

    static func downloadImage(urlString: String) -> UIImage? {
        guard let url = URL.init(string: urlString) else {
            // Empty or nil string returns nothing
            return nil
        }
        
        var image: UIImage?
        
        do {
            let imageData = try Data.init(contentsOf: url)
            image = UIImage.init(data: imageData)
        } catch {
            image = UIImage.init(named: "noimageavailable")
            #if DEBUG
                print("No Image found for thumbnail url: \(urlString)")
            #endif
        }
        
        return image
    }
}
