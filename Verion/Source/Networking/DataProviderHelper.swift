//
//  DataProviderHelper.swift
//  Verion
//
//  Created by Simon Chen on 12/15/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DataProviderHelper {
    
    
    private let VOAT_THUMBNAIL_LEGACY_URL = "https://cdn.voat.co/thumbs/"
    let API_V1_NOTSUPPORTED_ERROR_MESSAGE = "API.v1 not yet implemented"
    
    func getContentUrlString(fromSubmissionDataModel dataModel: SubmissionDataModelProtocol) -> String {
        var urlString: String = ""
        
        switch dataModel.apiVersion {
        case .legacy:
            urlString = self.getContentUrlStringFromLegacy(submissionDataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            urlString = self.getContentUrlStringFromV1(submissionDataModel: dataModel as! SubmissionDataModelV1)
        }
        
        return urlString
    }
    
    func getCommentCellVmInitData(fromDataModel dataModel: CommentDataModelProtocol) -> CommentCellViewModelInitData {
        let commentViewModelInitData: CommentCellViewModelInitData
        
        switch dataModel.apiVersion {
        case .legacy:
            commentViewModelInitData = self.getCommentViewModelInitDataFromLegacy(dataModel: dataModel as! CommentDataModelLegacy)
        case .v1:
            commentViewModelInitData = self.getCommentViewModelInitDataFromV1(dataModel: dataModel as! CommentDataModelV1)
        }
        
        return commentViewModelInitData
    }
    
    func getSubverseSearchResultCellVmInitData(fromDataModel dataModel: SubverseSearchResultDataModelProtocol) -> SubverseSearchResultCellViewModelInitData{
        let subverseSearchResultCellVmInitData: SubverseSearchResultCellViewModelInitData
        
        switch dataModel.apiVersion {
        case .legacy:
            subverseSearchResultCellVmInitData = self.getSubverseSearchResultCellVmInitDataFromLegacy(dataModel: dataModel as! SubverseSearchResultDataModelLegacy)
        case .v1:
            subverseSearchResultCellVmInitData = self.getSubverseSearchResultCellVmInitDataFromV1(dataModel: dataModel as! SubverseSearchResultDataModelV1)
        }
        
        return subverseSearchResultCellVmInitData
    }
    
    func getSubTitleCellVmInitData(fromDataModel dataModel: SubmissionDataModelProtocol) -> SubmissionTitleCellViewModelInitData {
        let subTitleCellVmInitData: SubmissionTitleCellViewModelInitData
        
        switch dataModel.apiVersion {
        case .legacy:
            subTitleCellVmInitData = self.getSubmissionTitleCellViewModelInitDataFromLegacyDataModel(dataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            subTitleCellVmInitData = self.getSubmissionTitleCellViewModelInitDataFromV1DataModel(dataModel: dataModel as! SubmissionDataModelV1)
        }
        
        return subTitleCellVmInitData
    }
    
    func getImageLink(fromDataModel dataModel: SubmissionDataModelProtocol) -> String {
        
        var imageLink = ""
        
        switch dataModel.apiVersion {
        case .legacy:
            let legacyDataModel = dataModel as! SubmissionDataModelLegacy
            imageLink = legacyDataModel.messageContent
        case .v1:
            let v1DataModel = dataModel as! SubmissionDataModelV1
            imageLink = v1DataModel.url
        }
        
        return imageLink
    }
    
    func getSubLinkCellVmInitData(fromDataModel dataModel: SubmissionDataModelProtocol) -> SubmissionLinkCellViewModelInitData {
        let subLinkCellVmInitData: SubmissionLinkCellViewModelInitData
        
        // Correctly cast
        switch dataModel.apiVersion {
        case .legacy:
            subLinkCellVmInitData = self.getSubLinkCellVmInitDataFromLegacyDataModel(dataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            subLinkCellVmInitData = self.getSubLinkCellVmInitDataFromV1DataModel(dataModel: dataModel as! SubmissionDataModelV1)
        }
        
        return subLinkCellVmInitData
    }
    
    func getSubmissionMediaType(fromDataModel dataModel: SubmissionDataModelProtocol) -> SubmissionMediaType {
        var mediaType = SubmissionMediaType.undetermined
        
        switch dataModel.apiVersion {
        case .legacy:
            mediaType = self.getSubmissionMediaTypeFromLegacyDataModel(submissionDataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            mediaType = self.getSubmissionMediaTypeFromV1DataModel(submissionDataModel: dataModel as! SubmissionDataModelV1)
        }
        
        return mediaType
    }
    
    private func getSubverseSearchResultCellVmInitDataFromV1(dataModel: SubverseSearchResultDataModelV1) -> SubverseSearchResultCellViewModelInitData {
        var subverseSearchResultCellVmInitData = SubverseSearchResultCellViewModelInitData()
        
        subverseSearchResultCellVmInitData.subverseString = dataModel.name
        subverseSearchResultCellVmInitData.subscriberCount = dataModel.subscriberCount
        subverseSearchResultCellVmInitData.subverseDescription = dataModel.description
        
        return subverseSearchResultCellVmInitData

    }
    
    private func getSubverseSearchResultCellVmInitDataFromLegacy(dataModel: SubverseSearchResultDataModelLegacy) -> SubverseSearchResultCellViewModelInitData {
        var subverseSearchResultCellVmInitData = SubverseSearchResultCellViewModelInitData()
        
        subverseSearchResultCellVmInitData.subverseString = dataModel.subverseName
        subverseSearchResultCellVmInitData.subscriberCount = dataModel.subscriberCount
        subverseSearchResultCellVmInitData.subverseDescription = dataModel.subverseDescription
        
        return subverseSearchResultCellVmInitData
    }
    
    private func getSubmissionTitleCellViewModelInitDataFromV1DataModel(dataModel: SubmissionDataModelV1) -> SubmissionTitleCellViewModelInitData {
        var subTitleCellVmInitData = SubmissionTitleCellViewModelInitData()
        subTitleCellVmInitData.date = self.getDateFromString(gmtString: dataModel.creationDateString)
        subTitleCellVmInitData.downvoteCount = dataModel.downvoteCount
        subTitleCellVmInitData.subverseString = dataModel.subverseName
        subTitleCellVmInitData.titleString = dataModel.title
        subTitleCellVmInitData.upvoteCount = dataModel.upvoteCount
        subTitleCellVmInitData.usernameString = dataModel.username
        subTitleCellVmInitData.voteTotalCount = dataModel.voteCountTotal
        
        return subTitleCellVmInitData
    }
    
    private func getSubmissionTitleCellViewModelInitDataFromLegacyDataModel(dataModel: SubmissionDataModelLegacy) -> SubmissionTitleCellViewModelInitData {
        var subTitleCellVmInitData = SubmissionTitleCellViewModelInitData()
        subTitleCellVmInitData.date = self.getDateFromString(gmtString: dataModel.dateString)
        subTitleCellVmInitData.downvoteCount = dataModel.downvoteCount
        subTitleCellVmInitData.subverseString = dataModel.subverseName
        subTitleCellVmInitData.titleString = dataModel.title
        subTitleCellVmInitData.upvoteCount = dataModel.upvoteCount
        subTitleCellVmInitData.usernameString = dataModel.username
        subTitleCellVmInitData.voteTotalCount = dataModel.voteCount
        
        return subTitleCellVmInitData
    }
    
    private func getSubmissionMediaTypeFromV1DataModel(submissionDataModel: SubmissionDataModelV1) -> SubmissionMediaType {
        
        var v1MediaType: SubmissionMediaType = .undetermined
        
        // If data model is text, return text.
        if submissionDataModel.type == "text" {
            v1MediaType = .text
        } else {
            v1MediaType = .undetermined
        }
        
        return v1MediaType
    }
    
    // This should be for offline-use ONLY
    private func getSubmissionMediaTypeFromLegacyDataModel(submissionDataModel: SubmissionDataModelLegacy) -> SubmissionMediaType {
        
        var legacyMediaType: SubmissionMediaType = .undetermined
        
        // If data model is text, return text.
        if submissionDataModel.type == SubmissionType.text.rawValue {
            legacyMediaType = .text
        } else {
            legacyMediaType = .undetermined
        }
        
        return legacyMediaType
    }
    
    func getCommentDataModels(fromJson json: JSON, apiVersion: APIVersion) -> [CommentDataModelProtocol]{
        var commentDataModels: [CommentDataModelProtocol] = []
        
        switch apiVersion {
        case .legacy:
            // For each submission, create a datamodel
            for i in 0..<json.count {
                // Get data model from sample JSON
                let commentJson = json[i]
                let commentDataModel = self.getCommentDataModelLegacy(fromJson: commentJson)
                commentDataModels.append(commentDataModel)
            }
        case .v1:
            let success = json["success"].boolValue
            if success == true {
                // Get array of comments
                let commentDataSet = json["data"]
                let commentsArray = commentDataSet["comments"].arrayValue
                
                for commentJson in commentsArray {
                    let commentDataModelV1 = self.getCommentDataModelV1(fromCommentJson: commentJson)
                    commentDataModels.append(commentDataModelV1)
                }   
            }
        }
        
        return commentDataModels
    }
    
    func getSubverseSearchResultDataModels(fromJson json: JSON, apiVersion: APIVersion) -> [SubverseSearchResultDataModelProtocol] {
        var searchResultDataModels: [SubverseSearchResultDataModelProtocol]
        
        switch apiVersion {
        case .legacy:
            searchResultDataModels = self.getSubverseSearchResultDataModelsLegacy(fromJson: json)
        case .v1:
            searchResultDataModels = self.getSubverseSearchResultDataModelsV1(fromJson: json)
        }
        
        return searchResultDataModels
    }
    
    private func getSubverseSearchResultDataModelsV1(fromJson json:JSON) -> [SubverseSearchResultDataModelV1] {
        var subverseDataModels: [SubverseSearchResultDataModelV1] = []
        
        let dataJson = json["data"]
        
        for i in 0..<dataJson.count {
            let subverseJson = dataJson[i]
            let subverseDataModel = self.getSubverseSearchResultDataModelV1(fromJson: subverseJson)
            subverseDataModels.append(subverseDataModel)
        }
        
        return subverseDataModels
    }
    
    private func getSubverseSearchResultDataModelsLegacy(fromJson json:JSON) -> [SubverseSearchResultDataModelLegacy] {
        var subverseDataModels: [SubverseSearchResultDataModelLegacy] = []
        
        // For each submission, create a data model
        for i in 0..<json.count {
            // Get data model from sample JSON
            let subverseJson = json[i]
            let subverseDataModel = self.getSubverseSearchResultDataModelLegacy(fromJson: subverseJson)
            subverseDataModels.append(subverseDataModel)
        }
        
        return subverseDataModels
    }
    
    private func getSubverseSearchResultDataModel(fromJson json:JSON, apiVersion: APIVersion) -> SubverseSearchResultDataModelProtocol {
        let subverseDataModel: SubverseSearchResultDataModelProtocol
        switch apiVersion {
        case .legacy:
            subverseDataModel = self.getSubverseSearchResultDataModelLegacy(fromJson: json)
        case .v1:
            subverseDataModel = self.getSubverseSearchResultDataModelV1(fromJson: json)
        }
        
        return subverseDataModel
    }
    
    func getSubmissionDataModels(fromJson json:JSON, apiVersion: APIVersion) -> [SubmissionDataModelProtocol] {
        let submissionDataModels: [SubmissionDataModelProtocol]
        
        switch apiVersion {
        case .legacy:
            submissionDataModels = self.getSubmissionDataModelsLegacy(fromJson: json)
        case .v1:
            submissionDataModels = self.getSubmissionDataModelsV1(fromJson: json)
        }
        
        return submissionDataModels
    }
    
    func getSampleJson(filename: String, withExtension ext: String) -> JSON {
        let url = Bundle.main.url(forResource: filename,
                                  withExtension: ext)
        let jsonData: Data
        do {
            try jsonData = Data.init(contentsOf: url!)
        }
        catch {
            fatalError("Sample JSON file does not exist in Bundle")
        }
        
        let sampleJson = JSON.init(data: jsonData)
        
        return sampleJson
    }
    
    
    func getSubCellVmInitData(fromDataModel dataModel:SubmissionDataModelProtocol) -> SubmissionCellViewModelInitData {
        let subCellVmInitData: SubmissionCellViewModelInitData
        
        // Correctly cast
        switch dataModel.apiVersion {
        case .legacy:
            subCellVmInitData = self.getSubCellVmInitDataFromLegacyDataModel(dataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            subCellVmInitData = self.getSubCellVmInitDataFromV1DataModel(dataModel: dataModel as! SubmissionDataModelV1)
        }
        
        return subCellVmInitData
    }
    
    // MARK: - private methods
    
    private func getContentUrlStringFromV1(submissionDataModel: SubmissionDataModelV1) -> String {
        return submissionDataModel.url
    }
    
    private func getContentUrlStringFromLegacy(submissionDataModel: SubmissionDataModelLegacy) -> String {
        return submissionDataModel.messageContent
    }
    
    private func getCommentViewModelInitDataFromV1(dataModel: CommentDataModelV1) -> CommentCellViewModelInitData{
        var commentCellVmInitData = CommentCellViewModelInitData()
        
        commentCellVmInitData.date = self.getDateFromString(gmtString: dataModel.creationDateString)
        commentCellVmInitData.downvoteCount = dataModel.downvoteCount
        commentCellVmInitData.textString = dataModel.content
        commentCellVmInitData.upvoteCount = dataModel.upvoteCount
        commentCellVmInitData.usernameString = dataModel.username
        commentCellVmInitData.voteCountTotal = dataModel.voteCountTotal
        commentCellVmInitData.isMinimized = dataModel.isCollapsed
        commentCellVmInitData.isUserOP = dataModel.isSubmitter
        
        for childData in dataModel.children {
            let commentCellVmInitDataChild = self.getCommentViewModelInitDataFromV1(dataModel: childData)
            commentCellVmInitData.children.append(commentCellVmInitDataChild)
        }
        
        return commentCellVmInitData
    }
    
    private func getCommentViewModelInitDataFromLegacy(dataModel: CommentDataModelLegacy) -> CommentCellViewModelInitData{
        var commentCellVmInitData = CommentCellViewModelInitData()
        
        commentCellVmInitData.date = self.getDateFromString(gmtString: dataModel.dateString)
        commentCellVmInitData.downvoteCount = dataModel.downvoteCount
        commentCellVmInitData.textString = dataModel.commentContent
        commentCellVmInitData.upvoteCount = dataModel.upvoteCount
        commentCellVmInitData.usernameString = dataModel.username
        commentCellVmInitData.voteCountTotal = dataModel.upvoteCount - dataModel.downvoteCount
        
        return commentCellVmInitData
    }
    
    private func getCommentDataModelV1(fromCommentJson json: JSON) -> CommentDataModelV1 {
        let commentModelV1 = CommentDataModelV1()
        
        commentModelV1.childCount = json["childCount"].intValue
        commentModelV1.content = json["content"].stringValue
        commentModelV1.creationDateString = json["creationDate"].stringValue
        commentModelV1.formattedContent = json["formattedContent"].stringValue
        commentModelV1.id = json["id"].int64Value
        commentModelV1.isAnonymized = json["isAnonymized"].boolValue
        commentModelV1.isCollapsed = json["isCollapsed"].boolValue
        commentModelV1.isDeleted = json["isDeleted"].boolValue
        commentModelV1.isSaved = json["isSaved"].boolValue
        commentModelV1.isDistinguished = json["isDistinguished"].boolValue
        commentModelV1.isOwner = json["isOwner"].boolValue
        commentModelV1.isSubmitter = json["isSubmitter"].boolValue
        commentModelV1.lastEditDateString = json["lastEditDate"].stringValue
        commentModelV1.parentId = json["parentID"].int64Value
        commentModelV1.submissionId = json["submissionID"].int64Value
        commentModelV1.subverseName = json["subverse"].stringValue
        commentModelV1.username = json["userName"].stringValue
        commentModelV1.vote = json["vote"].stringValue
        commentModelV1.voteCountTotal = json["sum"].intValue
        commentModelV1.upvoteCount = json["upCount"].intValue
        commentModelV1.downvoteCount = json["downCount"].intValue
        
        let childrenInfo = json["children"]
        let childrenCount = childrenInfo["segmentCount"].intValue // corresponds to the 'comments' array count
        
        // If there are children comments
        if childrenCount > 0 {
            let childrenNodes = childrenInfo["comments"].arrayValue
            for jsonCommentChild in childrenNodes {
                let commentChildModel = self.getCommentDataModelV1(fromCommentJson: jsonCommentChild)
                commentModelV1.children.append(commentChildModel)
            }
        }
        
        return commentModelV1
    }

    private func getCommentDataModelLegacy(fromJson json: JSON) -> CommentDataModelLegacy {
        let commentDataModelLegacy = CommentDataModelLegacy()
        
        commentDataModelLegacy.commentContent = json["CommentContent"].stringValue
        commentDataModelLegacy.dateString = json["Date"].stringValue
        commentDataModelLegacy.downvoteCount = json["Dislikes"].intValue
        commentDataModelLegacy.id = json["Id"].int64Value
        commentDataModelLegacy.messageId = json["MessageId"].int64Value
        commentDataModelLegacy.parentId = json["ParentId"].int64Value
        commentDataModelLegacy.upvoteCount = json["Likes"].intValue
        commentDataModelLegacy.username = json["Name"].stringValue
        
        return commentDataModelLegacy
    }
    
    private func getSubmissionDataModelsV1(fromJson json: JSON) -> [SubmissionDataModelV1] {
        var submissionDataModelsV1: [SubmissionDataModelV1] = []
        
        let dataSegmentJson = json["data"]
        
        for i in 0..<dataSegmentJson.count {
            let submissionJson = dataSegmentJson[i]
            let submissionDataModelV1 = self.getSubmissionDataModelV1(fromJson: submissionJson)
            submissionDataModelsV1.append(submissionDataModelV1)
        }
        
        return submissionDataModelsV1
    }
    
    private func getSubmissionDataModelsLegacy(fromJson jsonData: JSON) -> [SubmissionDataModelLegacy]{
        var submissionDataModelsLegacy: [SubmissionDataModelLegacy] = []
        
        // For each submission, create a datamodel
        for i in 0..<jsonData.count {
            // Get data model from sample JSON
            let submissionJson = jsonData[i]
            let submissionDataModel = self.getSubmissionDataModelLegacy(fromJson: submissionJson)
            submissionDataModelsLegacy.append(submissionDataModel)
        }
        
        return submissionDataModelsLegacy
    }
    
    private func getSubmissionDataModelV1(fromJson json: JSON) -> SubmissionDataModelV1 {
        let submissionDataModelV1 = SubmissionDataModelV1()
        
        submissionDataModelV1.commentCount = json["commentCount"].intValue
        submissionDataModelV1.content = json["content"].stringValue
        submissionDataModelV1.creationDateString = json["creationDate"].stringValue
        submissionDataModelV1.downvoteCount = json["downCount"].intValue
        submissionDataModelV1.formattedContent = json["formattedContent"].stringValue
        submissionDataModelV1.id = json["id"].int64Value
        submissionDataModelV1.isAnonymized = json["isAnonymized"].boolValue
        submissionDataModelV1.isDeleted = json["isDeleted"].boolValue
        submissionDataModelV1.lastEditDateString = json["lastEditDate"].stringValue
        submissionDataModelV1.subverseName = json["subverse"].stringValue
        submissionDataModelV1.thumbnailUrl = json["thumbnailUrl"].stringValue
        submissionDataModelV1.title = json["title"].stringValue
        submissionDataModelV1.type = json["type"].stringValue.lowercased()
        submissionDataModelV1.upvoteCount = json["upCount"].intValue
        submissionDataModelV1.url = json["url"].stringValue
        submissionDataModelV1.username = json["userName"].stringValue
        submissionDataModelV1.views = json["views"].uIntValue
        submissionDataModelV1.vote = json["vote"].stringValue
        submissionDataModelV1.voteCountTotal = json["sum"].intValue
        
        return submissionDataModelV1
    }
    
    private func getSubmissionDataModelLegacy(fromJson json: JSON) -> SubmissionDataModelLegacy {
        let submissionDataModel = SubmissionDataModelLegacy()
        
        submissionDataModel.commentCount = json["CommentCount"].intValue
        submissionDataModel.dateString = json["Date"].stringValue
        submissionDataModel.downvoteCount = json["Dislikes"].intValue
        submissionDataModel.upvoteCount = json["Likes"].intValue
        submissionDataModel.voteCount = json["Likes"].intValue - json["Dislikes"].intValue
        submissionDataModel.id = json["Id"].int64Value
        submissionDataModel.lastEditDateString = json["LastEditDate"].stringValue
        submissionDataModel.linkDescription = json["Linkdescription"].stringValue
        submissionDataModel.messageContent = json["MessageContent"].stringValue
        submissionDataModel.username = json["Name"].stringValue
        submissionDataModel.rank = json["Rank"].doubleValue
        submissionDataModel.subverseName = json["Subverse"].stringValue
        submissionDataModel.thumbnailLink = self.getThumbnailLink(voatURL: self.VOAT_THUMBNAIL_LEGACY_URL, voatEndpoint: json["Thumbnail"].stringValue)
        submissionDataModel.title = json["Title"].stringValue
        submissionDataModel.type = json["Type"].intValue
        submissionDataModel.dateString = json["Date"].stringValue
        
        return submissionDataModel
    }
    
    private func getSubverseSearchResultDataModelV1(fromJson json: JSON) -> SubverseSearchResultDataModelV1{
        let subverseDataModelV1 = SubverseSearchResultDataModelV1()
        
        subverseDataModelV1.createdByUsername = json["createdBy"].stringValue
        subverseDataModelV1.creationDateString = json["creationDate"].stringValue
        subverseDataModelV1.name = json["name"].stringValue
        subverseDataModelV1.description = json["description"].stringValue
        subverseDataModelV1.formattedSidebarDescription = json["formattedSidebar"].stringValue
        subverseDataModelV1.isAdult = json["isAdult"].boolValue
        subverseDataModelV1.isAnonymized = json["isAnonymized"].boolValue
        subverseDataModelV1.sidebarDescription = json["sidebar"].stringValue
        subverseDataModelV1.title = json["title"].stringValue
        subverseDataModelV1.type = json["type"].stringValue
        subverseDataModelV1.subscriberCount = json["subscriberCount"].intValue
        
        return subverseDataModelV1
    }
    
    // Subverse Search Result Data Model - Legacy
    private func getSubverseSearchResultDataModelLegacy(fromJson json: JSON) -> SubverseSearchResultDataModelLegacy {
        let subverseDataModelLegacy = SubverseSearchResultDataModelLegacy()
        
        // Expecting a single string, eg: "Name: news,Description: A place for major news from around the world,Subscribers: 70441,Created: Apr  7 2014  4:15PM"
        let subverseInfoString = json.stringValue
        
        // Name: news|--split--here--|A place for major news from around the world,Subscribers: 70441,Created: Apr  7 2014  4:15PM
        let nameAndRest = subverseInfoString.components(separatedBy: ",Description: ")
        
        // Name: news
        let nameWithHeader = nameAndRest[0]
        
        // news
        let name = nameWithHeader.replacingOccurrences(of: "Name: ", with: "")
        
        // A place for major news from around the world|--split--here--|70441,Created: Apr  7 2014  4:15PM
        let descriptionAndRest = nameAndRest[1].components(separatedBy: ",Subscribers: ")
        
        // A place for major news from around the world
        let description = descriptionAndRest[0]
        
        // 70441|--split--here--|Apr  7 2014  4:15PM
        let subscribersAndRest = descriptionAndRest[1].components(separatedBy: ",Created: ")
        
        // 70441
        let subscribers = subscribersAndRest[0]
        
        subverseDataModelLegacy.subscriberCount = Int(subscribers)!
        subverseDataModelLegacy.subverseName = name
        subverseDataModelLegacy.subverseDescription = description
        
        return subverseDataModelLegacy
    }
    
    private func getSubLinkCellVmInitDataFromV1DataModel(dataModel: SubmissionDataModelV1) -> SubmissionLinkCellViewModelInitData {
        
        var subLinkCellVmInitData = SubmissionLinkCellViewModelInitData()
        subLinkCellVmInitData.link = dataModel.url
        subLinkCellVmInitData.domainString = self.getLinkShortString(fromLink: dataModel.url)
        subLinkCellVmInitData.endpointString = self.getLinkEndpointString(fromLink: dataModel.url)
        subLinkCellVmInitData.thumbnailLink = dataModel.thumbnailUrl
        
        return subLinkCellVmInitData
    }
    
    // Submission Link-Content Init Data - Legacy
    private func getSubLinkCellVmInitDataFromLegacyDataModel(dataModel: SubmissionDataModelLegacy) -> SubmissionLinkCellViewModelInitData {
        
        var subLinkCellVmInitData = SubmissionLinkCellViewModelInitData()
        subLinkCellVmInitData.link = dataModel.messageContent
        subLinkCellVmInitData.domainString = self.getLinkShortString(fromLink: dataModel.messageContent)
        subLinkCellVmInitData.endpointString = self.getLinkEndpointString(fromLink: dataModel.messageContent)
        subLinkCellVmInitData.thumbnailLink = dataModel.thumbnailLink
        
        return subLinkCellVmInitData
    }
    
    private func getSubCellVmInitDataFromV1DataModel(dataModel: SubmissionDataModelV1) -> SubmissionCellViewModelInitData {
        var subCellVmInitData = SubmissionCellViewModelInitData()
        
        subCellVmInitData.voteCountTotal = dataModel.voteCountTotal
        subCellVmInitData.upvoteCount = dataModel.upvoteCount
        subCellVmInitData.downvoteCount = dataModel.downvoteCount
        subCellVmInitData.commentCount = dataModel.commentCount
        subCellVmInitData.titleString = dataModel.title
        
        // Get link short string description, based on Text/Link submission type
        switch dataModel.type.lowercased() {
        case "link":
            // get linkShortString "(abc.com)"
            subCellVmInitData.linkShortString = self.getLinkShortString(fromLink: dataModel.url)
            
        case "text":
            // get subverse "(/v/subverse)"
            subCellVmInitData.linkShortString = self.getSubverseShortString(subverse: dataModel.subverseName)
        default:
            // This should never be reached
            subCellVmInitData.linkShortString = ""
            break
        }
        
        // Get the date, expecting (eg): "2016-12-02T06:34:50.3834343" - note the T
        subCellVmInitData.date = self.getDateFromString(gmtString: dataModel.creationDateString)
        subCellVmInitData.thumbnailLink = dataModel.thumbnailUrl
        subCellVmInitData.username = dataModel.username
        subCellVmInitData.subverseName = dataModel.subverseName
        
        
        return subCellVmInitData
    }
    
    // Submission Cell Init Data - Legacy
    private func getSubCellVmInitDataFromLegacyDataModel(dataModel: SubmissionDataModelLegacy) -> SubmissionCellViewModelInitData {
        
        var subCellVmInitData = SubmissionCellViewModelInitData()
        subCellVmInitData.voteCountTotal = dataModel.voteCount
        subCellVmInitData.upvoteCount = dataModel.upvoteCount
        subCellVmInitData.downvoteCount = dataModel.downvoteCount
        subCellVmInitData.commentCount = dataModel.commentCount
        subCellVmInitData.titleString = dataModel.title
        
        // Get link short string description, based on Text/Link submission type
        switch dataModel.type {
        case SubmissionType.link.rawValue:
            // get linkShortString "(abc.com)"
            subCellVmInitData.linkShortString = self.getLinkShortString(fromLink: dataModel.messageContent)
            
        case SubmissionType.text.rawValue:
            // get subverse "(/v/subverse)"
            subCellVmInitData.linkShortString = self.getSubverseShortString(subverse: dataModel.subverseName)
            
        default:
            // If no shortstring provided, leave blank
            subCellVmInitData.linkShortString = ""
        }
        
        // Get the date, expecting (eg): "2016-12-02T06:34:50.3834343" - note the T
        subCellVmInitData.date = self.getDateFromString(gmtString: dataModel.dateString)
        subCellVmInitData.thumbnailLink = dataModel.thumbnailLink
        subCellVmInitData.username = dataModel.username
        subCellVmInitData.subverseName = dataModel.subverseName
        subCellVmInitData.rank = dataModel.rank
        
        return subCellVmInitData
    }
    
    private func getThumbnailLink(voatURL: String, voatEndpoint: String?) -> String {
        guard voatEndpoint != "" && voatEndpoint != nil else {
            return ""
        }
        
        let thumbnailLink = voatURL + voatEndpoint!
        return thumbnailLink
    }
    
    private func getLinkShortString(fromLink httpString: String) -> String {
        var filteredString = ""
        
        let http = "http:"
        let https = "https:"
        let slashslash = "//"
        let www = "www."
        
        filteredString = httpString.replacingOccurrences(of: http, with: "")
        filteredString = filteredString.replacingOccurrences(of: https, with: "")
        filteredString = filteredString.replacingOccurrences(of: slashslash, with: "")
        filteredString = filteredString.replacingOccurrences(of: www, with: "")
        
        let separatedStrings = filteredString.components(separatedBy: "/")
        
        var linkShortString = separatedStrings[0]
        linkShortString = "\(linkShortString)"
        
        return linkShortString
    }
    
    private func getLinkEndpointString(fromLink httpString: String) -> String {
        var filteredString = ""
        
        let http = "http:"
        let https = "https:"
        let slashslash = "//"
        let www = "www."
        
        filteredString = httpString.replacingOccurrences(of: http, with: "")
        filteredString = filteredString.replacingOccurrences(of: https, with: "")
        filteredString = filteredString.replacingOccurrences(of: slashslash, with: "")
        filteredString = filteredString.replacingOccurrences(of: www, with: "")
        
        let separatedStrings = filteredString.components(separatedBy: "/")
        
        var endpointString = ""
        for i in 1..<separatedStrings.count {
            endpointString += "/" + separatedStrings[i]
        }
        
        return endpointString
    }
    
    private func getSubverseShortString(subverse: String) -> String {
        // eg: (/v/whatever)
        let subverseString = "(/v/\(subverse))"
        
        return subverseString
    }
    
    // Param expecting (eg): "2016-12-02T06:34:50.3834343" - note the T
    private func getDateFromString(gmtString: String) -> Date {
        let index = gmtString.index(gmtString.startIndex, offsetBy: 19)
        let truncatedDateString = gmtString.substring(to: index)
        let prunedGMTDateString = truncatedDateString.replacingOccurrences(of: "T", with: " ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let gmtDate = dateFormatter.date(from: prunedGMTDateString) {
            return gmtDate
        } else {
            #if DEBUG
                print("Warning: Date conversion FAILED.")
            #endif
            return Date()
        }
    }

}
