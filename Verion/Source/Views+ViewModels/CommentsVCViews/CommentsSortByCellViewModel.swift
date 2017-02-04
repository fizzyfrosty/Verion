//
//  CommentsSortByCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/14/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class CommentsSortByCellViewModel {
    
    var sortType = Observable<SortTypeComments>(.top)//: SortTypeComments = .top
    var viewBindings: [Disposable] = [] // for external use
    
    var cellHeight: CGFloat {
        get {
            return self.CELL_HEIGHT
        }
    }
    
    private let CELL_HEIGHT: CGFloat = 90

    init() {
        
    }
    
    func resetViewBindings() {
        for binding in self.viewBindings {
            binding.dispose()
        }
        
        self.viewBindings.removeAll()
    }
}
