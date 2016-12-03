//
//  NSMutableAttributedString+Bold.swift
//  Verion
//
//  Created by Simon Chen on 12/3/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func bold(text:String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: fontSize)]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
    
}
