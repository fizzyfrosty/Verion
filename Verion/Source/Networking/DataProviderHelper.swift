//
//  DataProviderHelper.swift
//  Verion
//
//  Created by Simon Chen on 12/15/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwiftyJSON

class DataProviderHelper {
    
    
    private let VOAT_THUMBNAIL_URL = "https://cdn.voat.co/thumbs/"
    let API_V1_NOTSUPPORTED_ERROR_MESSAGE = "API.v1 not yet implemented"
    
    
    func getSubTitleCellVmInitData(fromDataModel dataModel: SubmissionDataModelProtocol) -> SubmissionTitleCellViewModelInitData {
        let subTitleCellVmInitData: SubmissionTitleCellViewModelInitData
        
        switch dataModel.apiVersion {
        case .legacy:
            subTitleCellVmInitData = self.getSubmissionTitleCellViewModelInitDataFromLegacyDataModel(dataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            fatalError(self.API_V1_NOTSUPPORTED_ERROR_MESSAGE)
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
            fatalError(self.API_V1_NOTSUPPORTED_ERROR_MESSAGE)
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
            fatalError(self.API_V1_NOTSUPPORTED_ERROR_MESSAGE)
        }
        
        return subLinkCellVmInitData
    }
    
    func getSubmissionMediaType(fromDataModel dataModel: SubmissionDataModelProtocol) -> SubmissionMediaType {
        var mediaType = SubmissionMediaType.none
        
        switch dataModel.apiVersion {
        case .legacy:
            mediaType = self.getSubmissionMediaTypeFromLegacyDataModel(submissionDataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            fatalError(self.API_V1_NOTSUPPORTED_ERROR_MESSAGE)
        }
        
        return mediaType
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
    
    private func getSubmissionMediaTypeFromLegacyDataModel(submissionDataModel: SubmissionDataModelLegacy) -> SubmissionMediaType {
        
        // TODO: implement
        var legacyMediaType: SubmissionMediaType = .none
        
        // If data model is text, return text.
        if submissionDataModel.type == SubmissionType.text.rawValue {
            legacyMediaType = .text
        } else {
            // If it is link..., make a request, get the content type back from the request
            
            // Parse the content type returned, jpg, png, gif, etc.
            
            // Set and return
            
            legacyMediaType = .link
        }
        
        return legacyMediaType
    }
    
    func getSubmissionDataModel(fromJson json: JSON) -> SubmissionDataModelProtocol {
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
        submissionDataModel.thumbnailLink = self.getThumbnailLink(voatURL: self.VOAT_THUMBNAIL_URL, voatEndpoint: json["Thumbnail"].stringValue)
        submissionDataModel.title = json["Title"].stringValue
        submissionDataModel.type = json["Type"].intValue
        submissionDataModel.dateString = json["Date"].stringValue
        
        return submissionDataModel
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
            fatalError(self.API_V1_NOTSUPPORTED_ERROR_MESSAGE)
        }
        
        return subCellVmInitData
    }
    
    // MARK: - private methods
    private func getSubLinkCellVmInitDataFromLegacyDataModel(dataModel: SubmissionDataModelLegacy) -> SubmissionLinkCellViewModelInitData {
        
        var subLinkCellVmInitData = SubmissionLinkCellViewModelInitData()
        subLinkCellVmInitData.link = dataModel.messageContent
        subLinkCellVmInitData.domainString = self.getLinkShortString(fromLink: dataModel.messageContent)
        subLinkCellVmInitData.endpointString = self.getLinkEndpointString(fromLink: dataModel.messageContent)
        subLinkCellVmInitData.thumbnailLink = dataModel.thumbnailLink
        
        return subLinkCellVmInitData
    }
    
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
        
        let prunedGMTDateString = gmtString.replacingOccurrences(of: "T", with: " ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SS"
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
