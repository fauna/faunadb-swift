//
//  FaunaDBTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
import Nimble
@testable import FaunaDB

class FaunaDBTests: XCTestCase {
    
    static let fieldRef = Field<Ref>("ref")
    static let fieldClass = Field<Ref>("class")
    static let fieldSecret = Field<String>("secret")
    
    static let secret = "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI"
    
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

extension ExprConvertible {
    
    var jsonString: String {
        let data = try! NSJSONSerialization.dataWithJSONObject(toJSON(), options: [])
        return String(data: data, encoding: NSUTF8StringEncoding) ?? ""
    }
}

extension Mapper {
    static func fromString(strData: String) throws -> Value {
        let data = strData.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonData: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        return try Mapper.fromData(jsonData)
    }
}

extension Int {
    var MIN: NSTimeInterval { return Double(self) * 60 }
    var SEC: NSTimeInterval { return Double(self) }
}

@warn_unused_result(message="Follow 'expect(…)' with '.to(…)', '.toNot(…)', 'toEventually(…)', '==', etc.")
public func expectToJson<T: ExprConvertible>(@autoclosure(escaping) expression: () throws -> T?, file: Nimble.FileString = #file, line: UInt = #line) -> Nimble.Expectation<String>{
    return try expect(expression()?.jsonString)    
}
