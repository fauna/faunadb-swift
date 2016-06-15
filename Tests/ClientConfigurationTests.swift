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
    
    func testDefaultValues() {
        let secret = "any_secret"
        let clientConfig = ClientConfiguration(secret: secret)
        XCTAssertEqual(clientConfig.secret , secret)
        XCTAssertEqual(clientConfig.faunaRoot, NSURL(string: "https://rest.faunadb.com")!)
        XCTAssertEqual(clientConfig.timeoutIntervalForRequest, 60)
    }

}
