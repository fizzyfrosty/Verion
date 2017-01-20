//
//  AnalyticsManager.swift
//  Verion
//
//  Created by Simon Chen on 12/28/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

enum AnalyticsType {
    case none
    case flurry
}

// Flurry session started in AppDelegate

class AnalyticsManager: AnalyticsManagerProtocol {
    
    let analyticsType: AnalyticsType
    
    init(analyticsType: AnalyticsType) {
        self.analyticsType = analyticsType
    }
    
    func logEvent(name: String, timed: Bool) {
        switch self.analyticsType {
        case .flurry:
            Flurry.logEvent(name, timed: timed)
        case .none:
            #if DEBUG
                print("Analytics Logging (no analytics) - \(name), timed: \(timed)")
            #endif
        }
    }
    
    func logEvent(name: String, params: Dictionary<AnyHashable, Any>, timed: Bool) {
        switch self.analyticsType {
        case .flurry:
            Flurry.logEvent(name, withParameters: params, timed: timed)
        case .none:
            #if DEBUG
                print("Analytics Logging (no analytics) - \(name), timed: \(timed), params: \(params)")
            #endif
        }
    }
    
    func endTimedEvent(name: String, params: Dictionary<AnyHashable, Any>?) {
        switch self.analyticsType {
        case .flurry:
            Flurry.endTimedEvent(name, withParameters: params)
        case .none:
            #if DEBUG
                print("Analytics Logging - Ending timed event (no analytics) - \(name)")
            #endif
        }
    }

}
