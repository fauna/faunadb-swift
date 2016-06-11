//
//  Field.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/7/16.
//
//

import Foundation

protocol FieldType {
    associatedtype T: ValueType
    var path: [FieldPathType] { get }
    func get(value: ValueType) throws -> T
    func getOptional(value: ValueType) throws -> T?
}

public struct Field<T: ValueType>: FieldType, ArrayLiteralConvertible {

    var path: [FieldPathType]
    
    public init(_ array: [FieldPathType]){
        path = array
    }
    
    public init(_ filePaths:FieldPathType...){
        self.init(filePaths)
    }

    public func get(value: ValueType) throws -> T {
        let result: ValueType = try path.reduce(value) { (partialValue, path) -> ValueType in
            return try path.subValue(partialValue)
        }
        guard let typedValue = result as? T else { throw FieldPathError.NotFound(fieldPath: 3) }
        return typedValue
    }
    
    public func getOptional(value: ValueType) throws -> T? {
        let result: ValueType = path.reduce(value) { (partialValue, path) -> ValueType in
            return try! path.subValue(partialValue)
        }
        return result as? T
    }
    
    
    public init(arrayLiteral elements: FieldPathType...){
        let array = elements
        path = array
    }
}

