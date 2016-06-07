//
//  FieldPath.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/7/16.
//
//

import Foundation
import Result

public enum FieldPathError: ErrorType {
    case NotFound(fieldPath: FieldPathType)
    case UnexpectedType(v: ValueType, expectedType: Any.Type, fieldPath: FieldPathType)
}

public protocol FieldPathType: CustomStringConvertible, CustomDebugStringConvertible {

    func subValue(v: ValueType) throws -> ValueType
    
}

extension FieldPathType {
    
    public var debugDescription: String {
        return description
    }
}

public struct FieldPathField: FieldPathType {
    
    let field: String
    
    init(field: String) {
        self.field = field
    }

    public func subValue(v: ValueType) throws -> ValueType {
        switch v{
        case let obj as Obj:
            guard let objValue = obj[field] else { throw FieldPathError.NotFound(fieldPath: self) }
            return objValue
        default:
            throw FieldPathError.UnexpectedType(v: v, expectedType: Obj.self, fieldPath: self)
        }
    }
    
    public var description: String {
        return "/\(field)"
    }
    
    
    
}


public struct FieldPathIndex: FieldPathType {
    
    let idx: Int
    
    init(idx: Int) {
        self.idx = idx
    }
    
    public func subValue(v: ValueType) throws -> ValueType {
        switch v{
        case let arr as Arr:
            guard arr.count > idx  else { throw FieldPathError.NotFound(fieldPath: self) }
            return arr[idx]
        default:
            throw FieldPathError.UnexpectedType(v: v, expectedType: Arr.self, fieldPath: self)
        }
    }
    
    public var description: String {
        return "/[\(idx)]"
    }
}

public struct FieldPathEmpty: FieldPathType {
    
    public var description: String {
        return "/"
    }
    
    public func subValue(v: ValueType) throws -> ValueType {
        return v
    }
}


public struct FieldPathNode: FieldPathType {
    
    let left: FieldPathType
    let right: FieldPathType
    
    public var description: String {
        switch (left, right) {
        case (is FieldPathEmpty, let r):
            return r.description
        case (let l, is FieldPathEmpty):
            return l.description
        case(let l, let r):
            return "\(l)\(r)"
        }
    }
    
    public func subValue(v: ValueType) throws -> ValueType {
        return try right.subValue(left.subValue(v))
    }
}
