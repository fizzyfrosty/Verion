//
//  MarkdownParser.swift
//  Verion
//
//  Created by Simon Chen on 12/19/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class MarkdownParser {
    static func attributedString(fromMarkdownString markdownString: String) -> NSAttributedString {
        var formattedString = NSAttributedString()
        
        /*
        let swiftyMarkdown = SwiftyMarkdown(string: markdownString)
        formattedString = swiftyMarkdown.attributedString()
 */
        formattedString = TSMarkdownParser.standard().attributedString(fromMarkdown: markdownString)
        
        return formattedString
    }
}
