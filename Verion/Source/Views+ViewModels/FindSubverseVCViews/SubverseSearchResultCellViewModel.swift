//
//  SubverseSearchResultCellViewModel.swift
//  Verion
//
//  Created by Simon Chen on 12/17/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Bond

struct SubverseSearchResultCellViewModelInitData {
    var subverseString = ""
    var subscriberCount: Int = 0
    var subverseDescription = ""
}

class SubverseSearchResultCellViewModel {
    
    var subverseString = ""
    var subverseDescription = ""
    
    var subscriberCount = Observable<Int>(0)
    var subscriberCountString = Observable<String>("")
    
    private let REGULAR_CELL_HEIGHT: CGFloat = 55.0
    private let SMALL_CELL_HEIGHT: CGFloat = 40.0
    
    var cellHeight: CGFloat {
        get {
            if self.subscriberCount.value == 0 || self.subverseDescription == "" {
                return self.SMALL_CELL_HEIGHT
            }
            else {
                return self.REGULAR_CELL_HEIGHT
            }
        }
    }
    
    func loadInitData(initData: SubverseSearchResultCellViewModelInitData) {
        
        // Bindings
        _ = self.subscriberCount.observeNext() { subscriberCount in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            if subscriberCount == 0 {
                self.subscriberCountString.value = ""
            } else {
                self.subscriberCountString.value = "\(numberFormatter.string(from: NSNumber(value: subscriberCount))!) subscribers"
            }
        }
        
        // Variables
        self.subverseString = initData.subverseString
        self.subscriberCount.value = initData.subscriberCount
        self.subverseDescription = initData.subverseDescription
        
    }
}
