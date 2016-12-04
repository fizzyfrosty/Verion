//
//  Delayer.swift
//  Verion
//
//  Created by Simon Chen on 12/4/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class Delayer {
    
    static func delay(seconds: Int, completion: @escaping ()->Void){
        let deadlineTime = DispatchTime.now() + DispatchTimeInterval.seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            completion()
            
        }
    }

}
