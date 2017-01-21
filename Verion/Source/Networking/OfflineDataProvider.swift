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
    
    var apiVersion: APIVersion = .legacy // default to be overwritten by initializer
    private let SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_LEGACY = "SampleJsonSubmissions_legacy"
    private let SAMPLE_JSON_SUBVERSE_LIST_DATA_FILE_LEGACY = "SampleSubverseList_legacy"
    private let SAMPLE_JSON_COMMENTS_FILE_LEGACY = "SampleComments_legacy"
    private let SAMPLE_FILES_EXTENSION = "txt"
    
    private let SAMPLE_JSON_COMMENTS_FILE_V1 = "SampleComments_v1"
    private let SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_V1 = "SampleJsonSubmissions_v1"
    private let SAMPLE_JSON_SUBVERSE_LIST_DATA_FILE_V1 = "SampleSubverseList_v1"
    
    private let DELAY_TIME_SECONDS: Float = 1.0
    private let SEARCH_RESULTS_DELAY_TIME: Float = 0.25
    
    required init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    func requestLoginAuthentication(username: String, password: String, completion: @escaping (Error?) -> ()) {
        Delayer.delay(seconds: self.DELAY_TIME_SECONDS) { 
            
            // Return error if empty password
            if password == "" {
                let error = NSError.init()
                completion(error)
            } else {
                // Return success if filled password
                completion(nil)
            }
        }
    }
    
    func requestContent(submissionDataModel: SubmissionDataModelProtocol, downloadProgress: @escaping (Double)->(), completion: @escaping (Data?, SubmissionMediaType, Bool, Error?) -> Void) {
        completion(nil, SubmissionMediaType.link, false, nil)
    }
    
    func requestSubverseSubmissions(submissionParams: SubmissionsRequestParams, completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void) -> Void {
        
        // HeeHeeHee let's delay execution to simulate "lag"
        Delayer.delay(seconds: self.DELAY_TIME_SECONDS) {
            var submissionDataModels = [SubmissionDataModelProtocol]()
            
            // Load sample json data
            let sampleJson: JSON
            switch self.apiVersion {
            case .legacy:
                sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_LEGACY, withExtension: self.SAMPLE_FILES_EXTENSION)
            case .v1:
                sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_SUBVERSE_SUBMISSIONS_DATA_FILE_V1, withExtension: self.SAMPLE_FILES_EXTENSION)
            }
            
            submissionDataModels = self.dataProviderHelper.getSubmissionDataModels(fromJson: sampleJson, apiVersion: self.apiVersion)
            
            // TODO: Implement error return in a mock object?
            
            // Return the data models
            completion(submissionDataModels, nil)
        }
    }
    
    func requestSubverseList(completion: @escaping ([SubverseSearchResultDataModelProtocol], Error?) -> Void) {
        Delayer.delay(seconds: self.SEARCH_RESULTS_DELAY_TIME) {
            var subverseDataModels = [SubverseSearchResultDataModelProtocol]()
            
            // Load sample json data
            let sampleJson: JSON
            switch self.apiVersion {
            case .legacy:
                sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_SUBVERSE_LIST_DATA_FILE_LEGACY, withExtension: self.SAMPLE_FILES_EXTENSION)
            case .v1:
                sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_SUBVERSE_LIST_DATA_FILE_V1, withExtension: self.SAMPLE_FILES_EXTENSION)
            }
            
            subverseDataModels = self.dataProviderHelper.getSubverseSearchResultDataModels(fromJson: sampleJson, apiVersion: self.apiVersion)
            
            // TODO: Implement error return in a mock object?
            
            // Return the data models
            completion(subverseDataModels, nil)
        }
    }
    
    func requestComments(subverse: String, submissionId: Int64, completion: @escaping ([CommentDataModelProtocol], CommentDataSegmentProtocol?, Error?)->Void) -> Void {
        Delayer.delay(seconds: self.DELAY_TIME_SECONDS) {
            var commentDataModels = [CommentDataModelProtocol]()
            let _: CommentDataSegmentProtocol
            
            // Load sample json data
            let sampleJson: JSON
            switch self.apiVersion {
            case .legacy:
                sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_COMMENTS_FILE_LEGACY, withExtension: self.SAMPLE_FILES_EXTENSION)
            case .v1:
                sampleJson = self.dataProviderHelper.getSampleJson(filename: self.SAMPLE_JSON_COMMENTS_FILE_V1, withExtension: self.SAMPLE_FILES_EXTENSION)
            }
            
            commentDataModels = self.dataProviderHelper.getCommentDataModels(fromJson: sampleJson, apiVersion: self.apiVersion)
            
            
            // Return the data models
            completion(commentDataModels, nil, nil)
            
        }
    }
    
    func requestChildComments(subverse: String, submissionId: Int64, parentId: Int64, startingIndex: Int, completion: @escaping ([CommentDataModelProtocol], CommentDataSegmentProtocol?, Error?) -> ()) {
        
        let commentDataModels: [CommentDataModelProtocol] = []
        let commentDataSegment: CommentDataSegmentProtocol? = nil
        
        completion(commentDataModels, commentDataSegment, nil)
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
        let subTitleCellVmInitData = self.dataProviderHelper.getSubTitleCellVmInitData(fromDataModel: dataModel)
        subTitleViewModel.loadInitData(subTitleCellVMInitData: subTitleCellVmInitData)
    }
    
    func bind(subTextCellViewModel: SubmissionTextCellViewModel, dataModel: SubmissionDataModelProtocol) {
        switch dataModel.apiVersion {
        case .legacy:
            let legacyDataModel = dataModel as! SubmissionDataModelLegacy
            subTextCellViewModel.textString = legacyDataModel.messageContent
        case .v1:
            let v1DataModel = dataModel as! SubmissionDataModelV1
            subTextCellViewModel.textString = v1DataModel.content
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
    
    func bind(subverseSearchResultCellViewModel: SubverseSearchResultCellViewModel, dataModel: SubverseSearchResultDataModelProtocol) {
        let subverseSearchResultCellVmInitData = self.dataProviderHelper.getSubverseSearchResultCellVmInitData(fromDataModel: dataModel)
        subverseSearchResultCellViewModel.loadInitData(initData: subverseSearchResultCellVmInitData)
    }
    
    func bind(commentCellViewModel: CommentCellViewModel, dataModel: CommentDataModelProtocol) {
        let commentCellVmInitData = self.dataProviderHelper.getCommentCellVmInitData(fromDataModel: dataModel)
        commentCellViewModel.loadInitData(initData: commentCellVmInitData)
    }
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType {
        let mediaType = self.dataProviderHelper.getSubmissionMediaType(fromDataModel: submissionDataModel)
        
        return mediaType
    }
    
}
