//
//  AnalyticsEvents.swift
//  Verion
//
//  Created by Simon Chen on 12/28/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class AnalyticsEvents {
    private static let SUBVERSE_PARAM_KEY = "subverse"
    private static let PAGE_NUMBER_PARAM_KEY = "page_number"
    private static let SORT_TYPE_PARAM_KEY = "sort_type"
    private static let SUBMISSION_MEDIA_TYPE_PARAM_KEY = "media_type"
    private static let SWITCH_ENABLED_KEY = "switch_enabled"
    
    // MARK: - Subverse controller
    static let subverseControllerFindSubverse = "Subverse Controller - Find Subverse"
    
    static let subverseControllerLoaded = "Subverse Controller - Initially Loaded"
    static func getSubverseControllerLoadedParams(subverseName: String) -> Dictionary<AnyHashable, Any>{
        
        // Record subverse name
        
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName))
    }
    
    static let subverseControllerMoreSubmissions = "Subverse Controller - Pressed More Submissions"
    static func getSubverseControllerMoreSubmissionParams(subverseName: String, pageNumber: Int, sortType: SortTypeSubmissions) -> Dictionary<AnyHashable, Any> {
        
        // Record subverse name, page number, sort type
        
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.PAGE_NUMBER_PARAM_KEY, pageNumber),
                          (self.SORT_TYPE_PARAM_KEY, sortType.rawValue))
    }
    
    static let subverseControllerPullToRefresh = "Subverse Controller - Pulled to Refresh"
    static func getSubverseControllerPullToRefreshParams(subverseName: String, sortType: SortTypeSubmissions) -> Dictionary<AnyHashable, Any> {
        
        // Record subverse name, sort type
        
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SORT_TYPE_PARAM_KEY, sortType.rawValue))
    }
    
    static let subverseControllerSortedBy = "Subverse Controller - Pressed Sort By"
    static func getSubverseControllerSortByParams(subverseName: String, sortType: SortTypeSubmissions) -> Dictionary<AnyHashable, Any>{
        
        // Record subverse name, sort type
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SORT_TYPE_PARAM_KEY, sortType.rawValue))
    }
    
    // MARK: - Comments controller
    static let commentsControllerViewing = "Comments Controller - Viewing"
    static func getCommentsControllerViewingParams(subverseName: String, mediaType: SubmissionMediaType) -> Dictionary<AnyHashable, Any> {
        
        // Record submission media type, subverse name
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SUBMISSION_MEDIA_TYPE_PARAM_KEY, mediaType.rawValue))
    }
    
    
    static let commentsControllerShare = "Comments Controller - Pressed Share"
    static func getCommentsControllerShareParams(subverseName: String, mediaType: SubmissionMediaType) -> Dictionary<AnyHashable, Any> {
        
        // Record subverse name, submission media type
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SUBMISSION_MEDIA_TYPE_PARAM_KEY, mediaType.rawValue))
    }
    
    static let commentsControllerOpenContent = "Comments Controller - Opened Content Link"
    static func getCommentsControllerOpenContentParams(subverseName: String, mediaType: SubmissionMediaType) -> Dictionary<AnyHashable, Any> {
        
        // Record subverse name, submission media type
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SUBMISSION_MEDIA_TYPE_PARAM_KEY, mediaType.rawValue))
    }
    
    static let commentsControllerSubmitTopLevelComment = "Comments Controller - Submitted Top Level Comment"
    static func getCommentControllerSubmitTopLevelCommentParams(subverseName: String, mediaType: SubmissionMediaType) -> Dictionary<AnyHashable, Any> {
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SUBMISSION_MEDIA_TYPE_PARAM_KEY, mediaType.rawValue))
    }
    
    static let commentsControllerSubmitCommentReply = "Comments Controller - Submitted Comment Reply"
    static func getCommentControllerSubmitCommentReplyParams(subverseName: String, mediaType: SubmissionMediaType) -> Dictionary<AnyHashable, Any> {
        
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName),
                          (self.SUBMISSION_MEDIA_TYPE_PARAM_KEY, mediaType.rawValue))
    }
    
    // MARK: - Left Menu Controller
    static let leftMenuViewing = "Left Menu - Viewing"
    
    static let leftMenuClearHistory = "Left Menu - Cleared History"
    static func getLeftMenuClearHistoryParams(subverseNames: [String]) -> Dictionary<AnyHashable, Any> {
        var dictionary = [AnyHashable: Any]()
        
        // Record Subverses
        for subverseName in subverseNames {
            dictionary[self.SUBVERSE_PARAM_KEY+"-"+subverseName] = subverseName
        }
        
        return dictionary
    }
    
    static let leftMenuGoToSubverseFromHistory = "Left Menu - Selected Subverse from History"
    static func getLeftMenuGoToSubverseFromHistoryParams(subverseName: String) -> Dictionary<AnyHashable, Any> {
        
        return Dictionary(dictionaryLiteral: (self.SUBVERSE_PARAM_KEY, subverseName))
    }
    
    static let leftMenuPurchasedRemoveAds = "Left Menu - Purchased Remove Ads"
    
    static let leftMenuRestorePurchases = "Left Menu - Restore Purchases"
    
    static let leftMenuHideNsfw = "Left Menu - Toggle Hide NSFW"
    static func getLeftMenuHideNsfwParams(isEnabled: Bool) -> Dictionary<AnyHashable, Any> {
        return Dictionary(dictionaryLiteral: (self.SWITCH_ENABLED_KEY, isEnabled))
    }
    
    static let leftMenuUseNsfwThumbnails = "Left Menu - Toggle NSFW Thumbnails"
    static func getLeftMenuUseNsfwThumbnailsParams(isEnabled: Bool) -> Dictionary<AnyHashable, Any> {
        return Dictionary(dictionaryLiteral: (self.SWITCH_ENABLED_KEY, isEnabled))
    }
    
    static let leftMenuFilterLanguage = "Left Menu - Toggle Filter Language"
    static func getLeftMenuFilterLanguageParams(isEnabled: Bool) -> Dictionary<AnyHashable, Any>{
        return Dictionary(dictionaryLiteral: (self.SWITCH_ENABLED_KEY, isEnabled))
    }
    
    static let leftMenuFindSubverse = "Left Menu - Find Subverse"
}
