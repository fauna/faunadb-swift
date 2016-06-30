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
    var path: [PathComponentType] { get }
    func get(value: Value) throws -> T
    func getOptional(value: Value) -> T?
}

public struct Field<T: Value>: FieldType, ArrayLiteralConvertible {

    var path: [PathComponentType]
    
    public init(_ array: [PathComponentType]){
        path = array
    }
    
    public init(_ filePaths:PathComponentType...){
        self.init(filePaths)
    }

    public func get(value: Value) throws -> T {
        let result: Value = try path.reduce(value) { (partialValue, path) -> Value in
            return try path.subValue(partialValue)
        }
        guard let typedValue = result as? T else { throw FieldPathError.UnexpectedType(value: result, expectedType: T.self, path: []) }
        return typedValue
    }
    
    public func getOptional(value: Value) -> T? {
        return try? get(value)
    }
    
    public init(arrayLiteral elements: PathComponentType...){
        let array = elements
        path = array
    }
}

