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
        let client = Client(secret: secret)
        XCTAssertEqual(client.secret , secret)
        XCTAssertEqual(client.faunaRoot, NSURL(string: "https://rest.faunadb.com")!)
        XCTAssertEqual(client.session.configuration.timeoutIntervalForRequest, 60)
    }

}
