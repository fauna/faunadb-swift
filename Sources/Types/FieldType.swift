//
//  FieldType.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

protocol FieldType {
    associatedtype T: DecodableValue
    func get(value: Value) throws -> T
    func getOptional(value: Value) -> T?
}

public struct Field<T: DecodableValue where T.DecodedType == T>: FieldType, ArrayLiteralConvertible, IntegerLiteralConvertible, StringLiteralConvertible {
    
    var path: [PathComponentType]
    
    public init(_ array: [PathComponentType]){
        path = array
    }
    
    public init(_ filePaths: PathComponentType...){
        self.init(filePaths)
    }
    
    public init<U: Value>(other: Field<U>){
        self.init(other.path)
    }

    public func get(value: Value) throws -> T {
        let result: Value = try path.reduce(value) { (partialValue, path) -> Value in
            return try path.subValue(partialValue)
        }
        guard let typedValue = T.decode(result) else { throw FieldPathError.UnexpectedType(value: result, expectedType: T.self, path: []) }
        return typedValue
    }
    
    public func getOptional(value: Value) -> T? {
        return try? get(value)
    }
    
    // MARK: ArrayLiteralConvertible
    
    public init(arrayLiteral elements: PathComponentType...){
        self.init(elements)
    }
    
    // MARK: IntegerLiteralConvertible
    
    public init(integerLiteral value: Int){
        self.init([value])
    }
    
    // MARK: StringLiteralConvertible
    
    public init(stringLiteral value: String){
        self.init([value])
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        self.init(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: String){
        self.init(stringLiteral: value)
    }
    
    // Mark: Convenience method
    
    /**
     Creates a field extractor composed with another nested field
     
     - parameter other: nested field to compose with
     
     - returns: a new field extractor with the nested field
     */
    public func at<U: Value>(other: Field<U>) -> Field<U>{
        return Field<U>(path + other.path)
    }
}

public struct FieldComposition {
    
    public static func zip<A: DecodableValue, B: DecodableValue>(field1: Field<A>, field2: Field<B>) -> (Value throws -> (A, B)){
        return { try (field1.get($0), field2.get($0)) }
    }
    
    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>) -> (Value throws  -> (A, B, C)){
        return { try (field1.get($0), field2.get($0), field3.get($0)) }
    }
    
    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) -> (Value throws  -> (A, B, C, D)){
        return { try (field1.get($0), field2.get($0), field3.get($0), field4.get($0)) }
    }
    
    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) -> (Value throws  -> (A, B, C, D, E)){
        return { try (field1.get($0), field2.get($0), field3.get($0), field4.get($0), field5.get($0)) }
    }
}

