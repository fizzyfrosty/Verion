//
//  SubmissionCellViewViewModelBindingsTest.swift
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

class SubmissionCellViewViewModelBindingsTest: QuickSpec {
    
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
        
        
        describe("a submission cell when bounded to the ViewModel") {
            
            let submissionCell = subverseController.tableView.dequeueReusableCell(withIdentifier: SUBMISSION_CELL_REUSE_ID) as! SubmissionCell

            let viewModel = SubmissionCellViewModel()
            beforeEach {
                submissionCell.bind(toViewModel: viewModel)
            }
            
            // -----------Testing UI Display----------------
            it("has the title loaded") {
                expect(submissionCell.titleLabel.text).to(equal(viewModel.titleString))
            }
            
            // TODO: Thumbnail
            xit("has the thumbnail loaded") {
                
            }
            
            it("has the thumbnail string loaded") {
                expect(submissionCell.thumbnailLabel.text).to(equal(viewModel.thumbnailString))
            }
            
            it("has the vote count loaded") {
                expect(submissionCell.voteCountLabel.text).to(equal(String(viewModel.voteCountTotal.value)))
            }
            
            it("has the separated-vote count") {
                expect(submissionCell.voteSeparatedCountLabel.text).to(equal(viewModel.voteSeparatedCountString.value))
            }
            
            it("has total vote count equal to sum of separated vote counts") {
                let totalVoteCount = viewModel.upvoteCount.value - viewModel.downvoteCount.value
                let labelVoteCount = Int(submissionCell.voteCountLabel.text!)
                expect(totalVoteCount).to(equal(labelVoteCount))
            }
            
            it("has the comment count loaded") {
                expect(submissionCell.commentLabel.text).to(equal(String(viewModel.commentCount)))
            }
            
            it("has the submitted-by-user label loaded") {
                expect(submissionCell.submittedByUserLabel.text).to(equal(viewModel.submittedByString))
            }
            
            it("has the submitted-to-subverse label loaded") {
                expect(submissionCell.submittedToSubverseLabel.text).to(equal(viewModel.submittedToSubverseString))
            }
            
            // ------------- Testing Bindings ---------------
            context("When the upvote button is pressed") {
                beforeEach {
                    submissionCell.upvoteButton.sendActions(for: .touchUpInside)
                }
                
                it("is registered in the ViewModel") {
                    expect(viewModel.didUpvote.value).to(beTrue())
                }
            }
            
            context("When the downvote button is pressed") {
                beforeEach {
                    submissionCell.downvoteButton.sendActions(for: .touchUpInside)
                }
                
                it("is registered in the ViewModel") {
                    expect(viewModel.didDownvote.value).to(beTrue())
                }
            }
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
            OfflineDataProvider(apiVersion: APIVersion.v1)
        }
        
        defaultContainer.registerForStoryboard(SubverseViewController.self, initCompleted: { (ResolverType, C) in
            C.sfxManager = ResolverType.resolve(SFXManagerType.self)!
            C.dataProvider = ResolverType.resolve(DataProviderType.self)!
        })
    }
}
