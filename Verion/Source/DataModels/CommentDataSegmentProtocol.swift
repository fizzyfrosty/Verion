//
//  CommentDataSegmentProtocol.swift
//  Verion
//
//  Created by Simon Chen on 1/8/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol CommentDataSegmentProtocol: class{
    var hasMore: Bool {get set}
    var endingIndex: Int {get set}
    var remainingCount: Int {get set}
}
