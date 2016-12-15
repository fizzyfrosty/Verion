//
//  SubmissionTextFormatter.swift
//  Verion
//
//  Created by Simon Chen on 12/15/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class SubmissionTextFormatter {

    // "by username" string
    func createSubmittedByUsernameString(username: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString()
        _ = attrString.normal(text: "by ").bold(text: username, fontSize: fontSize)
        return attrString
    }
    
    // "to subverse" string
    func createSubmittedToSubverseString(dateSubmittedString: String, subverseName: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString()
        
        // eg: 9 hours ago to /v/whatever
        _ = attrString.normal(text: "\(dateSubmittedString) ago to /v/\(subverseName)")
        return attrString
    }
    
    func createDateSubmittedString(gmtDate: Date) -> String {
        let currentDate = Date()
        let dateComponents: Set<Calendar.Component> = [Calendar.Component.year, .month, .day, .hour, .minute, .second]
        let differenceComponents = Calendar.current.dateComponents(dateComponents, from: gmtDate, to: currentDate)
        
        let dateSubmittedString: String
        let dateUnitString: String
        if differenceComponents.year != 0 {
            if differenceComponents.year! > 1 {
                dateUnitString = "years"
            } else {
                dateUnitString = "year"
            }
            // eg: 1 yr or 2 years
            dateSubmittedString = "\(differenceComponents.year!) \(dateUnitString)"
            
        } else if differenceComponents.month != 0{
            if differenceComponents.month! > 1 {
                dateUnitString = "months"
            } else {
                dateUnitString = "month"
            }
            // eg: 1 month, 2 months
            dateSubmittedString = "\(differenceComponents.month!) \(dateUnitString)"
            
        } else if differenceComponents.day != 0 {
            if differenceComponents.day! > 1 {
                dateUnitString = "days"
            } else {
                dateUnitString = "day"
            }
            // eg: 1 day, 2 days
            dateSubmittedString = "\(differenceComponents.day!) \(dateUnitString)"
            
        } else if differenceComponents.hour != 0 {
            if differenceComponents.hour! > 1 {
                dateUnitString = "hours"
            } else {
                dateUnitString = "hour"
            }
            // eg: 1 hour, 2 hours
            dateSubmittedString = "\(differenceComponents.hour!) \(dateUnitString)"
            
        } else if differenceComponents.minute != 0 {
            dateUnitString = "min"
            
            // eg: 1 min, 2 min
            dateSubmittedString = "\(differenceComponents.minute!) \(dateUnitString)"
        } else {
            dateUnitString = "sec"
            
            // eg: 1 sec, 34 sec
            dateSubmittedString = "\(differenceComponents.second!) \(dateUnitString)"
        }
        
        return dateSubmittedString
    }
    
    // Vote Count Separated String
    func createVoteCountSeparatedString(upvoteCount: Int, downvoteCount: Int) -> String {
        
        // Should appear to be (+1|-5)
        return "(+\(upvoteCount)|-\(downvoteCount))"
    }
}
