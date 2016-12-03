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
    
    init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    
    func requestSubverseSubmissions(completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void) -> Void {
        
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
        
        // TODO: Thumbnail string takes more work
        subCellVmInitData.thumbnailString = "(coming.soon)"
        
        subCellVmInitData.thumbnailLink = dataModel.thumbnailLink
        subCellVmInitData.username = dataModel.username
        subCellVmInitData.username = dataModel.subverseName
        
        return subCellVmInitData
    }
}
