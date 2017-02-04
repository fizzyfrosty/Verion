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
        
        // XNG Markdown Parser
        let parser = XNGMarkdownParser()
        formattedString = parser.attributedString(fromMarkdownString: markdownString)
        
        return formattedString
    }
}
