//
//  FieldPath.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/7/16.
//
//

import Foundation
import Result

public enum FieldPathError: ErrorType, Equatable {
    case NotFound(fieldPath: FieldPathType)
    case UnexpectedType(v: Value, expectedType: Any.Type, fieldPath: FieldPathType)
}


public func ==(lhs: FieldPathError, rhs: FieldPathError) -> Bool {
    switch (lhs, rhs) {
    case (.NotFound(let fieldPath1), .NotFound(let fieldPath2)):
        return fieldPath1.isEqual(fieldPath2)
    case (.UnexpectedType(let value1, let expectedType1, let fieldPath1), .UnexpectedType(let value2, let expectedType2, let fieldPath2)):
        return fieldPath1.isEqual(fieldPath2) && expectedType1 == expectedType2 && value1.isEquals(value2)
    default:
        return false
    }
    
}

public protocol FieldPathType: CustomStringConvertible, CustomDebugStringConvertible {
    func subValue(v: Value) throws -> Value
    func isEqual(other: FieldPathType) -> Bool
}

extension FieldPathType {
    
    public var description: String {
        if let str = self as? String {
            return "/\(str)"
        }
        else if let int = self as? Int {
            return "/[\(int)]"
        }
        return "Unknown FieldPathType"
    }
    
    public var debugDescription: String {
        return description
    }
    
    public func isEqual(other: FieldPathType) -> Bool {
        switch (self, other) {
        case (let str as String, let str2 as String):
            return str == str2
        case (let int as Int, let int2 as Int):
            return int == int2
        case ( _ as FieldPathEmpty, _ as FieldPathEmpty):
            return true
        default:
            return false
        }
    }
}


extension String: FieldPathType {
    
    public func subValue(v: Value) throws -> Value {
        switch v{
        case let obj as Obj:
            guard let objValue = obj[self] else { throw FieldPathError.NotFound(fieldPath: self) }
            return objValue
        default:
            throw FieldPathError.UnexpectedType(v: v, expectedType: Obj.self, fieldPath: self)
        }
    }
}

extension Int: FieldPathType {
    public func subValue(v: Value) throws -> Value {
        switch v{
        case let arr as Arr:
            guard arr.count > self  else { throw FieldPathError.NotFound(fieldPath: self) }
            return arr[self]
        default:
            throw FieldPathError.UnexpectedType(v: v, expectedType: Arr.self, fieldPath: self)
        }
    }
}

public struct FieldPathEmpty: FieldPathType {
    
    public var description: String {
        return "/"
    }
    
    public func subValue(v: Value) throws -> Value {
        return v
    }
}
