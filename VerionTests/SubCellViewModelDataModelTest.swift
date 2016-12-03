//
//  SubCellViewModelDataModelTest.swift
//  Verion
//
//  Created by Simon Chen on 12/2/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import XCTest
import Nimble
import Quick
import Bond

@testable import Verion

class SubCellViewModelDataModelTest: QuickSpec {
    
    override func spec() {
        
        // For Offline Data Provider
        // Test that a ViewModel is correctly bounded to a DataModel
        
        
        describe("an OfflineDataProvider") {
            let offlineDataProvider = OfflineDataProvider(apiVersion: APIVersion.legacy)
            
            context("binding a SubmissionCellViewModel and a SubmissionDataModel-Legacy") {
                let viewModel = SubmissionCellViewModel()
                let dataModel = SubmissionDataModelLegacy()
                
                beforeEach {
                    offlineDataProvider.bind(subCellViewModel: viewModel, dataModel: dataModel)
                }
                
                xit("correctly binds the upvote") {
                    expect(viewModel.upvoteCount.value).to(equal(dataModel.upvoteCount))
                }
                
                xit("correctly binds the downvote") {
                    expect(viewModel.downvoteCount.value).to(equal(dataModel.downvoteCount))
                }
                
                xit("correctly binds the total vote") {
                    expect(viewModel.voteCountTotal.value).to(equal(dataModel.voteCount))
                }
            }
        }
        
    }
}
