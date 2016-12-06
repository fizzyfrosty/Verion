//
//  Delayer.swift
//  Verion
//
//  Created by Simon Chen on 12/4/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class Delayer {
    
    static func delay(seconds: Float, completion: @escaping ()->Void){
        let milliSeconds: Int = Int(seconds * 1000)
        
        let deadlineTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(milliSeconds)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            completion()
            
        }
    }

}
