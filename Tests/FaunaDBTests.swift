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
    
    private static var secret: String {
        if let envVarKey = ProcessInfo.processInfo.environment["FAUNA_ROOT_KEY"], !envVarKey.isEmpty {
            return envVarKey
        }
        else {
            return "secret"
        }
    }

    lazy var client: Client = {
        return Client(secret: FaunaDBTests.secret, endpoint: URL(string: "https://localhost:8443")!)
    }()

    let testDbName = "faunadb-swift-test-\(arc4random())"

    override func setUp() {
        super.setUp()
        // This method is called before the invocation of each test method in the class.
        Nimble.AsyncDefaults.Timeout = 5.SEC
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Helpers

    func await(_ expr: Expr) -> Value? {
        var res: Value?
        
        waitUntil(timeout: 10) { [weak self] done in
            _ = self?.client.query(expr) { result in
                res = try? result.dematerialize()
                done()
            }
        }
        
        return res
    }

    func awaitError(_ expr: Expr) -> FaunaError? {
        var res: FaunaError?
        
        waitUntil(timeout: 10) { [weak self] done in
            _ = self?.client.query(expr) { result in
                res = result.error
                done()
            }
        }
        
        return res
    }

}

func XCTAssertThrows<T: Error>(error: T, block: () throws -> ()) where T: Equatable {
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
        let data = try! JSONSerialization.data(withJSONObject: toJSON(), options: [])
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
    }
}

extension Mapper {
    static func fromString(_ strData: String) throws -> Value {
        let data = strData.data(using: String.Encoding.utf8)
        let jsonData: AnyObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
        return try Mapper.fromData(jsonData)
    }
}

extension Int {
    var MIN: TimeInterval { return Double(self) * 60 }
    var SEC: TimeInterval { return Double(self) }
}


public func expectToJson<T: ValueConvertible>(_ expression: @autoclosure @escaping () throws -> T?, file: Nimble.FileString = #file, line: UInt = #line) -> Nimble.Expectation<String>{
    return try expect(expression()?.jsonString)
}

struct Fields {
    static let ref = Field<Ref>("ref")
    static let `class` = Field<Ref>("class")
    static let secret = Field<String>("secret")
}

extension String {
    
    public static func random(length: Int) -> String {
        return randomSample(source: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", length: length)
    }
    
    public static func random(nums length: Int) -> String {
        return randomSample(source: "123456789", length: length)
    }
    
    private static func randomSample(source: String, length: Int) -> String {
        var res = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(source.characters.count))
            res += "\(source[source.index(source.startIndex, offsetBy: IndexDistance(rand))])"
        }
        
        return res
    }
    
}


extension FaunaError {

    public func equalType(_ other: FaunaError) -> Bool {
        switch (self, other) {
        case (.unavailableException(_, _), .unavailableException(_, _)):
            return true
        case (.badRequestException(_, _), .badRequestException(_, _)):
            return true
        case (.notFoundException(_, _), .notFoundException(_, _)):
            return true
        case (.unauthorizedException(_, _), .unauthorizedException(_, _)):
            return true
        case (.unknownException(_, _, _), .unknownException(_, _, _)):
            return true
        case (.internalException(_, _, _), .internalException(_, _, _)):
            return true
        case (.networkException(_, _, _), .networkException(_, _, _)):
            return true
        case (.driverException(_, _), .driverException(_, _)):
            return true
        case (.unparsedDataException(_, _), .unparsedDataException(_, _)):
            return true
        default:
            return false
        }
    }
}
