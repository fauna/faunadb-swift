//
//  ClientConfigurationTests.swift
//  FaunaDB
//
//  Created by Martin Barreto on 5/31/16.
//
//

import XCTest
@testable import FaunaDB

class ClientConfigurationTests: FaunaDBTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultValues() {
        let secret = "any_secret"
        let clientConfig = ClientConfiguration(secret: secret)
        XCTAssertEqual(clientConfig.secret , secret)
        XCTAssertEqual(clientConfig.faunaRoot, NSURL(string: "https://rest.faunadb.com")!)
        XCTAssertEqual(clientConfig.timeoutIntervalForRequest, 60)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
