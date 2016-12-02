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
            let offlineDataProvider = OfflineDataProvider()
            
            context("given a SubmissionCellViewModel and a SubmissionDataModel-Legacy") {
                let viewModel = SubmissionCellViewModel()
                let dataModel = SubmissionDataModelLegacy()
                
                xit("correctly binds all the properties") {
                    offlineDataProvider.bind(subCellViewModel: viewModel, dataModel: dataModel)
                    
                    expect(viewModel.upvoteCount.value).to(equal(dataModel.upvoteCount))
                    expect(viewModel.downvoteCount.value).to(equal(dataModel.downvoteCount))
                }
            }
        }
        
    }
}
