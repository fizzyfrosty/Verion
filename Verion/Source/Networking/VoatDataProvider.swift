//
//  VoatDataProvider.swift
//  Verion
//
//  Created by Simon Chen on 12/19/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class VoatDataProvider: DataProviderType {

    var dataProviderHelper = DataProviderHelper()
    var apiVersion: APIVersion = .legacy // default to be overwritten by initializer
    
    private let VOAT_GET_FRONTPAGE_100_SUBMISSIONS_URL_STRING = "https://voat.co/api/frontpage"
    private let VOAT_GET_TOP_200_SUBVERSE_NAMES_URL_STRING = "https://voat.co/api/top200subverses"
    private let VOAT_GET_SUBVERSE_SUBMISSIONS_URL_STRING = "https://voat.co/api/subversefrontpage?subverse="
    private let VOAT_GET_COMMENTS_FOR_SUBMISSION_URL_STRING = "https://voat.co/api/submissioncomments?submissionId="
    
    private let VALIDATION_SUCCESSFUL_MESSAGE = "Validation successful"
    
    private let FRONTPAGE_SUBVERSE_NAME = "frontpage"
    
    required init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    func requestContent(submissionDataModel: SubmissionDataModelProtocol, completion: @escaping (Data?, SubmissionMediaType, Error?) -> Void) {
        let requestUrlString = self.dataProviderHelper.getContentUrlString(fromSubmissionDataModel: submissionDataModel)
        
        Alamofire.request(requestUrlString).validate().responseData { responseData in
            switch responseData.result {
            case .success:
                var data: Data?
                var mediaType: SubmissionMediaType = .link
                // Check the mime type
                let mimeType = responseData.response?.mimeType
                let truncatedMimeType = (mimeType?.components(separatedBy: "/"))?[0]
                if truncatedMimeType == "image" {
                    mediaType = .image
                    
                    data = responseData.data
                }
                
                completion(data, mediaType, nil)
                
            case .failure(let error):
                completion(nil, SubmissionMediaType.link, error)
            }
        }
    }
    
    func requestSubverseSubmissions(subverse: String, completion: @escaping ([SubmissionDataModelProtocol], Error?) -> Void) {
        var submissionDataModels = [SubmissionDataModelProtocol]()
        
        var jsonData: JSON?
        
        var requestUrlString: String?
        
        switch subverse {
        case self.FRONTPAGE_SUBVERSE_NAME:
            requestUrlString = self.VOAT_GET_FRONTPAGE_100_SUBMISSIONS_URL_STRING
        default:
            requestUrlString = self.VOAT_GET_SUBVERSE_SUBMISSIONS_URL_STRING + subverse.lowercased()
        }
        
        // Get data with Alamofire
        Alamofire.request(requestUrlString!).validate().responseJSON() { response in
            switch response.result {
            case .success:
                
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                // For each submission, create a datamodel
                for i in 0..<jsonData!.count {
                    // Get data model from sample JSON
                    let submissionJson = jsonData![i]
                    let submissionDataModel = self.dataProviderHelper.getSubmissionDataModel(fromJson: submissionJson)
                    submissionDataModels.append(submissionDataModel)
                }
                
                // TODO: Implement error
                
                // Return the data models
                completion(submissionDataModels, nil)
                
            case .failure(let error):
                print(error)
                
                completion(submissionDataModels, error)
            }
        }
    }
    
    func requestSubverseList(completion: @escaping ([SubverseSearchResultDataModelProtocol], Error?) -> Void) {
        
        // Get data with Alamofire
        Alamofire.request(self.VOAT_GET_TOP_200_SUBVERSE_NAMES_URL_STRING).validate().responseJSON() { response in
            
            var subverseDataModels = [SubverseSearchResultDataModelProtocol]()
            var jsonData: JSON?
            
            switch response.result {
            case .success:
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                // For each submission, create a data model
                for i in 0..<jsonData!.count {
                    // Get data model from sample JSON
                    let subverseJson = jsonData![i]
                    let subverseDataModel = self.dataProviderHelper.getSubverseDataModel(fromJson: subverseJson, apiVersion: self.apiVersion)
                    subverseDataModels.append(subverseDataModel)
                }
                
                // TODO: Implement error
                
                // Return the data models
                completion(subverseDataModels, nil)
            case .failure(let error):
                print(error)
                
                completion(subverseDataModels, error)
            }
        }
    }
    
    func requestComments(submissionId: Int64, completion: @escaping ([CommentDataModelProtocol], Error?) -> Void) {
        var commentDataModels = [CommentDataModelProtocol]()
        
        let requestUrlString = self.VOAT_GET_COMMENTS_FOR_SUBMISSION_URL_STRING + String(submissionId)
        var jsonData: JSON?
        
        Alamofire.request(requestUrlString).validate().responseJSON { response in
            switch response.result {
            case .success:
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                // For each submission, create a data model
                for i in 0..<jsonData!.count {
                    
                    // Get data model from sample JSON
                    let commentJson = jsonData![i]
                    let commentDataModel = self.dataProviderHelper.getCommentDataModel(fromJson: commentJson, apiVersion: self.apiVersion)
                    commentDataModels.append(commentDataModel)
                }
                
                // TODO: Implement error
                
                // Return the data models
                completion(commentDataModels, nil)
            case .failure(let error):
                print(error)
                
                completion(commentDataModels, error)
            }
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
        let subTitleCellVmInitData = self.dataProviderHelper.getSubTitleCellVmInitData(fromDataModel: dataModel)
        subTitleViewModel.loadInitData(subTitleCellVMInitData: subTitleCellVmInitData)
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
    
    func bind(subverseSearchResultCellViewModel: SubverseSearchResultCellViewModel, dataModel: SubverseSearchResultDataModelProtocol) {
        let subverseSearchResultCellVmInitData = self.dataProviderHelper.getSubverseSearchResultCellVmInitData(fromDataModel: dataModel)
        subverseSearchResultCellViewModel.loadInitData(initData: subverseSearchResultCellVmInitData)
    }
    
    func bind(commentCellViewModel: CommentCellViewModel, dataModel: CommentDataModelProtocol) {
        let commentCellVmInitData = self.dataProviderHelper.getCommentCellVmInitData(fromDataModel: dataModel)
        commentCellViewModel.loadInitData(initData: commentCellVmInitData)
    }
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType {
        
        // Make a request with the link. Check the mime type
        let mediaType = self.dataProviderHelper.getSubmissionMediaType(fromDataModel: submissionDataModel)
        
        return mediaType
    }
}
