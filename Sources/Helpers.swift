//
//  Helpers.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

extension NSNumber {
    
    internal func isBoolNumber() -> Bool{
        return CFGetTypeID(self) == CFBooleanGetTypeID()
    }
    
    internal func isDoubleNumber() -> Bool{
        return CFNumberGetType(self) == CFNumberType.doubleType || CFNumberGetType(self) == CFNumberType.float64Type
    }
}

func varargs<C: Collection>(_ collection: C) -> ValueConvertible where C.Iterator.Element == Expr{
    switch  collection.count {
    case 1:
        return collection.first!
    default:
        return Arr(collection.map { $0 })
    }
}

func varargs<C: Collection>(_ collection: C) -> ValueConvertible where C.Iterator.Element: ValueConvertible{
    switch  collection.count {
    case 1:
        return collection.first!
    default:
        return Arr(collection)
    }
}

func varargs<C: Collection>(_ collection: C) -> ValueConvertible where C.Iterator.Element == PathComponentType{
    switch  collection.count {
    case 1:
        return collection.first!
    default:
        return Arr(collection.map { $0 })
    }
    
}

struct Mapper {
    
    static func fromFaunaResponseData(_ data: Data) throws -> Value{
        let jsonData: AnyObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        guard let res = jsonData.object(forKey: "resource") else {
            throw FaunaError.driverException(data: jsonData, msg: "Fauna response does not contain a resource key")
        }
        return try Mapper.fromData(res as AnyObject)
    }
    
    static func fromData(_ data: AnyObject) throws -> Value {
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
        case let value as [AnyObject]:
            guard let result = Arr(json: value) else { throw FaunaError.unparsedDataException(data: value as AnyObject, msg: "Unparseable data to Arr") }
            return result
        case let value as [String: AnyObject]:
            guard let result: Value = Ref(json: value) ?? Timestamp(json: value) ?? Date(json: value) ?? SetRef(json: value) ?? Obj(json: value)  else { throw FaunaError.unparsedDataException(data: value as AnyObject, msg: "Unparseable data") }
            return result
        default:
            throw FaunaError.unparsedDataException(data: data, msg: "Unparseable data")
        }
    }
}
