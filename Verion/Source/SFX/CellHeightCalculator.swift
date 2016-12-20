//
//  CellHeightCalculator.swift
//  Verion
//
//  Created by Simon Chen on 12/16/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class CellHeightCalculator {
    
    static func sizeForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let size = CGSize(width: rect.width, height: rect.height)
        
        return size
    }
    
    static func sizeForAttributedText(text: NSAttributedString, maxSize: CGSize) -> CGSize {
        let rect = text.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let size = CGSize(width: rect.width, height: rect.height)
        
        return size
    }
}
