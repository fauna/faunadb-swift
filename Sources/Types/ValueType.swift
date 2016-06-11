//
//  ValueType.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/3/16.
//
//

import Foundation
import Gloss

public protocol ValueType: ExprType {}

extension ValueType {
    
    public func isEquals(other: ValueType) -> Bool{
        return false
    }
    
    public func get<T: ValueType>(path: FieldPathType...) throws -> T{
        let field: Field<T> = Field<T>(path)
        return try self.get(field)
        
    }
    
    public func get<T: ValueType>(field: Field<T>) throws -> T{
        return try field.get(self)
    }
}

struct Mapper {
    
    static func fromData(data: AnyObject) throws -> ValueType {
        switch data {
        case let strValue as String:
            return strValue
        case let doubleValue as Double:
            return doubleValue
        case let floatValue as Float:
            return floatValue
        case let intValue as Int:
            return intValue
        case let boolValue as Bool:
            return boolValue
        case _ as NSNull:
            return Null()
        case let arrayValue as [AnyObject]:
            guard let result = Arr(json: arrayValue) else { throw Error.DecodeException(data: arrayValue) }
            return result
        case let dictValue as [String: AnyObject]:
            guard let result: ValueType = Ref(json: dictValue) ?? Timestamp(json: dictValue) ?? Date(json: dictValue) ?? Obj(json: dictValue)  else { throw Error.DecodeException(data: dictValue) }
            return result
        default:
            throw Error.DecodeException(data: data)
        }
    }
    
}