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

extension ValueConvertible {
    
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
public func expectToJson<T: ValueConvertible>(@autoclosure(escaping) expression: () throws -> T?, file: Nimble.FileString = #file, line: UInt = #line) -> Nimble.Expectation<String>{
    return try expect(expression()?.jsonString)    
}

struct Fields {
    static let ref = Field<Ref>("ref")
    static let `class` = Field<Ref>("class")
    static let secret = Field<String>("secret")
}

extension CollectionType where Index.Distance == Int{
    
    
    public var sample: Self.Generator.Element? {
        if !isEmpty {
            let randomIndex = startIndex.advancedBy(Int(arc4random_uniform(UInt32(count))))
            return self[randomIndex]
        }
        return nil
    }
    
    public func sample(size size: Int) -> [Self.Generator.Element]? {
        
        if !self.isEmpty {
            var sampleElements: [Self.Generator.Element] = []
            
            for _ in 1...size {
                sampleElements.append(sample!)
            }
            return sampleElements
        }
        
        return nil
    }
    

}


extension String{

    public init(randomWithLength length: Int) {
        self.init("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters.sample(size: length)!)
        
    }
}
