//
//  Scalars.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

extension Int: ScalarValue{}
extension Int: Encodable {

    func toJSON() -> AnyObject {
        return self as AnyObject
    }
}

extension Double: ScalarValue{}
extension Double: Encodable {

    func toJSON() -> AnyObject {
        return self as AnyObject
    }
}

extension String: ScalarValue{}
extension String: Encodable {

    func toJSON() -> AnyObject {
        return self as AnyObject
    }
}

extension Bool: ScalarValue{}
extension Bool: Encodable {

    func toJSON() -> AnyObject {
        return self as AnyObject
    }
}

public struct Null: ScalarValue {
    public init(){}
}

extension Null: CustomDebugStringConvertible, CustomStringConvertible {

    public var description: String {
        return "null"
    }

    public var debugDescription: String {
        return description
    }
}

extension Null: Encodable {

    //MARK: Encodable

    func toJSON() -> AnyObject {
        return NSNull()
    }
}

extension Null: Equatable {}

public func ==(lhs: Null, rhs: Null) -> Bool {
    return true
}
