//
//  OfflineDataProvider.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import SwiftyJSON

class OfflineDataProvider: DataProviderType {
    
    let apiVersion: APIVersion?
    private let NUM_OF_TEST_DATA_CELLS = 6
    private let SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_LEGACY = "SampleJsonSubmissions_legacy"
    private let SAMPLE_FILES_EXTENSION = "txt"
    private let VOAT_THUMBNAIL_URL = "https://cdn.voat.co/thumbs/"
    private let DELAY_TIME_SECONDS: Float = 2.0
    
    init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    
    func requestSubverseSubmissions(subverse: String, completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void) -> Void {
        
        // HeeHeeHee let's delay execution to simulate "lag"
        Delayer.delay(seconds: self.DELAY_TIME_SECONDS) {
            var submissionDataModels = [SubmissionDataModelProtocol]()
            
            // Load sample json data
            let sampleJson = self.getSampleJson(filename: self.SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_LEGACY,
                                                withExtension: self.SAMPLE_FILES_EXTENSION)
            
            // For each submission, create a datamodel
            for i in 0..<sampleJson.count {
                // Get data model from sample JSON
                let submissionJson = sampleJson[i]
                let submissionDataModel = self.getSubmissionDataModel(fromJson: submissionJson)
                submissionDataModels.append(submissionDataModel)
            }
            
            // TODO: Implement error return in a mock object?
            
            // Return the data models
            completion(submissionDataModels, nil)
        }
    }
    
    func bind(subCellViewModel: SubmissionCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void {
        
        // TODO: UPVOTE/DOWNVOTE feature isn't supported by legacy api. Will do later when I get new API key
        // The viewModel dictates what requests are made: upvote, downvote
        // Bind upvote event to request
        // Bind downvote event to request
        
        // Initialize the view model's values with data models
        let subCellVmInitData = self.getSubCellVmInitData(fromDataModel: dataModel)
        subCellViewModel.loadInitData(subCellVmInitData: subCellVmInitData)
    }
    
    private func getSubmissionDataModel(fromJson json: JSON) -> SubmissionDataModelProtocol {
        let submissionDataModel = SubmissionDataModelLegacy()
        
        submissionDataModel.commentCount = json["CommentCount"].intValue
        submissionDataModel.dateString = json["Date"].stringValue
        submissionDataModel.downvoteCount = json["Dislikes"].intValue
        submissionDataModel.upvoteCount = json["Likes"].intValue
        submissionDataModel.id = json["Id"].int64Value
        submissionDataModel.lastEditDateString = json["LastEditDate"].stringValue
        submissionDataModel.linkDescription = json["Linkdescription"].stringValue
        submissionDataModel.messageContent = json["MessageContent"].stringValue
        submissionDataModel.username = json["Name"].stringValue
        submissionDataModel.rank = json["Rank"].doubleValue
        submissionDataModel.subverseName = json["Subverse"].stringValue
        submissionDataModel.thumbnailLink = json["Thumbnail"].stringValue
        submissionDataModel.title = json["Title"].stringValue
        submissionDataModel.type = json["Type"].intValue
        submissionDataModel.dateString = json["Date"].stringValue
        
        return submissionDataModel
    }
    
    private func getSampleJson(filename: String, withExtension ext: String) -> JSON {
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
    
    
    private func getSubCellVmInitData(fromDataModel dataModel:SubmissionDataModelProtocol) -> SubmissionCellViewModelInitData {
        let subCellVmInitData: SubmissionCellViewModelInitData
        
        // Correctly cast
        switch dataModel.apiVersion {
        case .legacy:
            subCellVmInitData = self.getSubCellVmInitDataFromLegacyDataModel(dataModel: dataModel as! SubmissionDataModelLegacy)
        case .v1:
            fatalError("API.v1 not yet implemented")
        }
        
        return subCellVmInitData
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
        subCellVmInitData.thumbnailLink = self.getThumbnailLink(voatURL: self.VOAT_THUMBNAIL_URL, voatEndpoint: dataModel.thumbnailLink)
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
        linkShortString = "(\(linkShortString))"
        
        return linkShortString
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
