
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
    init(apiVersion: APIVersion)
    
    func requestSubverseSubmissions(subverse: String, completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void)
    func requestComments(subverse: String, submissionId: Int64, completion: @escaping ([CommentDataModelProtocol], Error?)->Void)
    func requestSubverseList(completion: @escaping ([SubverseSearchResultDataModelProtocol], Error?) ->Void)
    func requestContent(submissionDataModel: SubmissionDataModelProtocol, downloadProgress: @escaping (Double)->(), completion: @escaping (Data?, SubmissionMediaType, Bool, Error?) -> Void)
    
    func bind(subCellViewModel: SubmissionCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subTitleViewModel: SubmissionTitleCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subTextCellViewModel: SubmissionTextCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subImageCellViewModel: SubmissionImageCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subLinkCellViewModel: SubmissionLinkCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subverseSearchResultCellViewModel: SubverseSearchResultCellViewModel, dataModel: SubverseSearchResultDataModelProtocol) -> Void
    func bind(commentCellViewModel: CommentCellViewModel, dataModel: CommentDataModelProtocol) -> Void
    
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType
}
