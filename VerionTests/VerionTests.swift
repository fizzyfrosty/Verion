//
//  VerionTests.swift
//  VerionTests
//
//  Created by Simon Chen on 11/26/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import XCTest
@testable import Verion

class VerionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }
    
    func testSubverseStoryboardLoaded() {
        
        let subVcSb = UIStoryboard(name: "Subverse", bundle: nil)
        if let subVc: SubverseViewController = subVcSb.instantiateViewController(withIdentifier: "SubverseViewController") as? SubverseViewController{
            
            XCTAssert(subVc.SUBMISSION_CELL_REUSE_ID == "SubmissionCell")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
