//
//  OfflineDataProvider.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit

class OfflineDataProvider: DataProviderType {
    
    let NUM_OF_TEST_DATA_CELLS = 6
    
    func requestSubverseSubmissions(completion: @escaping ([SubmissionDataModelType], Error?)->Void) -> Void {
        
        var submissionDataModels = [SubmissionDataModelType]()
        
        for _ in 0..<self.NUM_OF_TEST_DATA_CELLS {
            // TODO: initialize data model with real values to be bound to viewModel
            let submissionDataModel = SubmissionDataModelType()
            submissionDataModels.append(submissionDataModel)
        }
        
        // TODO: Implement error return in a mock object?
        
        completion(submissionDataModels, nil)
    }
    
    func bind(subCellViewModel: SubmissionCellViewModel, dataModel: SubmissionDataModelType) -> Void {
        // Initialize the viewModel here for now
        // TODO: Replace and Bind viewModel to data model, and to self
        var subCellVmInitData = SubmissionCellViewModelInitData()
        subCellVmInitData.voteCountTotal = 1293
        subCellVmInitData.upvoteCount = 1343
        subCellVmInitData.downvoteCount = 50
        subCellVmInitData.commentCount = 2342
        subCellVmInitData.titleString = "A post! Some random website or Title here!"
        
        subCellViewModel.loadInitData(subCellVmInitData: subCellVmInitData)
    }
}
