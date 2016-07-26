//
//  Helpers.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

extension NSNumber {
    
    func isBoolNumber() -> Bool{
        return CFGetTypeID(self) == CFBooleanGetTypeID()
    }
    
    func isDoubleNumber() -> Bool{
        return CFNumberGetType(self) == CFNumberType.DoubleType || CFNumberGetType(self) == CFNumberType.Float64Type
    }
}

func varargs<C: CollectionType where C.Generator.Element == Expr>(collection: C) -> ValueConvertible{
    switch  collection.count {
    case 1:
        return collection.first!
    default:
        return Arr(collection.map { $0 })
    }
}

func varargs<C: CollectionType where C.Generator.Element: ValueConvertible>(collection: C) -> ValueConvertible{
    switch  collection.count {
    case 1:
        return collection.first!
    default:
        return Arr(collection.map { $0 })
    }
}

func varargs<C: CollectionType where C.Generator.Element == PathComponentType>(collection: C) -> ValueConvertible{
    switch  collection.count {
    case 1:
        return collection.first!
    default:
        return Arr(collection.map { $0 })
    }
    
}

struct Mapper {
    
    static func fromFaunaResponseData(data: NSData) throws -> Value{
        let jsonData: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        guard let res = jsonData.objectForKey("resource") else {
            throw Error.DriverException(data: jsonData, msg: "Fauna response does not contain a resource key")
        }
        return try Mapper.fromData(res)
    }
    
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
        case let value as [AnyObject]:
            guard let result = Arr(json: value) else { throw Error.UnparsedDataException(data: value, msg: "Unparseable data to Arr") }
            return result
        case let value as [String: AnyObject]:
            guard let result: Value = Ref(json: value) ?? Timestamp(json: value) ?? Date(json: value) ?? SetRef(json: value) ?? Obj(json: value)  else { throw Error.UnparsedDataException(data: value, msg: "Unparseable data") }
            return result
        default:
            throw Error.UnparsedDataException(data: data, msg: "Unparseable data")
        }
    }
}
