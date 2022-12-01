//
//  MHToolsTests.swift
//  MHToolsTests
//
//  Created by LittleFoxiOSDeveloper on 2022/11/15.
//

import XCTest
@testable import MHTools


final class MHToolsTests: XCTestCase {
    
    var api: APITest?

    override func setUpWithError() throws {
        self.api = APITest()
    }

    override func tearDownWithError() throws {
        self.api = nil
    }

    
    func testAPI() throws{
        let exception = self.expectation(description: "test api call")
        
        self.api?.call(api: VersionAPI(deviceID: "7a16fd01-06a7-4395-bab0-30339d886541", pushID: "1dcf0c21fb5f7891f73eaba0266e87ac3871884ae6fc3456e4580007fbad8427", isPushOn: nil, config: APIConfig()), completed: { res in
            print("res ::\(res)")
            
            XCTAssertNotNil(res)
            exception.fulfill()
        })
        wait(for: [exception], timeout: 7)
    }
}

