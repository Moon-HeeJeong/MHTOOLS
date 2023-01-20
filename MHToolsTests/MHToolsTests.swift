//
//  MHToolsTests.swift
//  MHToolsTests
//
//  Created by LittleFoxiOSDeveloper on 2022/11/15.
//

import XCTest
@testable import MHTools
import RxSwift

final class MHToolsTests: XCTestCase {
    
    var api: APITest?
    
    var disposeBag = DisposeBag()

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
//            XCTAssertNotNil(res)
            XCTAssertNil(res.data)
            exception.fulfill()
        })
        wait(for: [exception], timeout: 7)
    }
    
    func testAPIByRx() throws{
        let exception = self.expectation(description: "test api by rx call")
        
//        var result: MH_Response<VersionAPI.DataType>?
        
        self.api?.callByRx(VersionAPI(deviceID: "7a16fd01-06a7-4395-bab0-30339d886541", pushID: "34edca539308ecc796113ce3fac74000a2cf3401252480cc18e97568625f12ab", isPushOn: nil, config: APIConfig()))
            .subscribe(
                onNext: { element in
                    print("res ::\(element)")
//                    result = element
//                    XCTAssertNotNil(element)
                    XCTAssertNotNil(element.data)
                    exception.fulfill()
                }, onError: { error in
                    print("error ::\((error as? APICallError)?.desc)")
                }, onCompleted: {
                    print("completed")
            }, onDisposed: {
                print("disposed")
            }
            ).disposed(by: disposeBag)
        
        wait(for: [exception], timeout: 7)
    }
    
}

