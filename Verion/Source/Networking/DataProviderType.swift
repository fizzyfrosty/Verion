
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

protocol DataProviderType {
    
    func requestSubverseSubmissions(subverse: String, completion: @escaping ([SubmissionDataModelProtocol], Error?)->Void) -> Void
    func requestComments(submissionId: Int, completion: @escaping ([CommentDataModelProtocol], Error?)->Void) -> Void
    func requestSubverseList(completion: @escaping ([SubverseSearchResultDataModelProtocol], Error?) ->Void) -> Void
    
    func bind(subCellViewModel: SubmissionCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subTitleViewModel: SubmissionTitleCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subTextCellViewModel: SubmissionTextCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subImageCellViewModel: SubmissionImageCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subLinkCellViewModel: SubmissionLinkCellViewModel, dataModel: SubmissionDataModelProtocol) -> Void
    func bind(subverseSearchResultCellViewModel: SubverseSearchResultCellViewModel, dataModel: SubverseSearchResultDataModelProtocol) -> Void
    
    
    func getSubmissionMediaType(submissionDataModel: SubmissionDataModelProtocol) -> SubmissionMediaType
}
