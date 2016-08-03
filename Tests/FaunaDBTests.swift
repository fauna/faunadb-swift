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

    static let secret = "your_admin_key"

    lazy var client: Client = {
        return Client(secret: FaunaDBTests.secret)
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

    func await(expr: Expr) -> Value? {
        var res: Value?
        waitUntil(timeout: 10) { [weak self] done in
            self?.client.query(expr) { result in
                res = try? result.dematerialize()
                done()
            }
        }
        return res
    }

    func awaitError(expr: Expr) -> Error? {
        var res: Error?
        waitUntil(timeout: 10) { [weak self] done in
            self?.client.query(expr) { result in
                res = result.error
                done()
            }
        }
        return res
    }

}

func XCTAssertThrows<T: ErrorType where T: Equatable>(error: T, block: () throws -> ()) {
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

    public init(randomNumWithLength length: Int) {
        self.init(["123456789".characters.sample!] + "0123456789".characters.sample(size: length - 1)!)
    }
}


extension Error {

    public func equalType(other: Error) -> Bool {
        switch (self, other) {
        case (.UnavailableException(_, _), .UnavailableException(_, _)):
            return true
        case (.BadRequestException(_, _), .BadRequestException(_, _)):
            return true
        case (.NotFoundException(_, _), .NotFoundException(_, _)):
            return true
        case (.UnauthorizedException(_, _), .UnauthorizedException(_, _)):
            return true
        case (.UnknownException(_, _, _), .UnknownException(_, _, _)):
            return true
        case (.InternalException(_, _, _), .InternalException(_, _, _)):
            return true
        case (.NetworkException(_, _, _), .NetworkException(_, _, _)):
            return true
        case (.DriverException(_, _), .DriverException(_, _)):
            return true
        case (.UnparsedDataException(_, _), .UnparsedDataException(_, _)):
            return true
        default:
            return false
        }
    }
}
