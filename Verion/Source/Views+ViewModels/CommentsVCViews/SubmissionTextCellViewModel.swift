//
//  SubmissionTextCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionTextCellViewModel {
    
    var textString = "" {
        didSet {
            if textString == "" {
                textString = "(No Content)"
            }
            
            self.attributedTextString = MarkdownParser.attributedString(fromMarkdownString: textString)
        }
    }
    
    var attributedTextString: NSAttributedString?
    
    // Cell Height
    var cellHeight: CGFloat {
        get {
            return self.getCellHeight(text: self.attributedTextString!)
        }
    }
    
    private let MAX_CELL_HEIGHT: CGFloat = 99999.0
    private let CELL_VERTICAL_OFFSET: CGFloat = 27.0 // Represents everything vertically that isn't the title.

    
    init(text: String) {
        self.textString = text
    }

    private func getCellHeight(text: NSAttributedString) -> CGFloat {
        let margins: CGFloat = 25.0
        let width = UIScreen.main.bounds.width - margins
        
        let titleSize = CellHeightCalculator.sizeForAttributedText(text: text, maxSize: CGSize(width: width, height: self.MAX_CELL_HEIGHT))
        
        let cellHeight = titleSize.height + self.CELL_VERTICAL_OFFSET
        
        return cellHeight
    }
}
