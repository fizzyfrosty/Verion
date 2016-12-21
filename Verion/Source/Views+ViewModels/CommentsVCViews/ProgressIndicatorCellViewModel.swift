//
//  ProgressIndicatorCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/20/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

class ProgressIndicatorCellViewModel {
    
    var progress = Observable<Double>(0.0)
    
    var cellHeight: CGFloat {
        get {
            return self.CELL_HEIGHT
        }
    }
    
    private let CELL_HEIGHT: CGFloat = 50.0
    
    init() {
        
    }

}
