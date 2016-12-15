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
    
    var dataProviderHelper = DataProviderHelper()
    
    let apiVersion: APIVersion?
    private let NUM_OF_TEST_DATA_CELLS = 6
    private let SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_LEGACY = "SampleJsonSubmissions_legacy"
    private let SAMPLE_FILES_EXTENSION = "txt"
    
    private let DELAY_TIME_SECONDS: Float = 1.0
    
    init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    
    func requestSubverseSubmissions(subverse: String, completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void) -> Void {
        
        // HeeHeeHee let's delay execution to simulate "lag"
        Delayer.delay(seconds: self.DELAY_TIME_SECONDS) {
            var submissionDataModels = [SubmissionDataModelProtocol]()
            
            // Load sample json data
            let sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_LEGACY,
                                                withExtension: self.SAMPLE_FILES_EXTENSION)
            
            // For each submission, create a datamodel
            for i in 0..<sampleJson.count {
                // Get data model from sample JSON
                let submissionJson = sampleJson[i]
                let submissionDataModel = self.dataProviderHelper.getSubmissionDataModel(fromJson: submissionJson)
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
        let subCellVmInitData = self.dataProviderHelper.getSubCellVmInitData(fromDataModel: dataModel)
        subCellViewModel.loadInitData(subCellVmInitData: subCellVmInitData)
    }
    
    func bind(subTitleViewModel: SubmissionTitleCellViewModel, dataModel: SubmissionDataModelProtocol) {
        
    }
    
    func bind(subTextCellViewModel: SubmissionTextCellViewModel, dataModel: SubmissionDataModelProtocol) {
        switch dataModel.apiVersion {
        case .legacy:
            let legacyDataModel = dataModel as! SubmissionDataModelLegacy
            subTextCellViewModel.textString = legacyDataModel.messageContent
        case .v1:
            fatalError(self.dataProviderHelper.API_V1_NOTSUPPORTED_ERROR_MESSAGE)
        }
    }
    
    func bind(subImageCellViewModel: SubmissionImageCellViewModel, dataModel: SubmissionDataModelProtocol) {
        let imageLink = self.dataProviderHelper.getImageLink(fromDataModel: dataModel)
        subImageCellViewModel.imageLink = imageLink
    }
    
    func bind(subLinkCellViewModel: SubmissionLinkCellViewModel, dataModel: SubmissionDataModelProtocol) {
        let subLinkCellVmInitData = self.dataProviderHelper.getSubLinkCellVmInitData(fromDataModel: dataModel)
        subLinkCellViewModel.loadInitData(subLinkCellVMInitData: subLinkCellVmInitData)
    }
    
    func requestComments(submissionId: Int, completion: @escaping ([CommentDataModelProtocol], Error?)->Void) -> Void {
        
    }
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType {
        
        let mediaType = self.dataProviderHelper.getSubmissionMediaType(fromDataModel: submissionDataModel)
        
        return mediaType
    }
    
}
