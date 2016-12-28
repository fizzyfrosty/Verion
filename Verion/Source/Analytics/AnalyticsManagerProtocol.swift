//
//  AnalyticsManagerProtocol.swift
//  Verion
//
//  Created by Simon Chen on 12/28/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

protocol AnalyticsManagerProtocol: class {
    
    func logEvent(name: String, timed: Bool)
    func logEvent(name: String, params: Dictionary<AnyHashable, Any>, timed: Bool)
    func endTimedEvent(name: String, params: Dictionary<AnyHashable, Any>?)
}
