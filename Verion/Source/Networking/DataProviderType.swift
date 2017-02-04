
//
//  DataProviderType.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

/*
 
 # Overview
 
 This protocol should mirror the Voat API. 
 Implementations will mirror each version of the API. 
 Each version, v1, v2, will have its own class. 
 
 */

import UIKit

protocol DataProviderType: class {
    var apiVersion: APIVersion {get}
    init(apiVersion: APIVersion, loginScreen: LoginScreenProtocol)
    
    func requestSubmitTopLevelComment(subverseName: String, submissionId: Int64, comment: String, completion: @escaping (CommentDataModelProtocol?, Error?)->())
    func requestSubmitCommentReply(subverseName: String, submissionId: Int64, commentId: Int64, comment: String, completion: @escaping (CommentDataModelProtocol?, Error?)->())
    func requestSubverseSubmissions(submissionParams: SubmissionsRequestParams, completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void)
    func requestComments(subverse: String, submissionId: Int64, completion: @escaping ([CommentDataModelProtocol], CommentDataSegmentProtocol?, Error?)->Void)
    func requestChildComments(subverse: String, submissionId: Int64, parentId: Int64, startingIndex: Int, completion: @escaping ([CommentDataModelProtocol], CommentDataSegmentProtocol?,Error?) -> ())
    func requestSubverseList(completion: @escaping ([SubverseSearchResultDataModelProtocol], Error?) ->Void)
    func requestContent(submissionDataModel: SubmissionDataModelProtocol, downloadProgress: @escaping (Double)->(), completion: @escaping (Data?, SubmissionMediaType, Bool, Error?) -> Void)
    func requestLoginAuthentication(username: String, password: String, completion: @escaping (_ accessToken: String, _ refreshToken: String, Error?)->()) -> ()
    func requestSubmissionVote(submissionId: Int64, voteValue: Int, rootViewController: UIViewController, completion: @escaping(VoteValue, Error?)->())
    func requestCommentVote(commentId: Int64, voteValue: Int, rootViewController: UIViewController, completion: @escaping(Error?)->())
    
    
    func bind(subCellViewModel: SubmissionCellViewModel, dataModel: SubmissionDataModelProtocol, viewController: UIViewController) -> Void
    func bind(subTitleViewModel: SubmissionTitleCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subTextCellViewModel: SubmissionTextCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subImageCellViewModel: SubmissionImageCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subLinkCellViewModel: SubmissionLinkCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subverseSearchResultCellViewModel: SubverseSearchResultCellViewModel, dataModel: SubverseSearchResultDataModelProtocol) -> Void
    func bindTopLevelCommentViewModel(commentCellViewModel: CommentCellViewModel, dataModel: CommentDataModelProtocol)
    func bind(commentCellViewModel: CommentCellViewModel, viewController: UIViewController)
    
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType
}
