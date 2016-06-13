//
//  Value.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/3/16.
//
//

import Foundation
import Gloss

public protocol Value: Expr {}

extension Value {
    
    public func get<T: Value>(path: FieldPathType...) throws -> T{
        let field: Field<T> = Field<T>(path)
        return try self.get(field)
        
    }
    
    public func get<T: Value>(field: Field<T>) throws -> T{
        return try field.get(self)
    }
}

struct Mapper {
    
    static func fromData(data: AnyObject) throws -> Value {
        switch data {
        case let strValue as String:
            return strValue
        case let nsNumber as NSNumber where nsNumber.isBoolNumber():
            return nsNumber.boolValue
        case let doubleValue as Double:
            return doubleValue
        case let intValue as Int:
            return intValue
        case _ as NSNull:
            return Null()
        case let arrayValue as [AnyObject]:
            guard let result = Arr(json: arrayValue) else { throw Error.DecodeException(data: arrayValue) }
            return result
        case let dictValue as [String: AnyObject]:
            guard let result: Value = Ref(json: dictValue) ?? Timestamp(json: dictValue) ?? Date(json: dictValue) ?? Obj(json: dictValue)  else { throw Error.DecodeException(data: dictValue) }
            return result
        default:
            throw Error.DecodeException(data: data)
        }
    }
    
}

extension NSNumber {
    
    func isBoolNumber() -> Bool{
        let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
        let numID = CFGetTypeID(self) // the type ID of num
        return numID == boolID
    }
}