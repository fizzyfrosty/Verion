//
//  SubmissionCellViewViewModelTest.swift
//  Verion
//
//  Created by Simon Chen on 12/1/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import XCTest
import Quick
import Nimble
import SwinjectStoryboard

@testable import Verion

class SubmissionCellViewViewModelTest: QuickSpec {
    
    override func spec() {
        let SUBMISSION_CELL_REUSE_ID = "SubmissionCell"
        
        // Initialize view, viewmodel, and binding
        let subverseVcSb = SwinjectStoryboard.create(name: "Subverse", bundle: nil)
        let subverseController = subverseVcSb.instantiateViewController(withIdentifier: "SubverseViewController") as! SubverseViewController
        _ = subverseController.view
        
        // TODO: Move this into test for subverseController loading correct data
        // Register a dummy dataProvider, it should automatically load the controller with dummy data
        /*
        SwinjectStoryboard.defaultContainer.register(<#T##serviceType: Service.Type##Service.Type#>){ _ in
            
        }
    */
        
        
        // Test that a cell's UI is loaded properly from the view model
        describe("a submission cell") {
            
            let submissionCell = subverseController.tableView.dequeueReusableCell(withIdentifier: SUBMISSION_CELL_REUSE_ID) as! SubmissionCell

            let viewModel = SubmissionCellViewModel()
            submissionCell.bind(toViewModel: viewModel)
            
            
            it("has the title loaded") {
                expect(submissionCell.titleLabel.text).to(equal(viewModel.titleString))
            }
            
            it("has the vote count loaded") {
                expect(submissionCell.voteCountLabel.text).to(equal(String(viewModel.voteCountTotal.value)))
            }
            
            it("has the separated-vote count, and the string is not empty") {
                expect(submissionCell.voteSeparatedCountLabel.text).to(equal(viewModel.voteSeparatedCountString.value))
                expect(viewModel.voteSeparatedCountString.value).toNot(equal(""))
            }
            
            it("has the comment count loaded") {
                expect(submissionCell.commentLabel.text).to(equal(String(viewModel.commentCount)))
            }
            
            // TODO: thumbnail support
            xit("has the thumbnail loaded") {
                
            }
            
            // TODO: tests for the other UI elements...
            
        }
        
        // TODO: Test that a submission cell is resized properly for long titles
        
        
        
        // TODO:
        // Test event bindings for upvote and downvote
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


extension SwinjectStoryboard {
    class func setup() {
        let defaultContainer = SwinjectStoryboard.defaultContainer
        
        defaultContainer.register(SFXManagerType.self, factory: { _ in
            SFXManager()
        })
        
        defaultContainer.register(DataProviderType.self){ _ in
            OfflineDataProvider()
        }
        
        defaultContainer.registerForStoryboard(SubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = ResolverType.resolve(SFXManagerType.self)!
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
        })
    }
}
