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
    
    // Legacy API
    private let VOAT_GET_FRONTPAGE_100_SUBMISSIONS_URL_STRING = "https://voat.co/api/frontpage"
    private let VOAT_GET_TOP_200_SUBVERSE_NAMES_URL_STRING = "https://voat.co/api/top200subverses"
    private let VOAT_GET_SUBVERSE_SUBMISSIONS_URL_STRING = "https://voat.co/api/subversefrontpage?subverse="
    private let VOAT_GET_COMMENTS_FOR_SUBMISSION_URL_STRING = "https://voat.co/api/submissioncomments?submissionId="
    
    // V1 API
    private let VOAT_API_KEY_HEADER = "Voat-ApiKey"
    private let VOAT_API_KEY_VALUE = "VO0FEEE221244B41B7B3686098AA4EA227AT"
    private let VOAT_V1_DOMAIN = "https://api.voat.co"
    
    
    private let VALIDATION_SUCCESSFUL_MESSAGE = "Validation successful"
    private let FRONTPAGE_SUBVERSE_NAME = "frontpage"
    
    required init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    func requestContent(submissionDataModel: SubmissionDataModelProtocol, downloadProgress: @escaping (Double)->(), completion: @escaping (Data?, SubmissionMediaType, Bool, Error?) -> Void) {
        let requestUrlString = self.dataProviderHelper.getContentUrlString(fromSubmissionDataModel: submissionDataModel)
        
        // --------To download a file to device, need to specify destination:
        // http://stackoverflow.com/questions/39490390/alamofire-download-issue
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("tempFile")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
        // ----------------------------------------------------------
        
        
        Alamofire.download(requestUrlString, to: destination).downloadProgress {(progress) in
            downloadProgress(progress.fractionCompleted)
        }
        .responseData { (response) in
            
            if let data = response.result.value {
                var mediaType: SubmissionMediaType = .link
                var isGif: Bool = false
                
                // Check the mime type
                let mimeType = response.response?.mimeType
                let mimeComponents = mimeType?.components(separatedBy: "/")
                let generalMimeType = mimeComponents?[0]
                let detailedMimeType = mimeComponents?[1]
                
                // Only return data (imageData) if it was an image
                if generalMimeType == "image" {
                    mediaType = .image
                    
                    if detailedMimeType == "gif" {
                        isGif = true
                    } else {
                        isGif = false
                    }
                    
                    //data = response.result.value
                }
                
                completion(data, mediaType, isGif, nil)
            } else {
                completion(nil, SubmissionMediaType.link, false, response.result.error)
            }
        }
    }
    
    func requestSubverseSubmissions(submissionParams: SubmissionsRequestParams, completion: @escaping ([SubmissionDataModelProtocol], Error?) -> Void) {
        var submissionDataModels = [SubmissionDataModelProtocol]()
        
        var jsonData: JSON?
        
        let requestUrlString = self.getSubverseSubmissionsRequestUrlString(submissionParams: submissionParams, apiVersion: self.apiVersion)
        
        let headers = self.getHeaders(apiVersion: self.apiVersion)
        
        // Get data with Alamofire
        Alamofire.request(requestUrlString, headers: headers).validate().responseJSON() { response in
            switch response.result {
            case .success:
                
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                submissionDataModels = self.dataProviderHelper.getSubmissionDataModels(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                
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
                    let subverseDataModel = self.dataProviderHelper.getSubverseSearchResultDataModel(fromJson: subverseJson, apiVersion: self.apiVersion)
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
    
    func requestComments(subverse: String, submissionId: Int64, completion: @escaping ([CommentDataModelProtocol], Error?) -> Void) {
        var commentDataModels = [CommentDataModelProtocol]()
        
        let requestUrlString = self.getCommentsUrlStringV1(forSubverse: subverse, submissionID: submissionId)
        var jsonData: JSON?
        
        let headers: HTTPHeaders = [
            self.VOAT_API_KEY_HEADER: self.VOAT_API_KEY_VALUE
        ]
        
        Alamofire.request(requestUrlString, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                commentDataModels = self.dataProviderHelper.getCommentDataModels(fromJson: jsonData!, apiVersion: self.apiVersion)
                
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
    
    private func getCommentsUrlStringV1(forSubverse subverse: String, submissionID: Int64) -> String {
        let urlString = self.VOAT_V1_DOMAIN + "/api/v1/v/\(subverse)/\(String(submissionID))/comments"
        return urlString
    }
    
    private func getSubverseSubmissionsRequestUrlString(submissionParams: SubmissionsRequestParams, apiVersion: APIVersion) -> String {
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = self.getSubverseSubmissionsRequestUrlStringLegacy(submissionParams: submissionParams)
        case .v1:
            urlString = self.getSubverseSubmissionsRequestUrlStringV1(submissionParams: submissionParams)
        }
        
        return urlString
    }
    
    private func getSubverseSubmissionsRequestUrlStringLegacy(submissionParams: SubmissionsRequestParams) -> String {
        var legacyUrlString = ""
        let subverse = submissionParams.subverseName
        
        switch subverse {
        case self.FRONTPAGE_SUBVERSE_NAME:
            legacyUrlString = self.VOAT_GET_FRONTPAGE_100_SUBMISSIONS_URL_STRING
        default:
            legacyUrlString = self.VOAT_GET_SUBVERSE_SUBMISSIONS_URL_STRING + subverse.lowercased()
        }
        
        return legacyUrlString
    }
    
    private func getSubverseSubmissionsRequestUrlStringV1(submissionParams: SubmissionsRequestParams) -> String {
        var urlStringV1 = ""
        
        urlStringV1 = self.VOAT_V1_DOMAIN + "/api/v1/v/\(submissionParams.subverseName)?sort=\(submissionParams.sortType.rawValue)&page=\(submissionParams.page)"
        
        switch submissionParams.sortType {
        case .top:
            // Append a time query string if sorting by Top
            urlStringV1 = urlStringV1 + "&time=\(submissionParams.topSortTypeTime)"
        default:
            break
        }
        
        return urlStringV1
    }
    
    private func getHeaders(apiVersion: APIVersion) -> HTTPHeaders {
        switch apiVersion {
        case .legacy:
            return ["":""]
        case .v1:
            return [self.VOAT_API_KEY_HEADER: self.VOAT_API_KEY_VALUE]
        }
    }
}
