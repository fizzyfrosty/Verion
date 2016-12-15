//
//  CommentsSortByCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond


class CommentsSortByCellViewModel {
    
    var sortType = Observable<SortTypeComments>(.top)//: SortTypeComments = .top

    init() {
        
    }
}
