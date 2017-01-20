//
//  DataManagerTest.swift
//  Verion
//
//  Created by Simon Chen on 12/23/16.
//  Copyright © 2016 Workhorse Bytes. All rights reserved.
//

import UIKit
import Quick
import Nimble

@testable import Verion

class DataManagerTest: QuickSpec {
    override func spec() {
        
        describe("A Data Manager") {
            let dataManager = VerionDataManager()
            
            context("When there is a file") {
                var file: VerionDataModel?
                beforeEach {
                    file = VerionDataModel()
                    let randomInt = arc4random()
                    file?.subversesVisited = [String(randomInt)]
                }
                
                it("Saving it will let us reload it again") {
                    dataManager.saveData(dataModel: file!)
                    let loadedFile = dataManager.getSavedData()
                    
                    expect(loadedFile.subversesVisited?[0]).to(equal(file?.subversesVisited?[0]))
                }
            }
        }
    }
}
