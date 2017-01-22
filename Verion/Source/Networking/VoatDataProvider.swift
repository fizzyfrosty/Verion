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
    private let VOAT_API_KEY_PRIVATE_VALUE = "F80C9D5D732048E0B0928FCA8F71DA5AB8170FE1451B4967BD738D5F47C7CEC0"
    private let VOAT_V1_DOMAIN = "https://api.voat.co"
    private let CONTENT_TYPE_HEADER = "Content-Type"
    private let CONTENT_TYPE_AUTH_VALUE = "application/x-www-form-urlencoded"
    
    private var accessToken = ""
    private var refreshToken = ""
    
    
    private let VALIDATION_SUCCESSFUL_MESSAGE = "Validation successful"
    private let FRONTPAGE_SUBVERSE_NAME = "frontpage"
    private let ALL_SUBVERSE_NAME = "all"
    
    required init(apiVersion: APIVersion) {
        self.apiVersion = apiVersion
    }
    
    func requestLoginAuthentication(username: String, password: String, completion: @escaping (Error?) -> ()) {
        
        let requestUrlString = self.getAuthenticationUrlStringV1()
        let headers = self.getAuthenticationHeaders()
        let authParams = self.getAuthenticationParams(username: username, password: password)
        
        Alamofire.request(requestUrlString, method: .post, parameters: authParams, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response) in
            
            // FIXME: implement
            switch response.result {
            case .failure:
                completion(response.error)
            case .success:
                
                let jsonData = JSON.init(data: response.data!)
                self.accessToken = jsonData["access_token"].stringValue
                self.refreshToken = jsonData["refresh_token"].stringValue
                
                completion(nil)
            }
            
        }
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
        
        let requestUrlString = self.getSubverseListRequestUrlString(apiVersion: self.apiVersion)
        var jsonData: JSON?
        
        let headers = self.getHeaders(apiVersion: self.apiVersion)
        
        // Get data with Alamofire
        Alamofire.request(requestUrlString, headers: headers).validate().responseJSON() { response in
            
            var subverseDataModels = [SubverseSearchResultDataModelProtocol]()
            
            switch response.result {
            case .success:
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                subverseDataModels = self.dataProviderHelper.getSubverseSearchResultDataModels(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                // TODO: Implement error
                
                // Return the data models
                completion(subverseDataModels, nil)
            case .failure(let error):
                print(error)
                
                completion(subverseDataModels, error)
            }
        }
    }
    
    func requestComments(subverse: String, submissionId: Int64, completion: @escaping ([CommentDataModelProtocol], CommentDataSegmentProtocol?, Error?) -> Void) {
        var commentDataModels = [CommentDataModelProtocol]()
        
        let requestUrlString = self.getCommentsRequestUrlString(forSubverse: subverse, submissionId: submissionId, apiVersion: self.apiVersion)
        var jsonData: JSON?
        
        let headers = self.getHeaders(apiVersion: self.apiVersion)
        
        Alamofire.request(requestUrlString, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                commentDataModels = self.dataProviderHelper.getCommentDataModels(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                let commentDataSegment = self.dataProviderHelper.getCommentDataSegment(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                // TODO: Implement error
                
                // Return the data models
                completion(commentDataModels, commentDataSegment, nil)
            case .failure(let error):
                print(error)
                
                completion(commentDataModels, nil, error)
            }
        }
    }
    
    func requestChildComments(subverse: String, submissionId: Int64, parentId: Int64, startingIndex: Int, completion: @escaping ([CommentDataModelProtocol], CommentDataSegmentProtocol?, Error?) -> ()) {
        var commentDataModels = [CommentDataModelProtocol]()
        
        let requestUrlString = self.getChildCommentsRequestUrlString(forSubverse: subverse, submissionId: submissionId, parentId: parentId, startingIndex: startingIndex, apiVersion: self.apiVersion)
        var jsonData: JSON?
        
        let headers = self.getHeaders(apiVersion: self.apiVersion)
        
        Alamofire.request(requestUrlString, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                #if DEBUG
                    print(self.VALIDATION_SUCCESSFUL_MESSAGE)
                #endif
                
                jsonData = JSON.init(data: response.data!)
                
                commentDataModels = self.dataProviderHelper.getCommentDataModels(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                let commentDataSegment = self.dataProviderHelper.getCommentDataSegment(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                // TODO: Implement error
                
                // Return the data models
                completion(commentDataModels, commentDataSegment, nil)
            case .failure(let error):
                print(error)
                
                completion(commentDataModels, nil, error)
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
        
        // Make a request with the link. Check the mime type
        let mediaType = self.dataProviderHelper.getSubmissionMediaType(fromDataModel: submissionDataModel)
        
        return mediaType
    }
    
    private func getAuthenticationUrlStringV1() -> String {
        let urlString = "https://api.voat.co/oauth/token"
        
        return urlString
    }
    
    private func getCommentsUrlStringV1(forSubverse subverse: String, submissionID: Int64) -> String {
        let urlString = self.VOAT_V1_DOMAIN + "/api/v1/v/\(subverse)/\(String(submissionID))/comments"
        return urlString
    }
    
    private func getCommentsUrlStringLegacy(submissionId: Int64) -> String {
        let urlString = self.VOAT_GET_COMMENTS_FOR_SUBMISSION_URL_STRING + String(submissionId)
        
        return urlString
    }
    
    private func getSubverseListRequestUrlString(apiVersion: APIVersion) -> String {
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = self.getSubverseListRequestUrlStringLegacy()
        case .v1:
            urlString = self.getSubverseListRequestUrlStringV1()
        }
        
        return urlString
    }
    
    private func getSubverseListRequestUrlStringV1() -> String {
        let urlString = self.VOAT_V1_DOMAIN + "/api/v1/subverse/top"
        return urlString
    }
    
    private func getSubverseListRequestUrlStringLegacy() -> String {
        return self.VOAT_GET_TOP_200_SUBVERSE_NAMES_URL_STRING
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
        
        var subverseName = ""
        var sortTypeParam = ""
        var timeParam = "" // for the Top sort type
        
        switch submissionParams.subverseName {
        case self.FRONTPAGE_SUBVERSE_NAME:
            subverseName = "_front"
        case self.ALL_SUBVERSE_NAME:
            subverseName = "_any"
        default:
            subverseName = submissionParams.subverseName
        }
        
        
        sortTypeParam = "&sort=\(submissionParams.sortType.rawValue)"
        
        switch submissionParams.sortType {
        case .top:
            // Append a time query string if sorting by Top
            timeParam = "&span=\(submissionParams.topSortTypeTime.rawValue)"
        case .hot:
            sortTypeParam = "&sort=Rank"
        default:
            break
        }
        
        urlStringV1 = self.VOAT_V1_DOMAIN + "/api/v1/v/\(subverseName)?page=\(submissionParams.page)" + sortTypeParam + timeParam
        
        return urlStringV1
    }
    
    private func getChildCommentsRequestUrlString(forSubverse subverse: String, submissionId: Int64, parentId: Int64, startingIndex: Int, apiVersion: APIVersion) -> String {
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = ""
        case .v1:
            urlString = self.getCommentsUrlStringV1(forSubverse: subverse, submissionID: submissionId) + "/\(parentId)/\(startingIndex)"
        }
        
        return urlString
    }
    
    private func getCommentsRequestUrlString(forSubverse subverse: String, submissionId: Int64, apiVersion: APIVersion) -> String {
        
        var urlString: String = ""
        switch apiVersion {
        case .legacy:
            urlString = self.getCommentsUrlStringLegacy(submissionId: submissionId)
        case .v1:
            urlString = self.getCommentsUrlStringV1(forSubverse: subverse, submissionID: submissionId)
        }
        
        return urlString
    }
    
    private func getHeaders(apiVersion: APIVersion) -> HTTPHeaders {
        switch apiVersion {
        case .legacy:
            return [:]
        case .v1:
            return [self.VOAT_API_KEY_HEADER: self.VOAT_API_KEY_VALUE]
        }
    }
    
    private func getAuthenticationHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        
        headers[self.VOAT_API_KEY_HEADER] = self.VOAT_API_KEY_VALUE
        headers[self.CONTENT_TYPE_HEADER] = self.CONTENT_TYPE_AUTH_VALUE
        
        return headers
    }
    
    private func getAuthenticationParams(username: String, password: String) -> [String: Any]{
        var params: [String: Any] = [:]
        
        params["grant_type"] = "password"
        params["username"] = username
        params["password"] = password
        params["client_id"] = self.VOAT_API_KEY_VALUE
        params["client_secret"] = self.VOAT_API_KEY_PRIVATE_VALUE
        
        return params
    }
}
