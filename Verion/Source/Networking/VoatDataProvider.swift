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
    
    private var _sessionManager: SessionManager?
    private var sessionManager: SessionManager {
        get {
         
            if _sessionManager == nil {
                _sessionManager = SessionManager()
            }
            
            _sessionManager?.adapter = OAuth2Handler.sharedInstance
            _sessionManager?.retrier = OAuth2Handler.sharedInstance
            
            return _sessionManager!
            
        }
    }
    
    enum VoteError: Error {
        case notEnoughCcp
        case unknown
    }
    
    
    // Dependencies
    private var loginScreen: LoginScreenProtocol?
    private var analyticsManager: AnalyticsManagerProtocol?
    
    required init(apiVersion: APIVersion, loginScreen: LoginScreenProtocol, analyticsManager: AnalyticsManagerProtocol) {
        self.apiVersion = apiVersion
        self.loginScreen = loginScreen
        self.analyticsManager = analyticsManager
    }
    
    func requestSubmitTopLevelComment(subverseName: String, submissionId: Int64, comment: String, completion: @escaping (CommentDataModelProtocol?, Error?) -> ()) {
        let submitCommentClosure: ()->() = {
            
            let urlString = self.getSubmitTopLevelCommentUrlString(subverse: subverseName, submissionId: submissionId, apiVersion: self.apiVersion)
            let params = self.getSubmitCommentParams(comment: comment, apiVersion: self.apiVersion)
            
            self.sessionManager.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { (response) in
                switch response.result {
                case .success:
                    // Parse response, get comment data model
                    let jsonData = JSON.init(data: response.data!)
                    let dataModel = self.dataProviderHelper.getCommentDataModelFromSubmitComment(fromJson: jsonData, apiVersion: self.apiVersion)
                    
                    completion(dataModel, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
        
        // No need to check for login here like in other requests. 
        // Submitting comments already require login before getting through UI
        submitCommentClosure()
    }
    
    func requestSubmitCommentReply(subverseName: String, submissionId: Int64, commentId: Int64, comment: String, completion: @escaping (CommentDataModelProtocol?, Error?) -> ()) {
        
        let submitCommentClosure: ()->() = {
            
            let urlString = self.getSubmitCommentReplyUrlString(subverse: subverseName, submissionId: submissionId, commentId: commentId, apiVersion: self.apiVersion)
            let params = self.getSubmitCommentParams(comment: comment, apiVersion: self.apiVersion)
            
            self.sessionManager.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { (response) in
                switch response.result {
                case .success:
                    // Parse response, get comment data model
                    let jsonData = JSON.init(data: response.data!)
                    let dataModel = self.dataProviderHelper.getCommentDataModelFromSubmitComment(fromJson: jsonData, apiVersion: self.apiVersion)
                    
                    completion(dataModel, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
        
        // No need to check for login here like in other requests.
        // Submitting comments already require login before getting through UI
        submitCommentClosure()
    }
    
    func requestCommentVote(commentId: Int64, voteValue: Int, rootViewController: UIViewController, completion: @escaping (VoteValue, Error?) -> ()) {
        let requestCommentVoteClosure: ()->() = {
            
            let urlString = self.getCommentVoteUrlString(commentId: commentId, voteType: voteValue, apiVersion: self.apiVersion)
            
            self.sessionManager.request(urlString, method: .post).validate().responseJSON { (response) in
                switch response.result {
                case .success:
                    
                    // Get vote value based on json response
                    let jsonData = JSON.init(data: response.data!)
                    let voteValue = self.dataProviderHelper.getVoteValue(fromJson: jsonData, apiVersion: self.apiVersion)
                    let isVoteSuccessful = self.dataProviderHelper.getIsVoteSuccessful(fromJson: jsonData, apiVersion: self.apiVersion)
                    
                    if isVoteSuccessful == true {
                        // Success
                        completion(voteValue, nil)
                        
                    } else {
                        let hasNotEnoughCcp = self.dataProviderHelper.getIsVoteNotEnoughCcp(fromJson: jsonData, apiVersion: self.apiVersion)
                        
                        if hasNotEnoughCcp == true {
                            // Failed vote from not enough CCP
                            completion(.none, VoteError.notEnoughCcp)
                        } else {
                            // Failed unknown
                            completion(.none, VoteError.unknown)
                        }
                    }
                    
                case .failure(let error):
                    completion(.none, error)
                }
            }
        }
        
        // Check for accesstoken and prompt for login
        if OAuth2Handler.sharedInstance.accessToken == "" {
            self.loginScreen?.presentLogin(rootViewController: rootViewController.navigationController!, showConfirmation: true, completion: { (username, error) in
                
                guard error == nil else {
                    // Failed to log in
                    completion(.none, error)
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
    
    func requestSubmissionVote(submissionId: Int64, voteValue: Int, rootViewController: UIViewController, completion: @escaping (VoteValue, Error?) -> ()) {
        
        let requestSubmissionVoteClosure: ()->() = {
            
            let urlString = self.getSubmissionVoteUrlString(submissionId: submissionId, voteType: voteValue, apiVersion: self.apiVersion)
            
            self.sessionManager.request(urlString, method: .post).validate().responseJSON { (response) in
                switch response.result {
                case .success:
                    
                    // Get vote value based on json response
                    let jsonData = JSON.init(data: response.data!)
                    let voteValue = self.dataProviderHelper.getVoteValue(fromJson: jsonData, apiVersion: self.apiVersion)
                    let isVoteSuccessful = self.dataProviderHelper.getIsVoteSuccessful(fromJson: jsonData, apiVersion: self.apiVersion)
                    
                    if isVoteSuccessful == true {
                        // Success
                        completion(voteValue, nil)
                        
                    } else {
                        let hasNotEnoughCcp = self.dataProviderHelper.getIsVoteNotEnoughCcp(fromJson: jsonData, apiVersion: self.apiVersion)
                        
                        if hasNotEnoughCcp == true {
                            // Failed vote from not enough CCP
                            completion(.none, VoteError.notEnoughCcp)
                        } else {
                            // Failed unknown
                            completion(.none, VoteError.unknown)
                        }
                    }
                    
                case .failure(let error):
                    completion(.none, error)
                }
            }
        }
        
        // Check for accesstoken and prompt for login
        if OAuth2Handler.sharedInstance.accessToken == "" {
            self.loginScreen?.presentLogin(rootViewController: rootViewController.navigationController!, showConfirmation: true, completion: { (username, error) in
                
                guard error == nil else {
                    // Failed to log in
                    completion(VoteValue.none, error)
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
        
        self.sessionManager.request(requestUrlString).validate().responseJSON { response in
            switch response.result {
            case .success:
                jsonData = JSON.init(data: response.data!)
                
                submissionDataModels = self.dataProviderHelper.getSubmissionDataModels(fromJson: jsonData!, apiVersion: self.apiVersion)
                
                // Return the data models
                completion(submissionDataModels, nil)
                
            case .failure(let error):
                if response.response?.statusCode == 503 {
                    // Status code
                    print("Voat Service unavailable.")
                }
                #if DEBUG
                print(response.error.debugDescription)
                #endif
                
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
        
        self.sessionManager.request(requestUrlString).validate().responseJSON { (response) in
            switch response.result {
            case .success:
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
        
        self.sessionManager.request(requestUrlString).validate().responseJSON { (response) in
            switch response.result {
            case .success:
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
        subCellViewModel.dataModel = dataModel
        
        subCellViewModel.resetDataProviderBindings()
        
        // Bind upvote event to request
        subCellViewModel.dataProviderBindings.append( subCellViewModel.didRequestUpvote.observeNext { [weak self, unowned subCellViewModel, unowned viewController, unowned dataModel] (didRequestUpvote) in
            if didRequestUpvote {
                
                self?.requestSubmissionVote(submissionId: (subCellViewModel.dataModel?.id)!, voteValue: VoteValue.up.rawValue, rootViewController: viewController, completion: { (voteValue, error) in
                    
                    // Reset binding to allow for re-calling
                    subCellViewModel.didRequestUpvote.value = false
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Upvote")
                        #endif
                        subCellViewModel.voteValue.value = subCellViewModel.voteValue.value
                        return
                    }
                    
                    // Success
                    subCellViewModel.voteValue.value = voteValue
                    
                    // Analytics
                    let upvoteParams = AnalyticsEvents.getSubverseControllerVoteParams(subverseName: dataModel.subverseName, voteValue: voteValue.rawValue)
                    self?.analyticsManager?.logEvent(name: AnalyticsEvents.subverseControllerUpvote, params: upvoteParams, timed: false)
                    
                    #if DEBUG
                        print("Response received: \(voteValue.rawValue)")
                    #endif
                })
                
            }
        })
        
        // Bind downvote event to request
        subCellViewModel.dataProviderBindings.append( subCellViewModel.didRequestDownvote.observeNext { [weak self, unowned subCellViewModel, unowned viewController, unowned dataModel] didRequestDownvote in
            if didRequestDownvote {
                
                self?.requestSubmissionVote(submissionId: (subCellViewModel.dataModel?.id)!, voteValue: VoteValue.down.rawValue, rootViewController: viewController, completion: { (voteValue, error) in
                    
                    // Reset binding to allow for re-calling
                    subCellViewModel.didRequestUpvote.value = false
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Downvote")
                        #endif
                        
                        // Not Enough CCP
                        if let voteError = error as? VoteError {
                            if voteError == VoteError.notEnoughCcp {
                                if let subverseController = viewController as? SubverseViewController {
                                   subverseController.showNotEnoughCcpMessage()
                                }
                            }
                        }
                        
                        subCellViewModel.voteValue.value = subCellViewModel.voteValue.value
                        return
                    }
                    
                    // Success
                    subCellViewModel.voteValue.value = voteValue
                    
                    // Analytics
                    let downvoteParams = AnalyticsEvents.getSubverseControllerVoteParams(subverseName: dataModel.subverseName, voteValue: voteValue.rawValue)
                    self?.analyticsManager?.logEvent(name: AnalyticsEvents.subverseControllerDownvote, params: downvoteParams, timed: false)
                    
                    #if DEBUG
                        print("Response received: \(voteValue.rawValue)")
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
        commentCellViewModel.dataProviderBindings.append( commentCellViewModel.didRequestUpvote.observeNext { [weak self, weak viewController, weak commentCellViewModel] (didRequestUpvote) in
            if didRequestUpvote {
                
                self?.requestCommentVote(commentId: commentCellViewModel!.id, voteValue: VoteValue.up.rawValue, rootViewController: viewController!, completion: { (voteValue, error) in
                    
                    // Reset to allow for re-voting
                    commentCellViewModel!.didRequestUpvote.value = false
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Upvote")
                        #endif
                        // Trigger callback to reset previous value
                        commentCellViewModel!.voteValue.value = commentCellViewModel!.voteValue.value
                        return
                    }
                    
                    // Success
                    commentCellViewModel!.voteValue.value = voteValue
                    
                    // Analytics
                    let commentsViewController = viewController as! CommentsViewController
                    let upvoteParams = AnalyticsEvents.getCommentsControllerCommentVoteParams(subverseName: commentsViewController.submissionDataModel!.subverseName, mediaType: commentsViewController.submissionMediaType, voteValue: voteValue.rawValue, childDepthIndex: commentCellViewModel!.childDepthIndex)
                    self?.analyticsManager?.logEvent(name: AnalyticsEvents.commentsControllerCommentUpvote, params: upvoteParams, timed: false)
                    
                    #if DEBUG
                        print("Response received: \(voteValue.rawValue)")
                    #endif
                })
                
            }
        })
        
        // Bind downvote event to request
        commentCellViewModel.dataProviderBindings.append( commentCellViewModel.didRequestDownvote.observeNext { [weak self, weak viewController, weak commentCellViewModel] didRequestDownvote in
            if didRequestDownvote {
                
                self?.requestCommentVote(commentId: commentCellViewModel!.id, voteValue: VoteValue.down.rawValue, rootViewController: viewController!, completion: { (voteValue, error) in
                    
                    // Reset to allow for re-voting
                    commentCellViewModel!.didRequestUpvote.value = false
                    
                    // Failed
                    guard error == nil else {
                        #if DEBUG
                            print("Response failed: Downvote")
                        #endif
                        
                        // Not Enough CCP
                        if let voteError = error as? VoteError {
                            if voteError == VoteError.notEnoughCcp {
                                if let commentsController = viewController as? CommentsViewController {
                                    commentsController.showNotEnoughCcpMessage()
                                }
                            }
                        }
                        
                        // Trigger callback to reset previous value
                        commentCellViewModel!.voteValue.value = commentCellViewModel!.voteValue.value
                        return
                    }
                    
                    // Success
                    commentCellViewModel!.voteValue.value = voteValue
                    
                    // Analytics
                    let commentsViewController = viewController as! CommentsViewController
                    let downvoteParams = AnalyticsEvents.getCommentsControllerCommentVoteParams(subverseName: commentsViewController.submissionDataModel!.subverseName, mediaType: commentsViewController.submissionMediaType, voteValue: voteValue.rawValue, childDepthIndex: commentCellViewModel!.childDepthIndex)
                    self?.analyticsManager?.logEvent(name: AnalyticsEvents.commentsControllerCommentDownvote, params: downvoteParams, timed: false)
                    
                    #if DEBUG
                        print("Response received: \(voteValue.rawValue)")
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
            urlString = self.VOAT_V1_DOMAIN + "/api/v1/vote/\(type)/\(submissionId)/\(voteType)"
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
            urlString = self.VOAT_V1_DOMAIN + "/api/v1/vote/\(type)/\(commentId)/\(voteType)"
        }
        
        return urlString
    }
    
    private func getSubmitTopLevelCommentUrlString(subverse: String, submissionId: Int64, apiVersion: APIVersion) -> String {
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = "" // Unsupported
        case .v1:
            urlString = self.VOAT_V1_DOMAIN + "/api/v1/v/\(subverse)/\(submissionId)/comment"
        }
        
        return urlString
    }
    
    private func getSubmitCommentReplyUrlString(subverse: String, submissionId: Int64, commentId: Int64, apiVersion: APIVersion) -> String {
        var urlString = ""
        
        switch apiVersion {
        case .legacy:
            urlString = "" // Unsupported
        case .v1:
            urlString = self.VOAT_V1_DOMAIN + "/api/v1/v/\(subverse)/\(submissionId)/comment/\(commentId)"
        }
        
        return urlString
    }
    
    private func getSubmitCommentParams(comment: String, apiVersion: APIVersion) -> [String:String] {
        
        var params: [String:String] = [:]
        
        switch apiVersion {
        case .legacy:
            // unsupported
            break
        case .v1:
            params["value"] = comment
        }
        
        return params
    }
    
    private func getHeaders(apiVersion: APIVersion) -> HTTPHeaders {
        switch apiVersion {
        case .legacy:
            return [:]
        case .v1:
            return [self.VOAT_API_KEY_HEADER: self.VOAT_API_KEY_VALUE]
        }
    }
    
}
