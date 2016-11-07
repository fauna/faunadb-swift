//
//  PathComponentType.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
import Result

public enum FieldPathError: Error, Equatable {
    case notFound(value: Value, path: [PathComponentType])
    case unexpectedType(value: ValueConvertible, expectedType: Any.Type, path: [PathComponentType])
}


public func ==(lhs: FieldPathError, rhs: FieldPathError) -> Bool {
    switch (lhs, rhs) {
    case (.notFound(let value1, let path1), .notFound(let value2, let path2)):
        return path1 == path2 && value1.isEquals(value2)
    case (.unexpectedType(let value1, let expectedType1, let path1), .unexpectedType(let value2, let expectedType2, let path2)):
        return path1 == path2 && expectedType1 == expectedType2 && value1.value.isEquals(value2.value)
    default:
        return false
    }

}

public protocol PathComponentType: CustomStringConvertible, CustomDebugStringConvertible, Value {
    func subValue(_ v: Value) throws -> ValueConvertible
    func isEqual(_ other: PathComponentType) -> Bool
}

func ==(lhs: [PathComponentType], rhs: [PathComponentType]) -> Bool{
    guard lhs.count == rhs.count else { return false }
    var i1 = lhs.makeIterator()
    var i2 = rhs.makeIterator()
    while let e1 = i1.next(), let e2 = i2.next() {
        guard e1.isEqual(e2) else { return false }
    }
    return true
}

extension PathComponentType {

    public var description: String {
        if let str = self as? String {
            return "/\(str)"
        }
        else if let int = self as? Int {
            return "/[\(int)]"
        }
        return "Unknown PathComponentType"
    }

    public var debugDescription: String {
        return description
    }

    public func isEqual(_ other: PathComponentType) -> Bool {
        switch (self, other) {
        case (let str as String, let str2 as String):
            return str == str2
        case (let int as Int, let int2 as Int):
            return int == int2
        default:
            return false
        }
    }

}

extension String: PathComponentType {

    public func subValue(_ v: Value) throws -> ValueConvertible {
        switch v{
        case let obj as Obj:
            guard let objValue = obj[self] else { throw FieldPathError.notFound(value: v, path: [self]) }
            return objValue
        case let valueConvertible as ValueConvertible where valueConvertible.value is Obj:
            return try subValue(valueConvertible.value)
        default:
            throw FieldPathError.unexpectedType(value: v, expectedType: Obj.self, path: [self])
        }
    }
}

extension Int: PathComponentType {
    public func subValue(_ v: Value) throws -> ValueConvertible {
        switch v{
        case let arr as Arr:
            guard arr.count > self  else { throw FieldPathError.notFound(value: v, path: [self]) }
            return arr[self]
        case let valueConvertible as ValueConvertible where valueConvertible.value is Arr:
            return try subValue(valueConvertible.value)
        default:
            throw FieldPathError.unexpectedType(value: v, expectedType: Arr.self, path: [self])
        }
    }
}
