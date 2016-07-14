//
//  ClientConfigurationTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//


import XCTest
@testable import FaunaDB

class ClientConfigurationTests: FaunaDBTests {
    
    func testDefaultValues() {
        let secret = "any_secret"
        let client = Client(secret: secret)
        XCTAssertEqual(client.secret , secret)
        XCTAssertEqual(client.endpoint, NSURL(string: "https://rest.faunadb.com")!)
        XCTAssertEqual(client.session.configuration.timeoutIntervalForRequest, 60)
    }

}
