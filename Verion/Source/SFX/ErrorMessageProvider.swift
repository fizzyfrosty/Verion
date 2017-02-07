//
//  ErrorMessageProvider.swift
//  Verion
//
//  Created by Simon Chen on 2/7/17.
//  Copyright © 2017 Workhorse Bytes. All rights reserved.
//

import UIKit


enum VoatErrorType {
    case notEnoughCcp
}

class ErrorMessageProvider {
    
    static func getTitle(_ errorType: VoatErrorType) -> String {
        var title = ""
        
        switch errorType {
        case .notEnoughCcp:
            title = "Welcome to Voat!"
        }
        
        return title
    }
    
    static func getMessage(_ errorType: VoatErrorType) -> String {
        var message = ""
        
        switch errorType {
        case .notEnoughCcp:
            message = "In order to *Downvote* comments or submissions you need to have at least 100 comment contribution points (CCP).\n\nEvery time someone upvotes one of your comments, you gain 1 comment contribution point.\n\nTip: Taking part in friendly discussions will help you get there in no time!"
        }
        
        return message
    }

}
