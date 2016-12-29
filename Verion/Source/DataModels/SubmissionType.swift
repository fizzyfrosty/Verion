//
//  SubmissionType.swift
//  Verion
//
//  Created by Simon Chen on 12/3/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

enum SubmissionType: Int {
    case text = 1
    case link = 2
}

enum SubmissionMediaType: String {
    case undetermined = "undetermined"
    case text = "text"
    case image = "image"
    case video = "video"
    case link = "link"
}
