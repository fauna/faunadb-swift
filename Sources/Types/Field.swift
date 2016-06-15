//
//  Field.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/7/16.
//
//

import Foundation

protocol FieldType {
    associatedtype T: Value
    var path: [FieldPathType] { get }
    func get(value: Value) throws -> T
    func getOptional(value: Value) throws -> T?
}

public struct Field<T: Value>: FieldType, ArrayLiteralConvertible {

    var path: [FieldPathType]
    
    public init(_ array: [FieldPathType]){
        path = array
    }
    
    public init(_ filePaths:FieldPathType...){
        self.init(filePaths)
    }

    public func get(value: Value) throws -> T {
        let result: Value = try path.reduce(value) { (partialValue, path) -> Value in
            return try path.subValue(partialValue)
        }
        guard let typedValue = result as? T else { throw FieldPathError.NotFound(fieldPath: 3) }
        return typedValue
    }
    
    public func getOptional(value: Value) throws -> T? {
        let result: Value = path.reduce(value) { (partialValue, path) -> Value in
            return try! path.subValue(partialValue)
        }
        return result as? T
    }
    
    
    public init(arrayLiteral elements: FieldPathType...){
        let array = elements
        path = array
    }
}

