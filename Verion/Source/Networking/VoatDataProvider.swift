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
    private let VOAT_API_KEY_VALUE = OAuth2Handler.CLIENT_ID
    private let VOAT_API_KEY_PRIVATE_VALUE = OAuth2Handler.CLIENT_SECRET
    private let VOAT_V1_DOMAIN = "https://api.voat.co"
    private let CONTENT_TYPE_HEADER = "Content-Type"
    private let CONTENT_TYPE_AUTH_VALUE = "application/x-www-form-urlencoded"
    
    
    private let VALIDATION_SUCCESSFUL_MESSAGE = "Validation successful"
    private let FRONTPAGE_SUBVERSE_NAME = "frontpage"
    private let ALL_SUBVERSE_NAME = "all"
    
    private var sessionManager: SessionManager?
    
    
    // Dependencies
    private var loginScreen: LoginScreenProtocol?
    
    required init(apiVersion: APIVersion, loginScreen: LoginScreenProtocol) {
        self.apiVersion = apiVersion
        self.loginScreen = loginScreen
    }
    
    func requestSubmitTopLevelComment(subverseName: String, submissionId: Int64, comment: String, completion: @escaping (CommentDataModelProtocol?, Error?) -> ()) {
        
        
    }
    
    func requestSubmitCommentReply(subverseName: String, submissionId: Int64, commentId: Int64, comment: String, completion: @escaping (CommentDataModelProtocol?, Error?) -> ()) {
        
        // FIXME: Implement
    }
    
    func requestCommentVote(commentId: Int64, voteValue: Int, rootViewController: UIViewController, completion: @escaping (Error?) -> ()) {
        let requestCommentVoteClosure: ()->() = {
            self.sessionManager = self.getSessionManager()
            let urlString = self.getCommentVoteUrlString(commentId: commentId, voteType: voteValue, apiVersion: self.apiVersion)
            
            self.sessionManager!.request(urlString, method: .post).validate().responseJSON { (response) in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
        
        // Check for accesstoken and prompt for login
        if OAuth2Handler.sharedInstance.accessToken == "" {
            self.loginScreen?.presentLogin(rootViewController: rootViewController, showConfirmation: true, completion: { (username, error) in
                
                guard error == nil else {
                    // Failed to log in
                    completion(error)
                    return
                }
                
                // Success
                requestCommentVoteClosure()
            })
        } else {
            // Already signed in
            requestCommentVoteClosure()
        }
        
    }
    
    func requestSubmissionVote(submissionId: Int64, voteValue: Int, rootViewController: UIViewController, completion: @escaping (Error?) -> ()) {
        
        let requestSubmissionVoteClosure: ()->() = {
            self.sessionManager = self.getSessionManager()
            let urlString = self.getSubmissionVoteUrlString(submissionId: submissionId, voteType: voteValue, apiVersion: self.apiVersion)
            
            self.sessionManager!.request(urlString, method: .post).validate().responseJSON { (response) in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
        
        // Check for accesstoken and prompt for login
        if OAuth2Handler.sharedInstance.accessToken == "" {
            self.loginScreen?.presentLogin(rootViewController: rootViewController, showConfirmation: true, completion: { (username, error) in
                
                guard error == nil else {
                    // Failed to log in
                    completion(error)
                    return
                }
                
                // Success
                requestSubmissionVoteClosure()
            })
            
        } else {
            // Already signed in
            requestSubmissionVoteClosure()
        }
    }
    
    // This method is not used. Access OAuthSwiftAuthenticator for online login
    func requestLoginAuthentication(username: String, password: String, completion: @escaping (_ accessToken: String, _ refreshToken: String, Error?) -> ()) {
        // Do not use. Resource Owner Credentials access is not permitted.
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
                                
                // Return the data models
                completion(commentDataModels, commentDataSegment, nil)
            case .failure(let error):
                print(error)
                
                completion(commentDataModels, nil, error)
            }
        }
    }
    
    func bind(subCellViewModel: SubmissionCellViewModel, dataModel: SubmissionDataModelProtocol, viewController: UIViewController) -> Void {
        
        // Initialize the view model's values with data models
        let subCellVmInitData = self.dataProviderHelper.getSubCellVmInitData(fromDataModel: dataModel)
        subCellViewModel.loadInitData(subCellVmInitData: subCellVmInitData)
        
        subCellViewModel.resetDataProviderBindings()
        
        // Bind upvote event to request
        subCellViewModel.dataProviderBindings.append( subCellViewModel.didRequestUpvote.observeNext { [weak self] (didRequestUpvote) in
            if didRequestUpvote {
                
                self?.requestSubmissionVote(submissionId: (subCellViewModel.dataModel?.id)!, voteValue: VoteType.up.rawValue, rootViewController: viewController, completion: { (error) in
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Upvote")
                        #endif
                        subCellViewModel.didRequestUpvote.value = false
                        subCellViewModel.isUpvoted.value = false
                        return
                    }
                    
                    // Success
                    subCellViewModel.isUpvoted.value = true
                    
                    #if DEBUG
                        print("Response received: Upvote")
                    #endif
                })
                
            }
        })
        
        // Bind downvote event to request
        subCellViewModel.dataProviderBindings.append( subCellViewModel.didRequestDownvote.observeNext { [weak self] didRequestDownvote in
            if didRequestDownvote {
                
                self?.requestSubmissionVote(submissionId: (subCellViewModel.dataModel?.id)!, voteValue: VoteType.down.rawValue, rootViewController: viewController, completion: { (error) in
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Downvote")
                        #endif
                        subCellViewModel.didRequestDownvote.value = false
                        subCellViewModel.isDownvoted.value = false
                        return
                    }
                    
                    // Success
                    subCellViewModel.isDownvoted.value = true
                    
                    #if DEBUG
                        print("Response received: Downvote")
                    #endif
                })
            }
        })
        
        subCellViewModel.dataProviderBindings.append( subCellViewModel.didRequestNoVote.observeNext { [weak self] didRequestNoVote in
            if didRequestNoVote {
                self?.requestSubmissionVote(submissionId: (subCellViewModel.dataModel?.id)!, voteValue: VoteType.none.rawValue, rootViewController: viewController, completion: { (error) in
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: NoVote")
                        #endif
                        return
                    }
                    
                    // Success
                    subCellViewModel.isUpvoted.value = false
                    subCellViewModel.isDownvoted.value = false
                    #if DEBUG
                        print("Response received: NoVote")
                    #endif
                })
            }
        })
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
    
    func bindTopLevelCommentViewModel(commentCellViewModel: CommentCellViewModel, dataModel: CommentDataModelProtocol) {
        let commentCellVmInitData = self.dataProviderHelper.getCommentCellVmInitData(fromDataModel: dataModel)
        commentCellViewModel.loadInitData(initData: commentCellVmInitData)
    }
    
    func bind(commentCellViewModel: CommentCellViewModel, viewController: UIViewController) {
        commentCellViewModel.resetDataProviderBindings()
        
        // Bind upvote event to request
        commentCellViewModel.dataProviderBindings.append( commentCellViewModel.didRequestUpvote.observeNext { [weak self] (didRequestUpvote) in
            if didRequestUpvote {
                
                self?.requestCommentVote(commentId: commentCellViewModel.id, voteValue: VoteType.up.rawValue, rootViewController: viewController, completion: { (error) in
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Upvote")
                        #endif
                        commentCellViewModel.didRequestUpvote.value = false
                        commentCellViewModel.isUpvoted.value = false
                        return
                    }
                    
                    // Success
                    commentCellViewModel.isUpvoted.value = true
                    
                    #if DEBUG
                        print("Response received: Upvote")
                    #endif
                })
                
            }
        })
        
        // Bind downvote event to request
        commentCellViewModel.dataProviderBindings.append( commentCellViewModel.didRequestDownvote.observeNext { [weak self] didRequestDownvote in
            if didRequestDownvote {
                
                self?.requestCommentVote(commentId: commentCellViewModel.id, voteValue: VoteType.down.rawValue, rootViewController: viewController, completion: { (error) in
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Downvote")
                        #endif
                        commentCellViewModel.didRequestDownvote.value = false
                        commentCellViewModel.isDownvoted.value = false
                        return
                    }
                    
                    // Success
                    commentCellViewModel.isDownvoted.value = true
                    
                    #if DEBUG
                        print("Response received: Downvote")
                    #endif
                })
            }
        })
        
        commentCellViewModel.dataProviderBindings.append( commentCellViewModel.didRequestNoVote.observeNext { [weak self] didRequestNoVote in
            if didRequestNoVote {
                self?.requestCommentVote(commentId: commentCellViewModel.id, voteValue: VoteType.none.rawValue, rootViewController: viewController, completion: { (error) in
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: NoVote")
                        #endif
                        return
                    }
                    
                    // Success
                    commentCellViewModel.isUpvoted.value = false
                    commentCellViewModel.isDownvoted.value = false
                    #if DEBUG
                        print("Response received: NoVote")
                    #endif
                })
            }
        })
    }
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType {
        
        // Make a request with the link. Check the mime type
        let mediaType = self.dataProviderHelper.getSubmissionMediaType(fromDataModel: submissionDataModel)
        
        return mediaType
    }
    
    // MARK: - Private functions
    
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
    
    private func getSubmissionVoteUrlString(submissionId: Int64, voteType: Int, apiVersion: APIVersion) -> String{
        let type = "submission"
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = "" // Unsupported
        case .v1:
            urlString = self.VOAT_V1_DOMAIN + "/api/v1/vote/\(type)/\(submissionId)/\(voteType)?revokeOnRevote=false"
        }
        
        return urlString
    }
    
    private func getCommentVoteUrlString(commentId: Int64, voteType: Int, apiVersion: APIVersion) -> String {
        let type = "comment"
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = "" // Unsupported
        case .v1:
            urlString = self.VOAT_V1_DOMAIN + "/api/v1/vote/\(type)/\(commentId)/\(voteType)?revokeOnRevote=false"
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
    
    private func getSessionManager() -> SessionManager {
        let sessionManager = SessionManager()
        
        sessionManager.adapter = OAuth2Handler.sharedInstance
        sessionManager.retrier = OAuth2Handler.sharedInstance
        
        return sessionManager
    }
    
}
