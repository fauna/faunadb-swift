//
//  FaunaDBTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
@testable import FaunaDB

class FaunaDBTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
      
}

func XCTAssertThrowss<T: ErrorType where T: Equatable>(error: T, block: () throws -> ()) {
    do {
        try block()
    }
    catch let e as T {
        XCTAssertEqual(e, error)
    }
    catch {
        XCTFail("Wrong error")
    }
}

extension ExprType {
    
    var jsonString: String {
        let data = try! NSJSONSerialization.dataWithJSONObject(toAnyObjectJSON()!, options: [])
        return String(data: data, encoding: NSUTF8StringEncoding) ?? ""
    }
}

extension Int {
    var MIN: NSTimeInterval { return Double(self) * 60 }
}
