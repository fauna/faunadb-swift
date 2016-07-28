//
//  FieldType.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public protocol FieldType {
    associatedtype T: DecodableValue

    var path: [PathComponentType] { get }

    func get(value: Value) throws -> T
    func getOptional(value: Value) -> T?
    func collect(value: Value) throws -> [T]
    func collectOptional(value: Value) -> [T]?

    init(_ array: [PathComponentType])
}


extension FieldType {
    public func getOptional(value: Value) -> T? {
        return try? get(value)
    }

    public func collectOptional(value: Value) -> [T]? {
        return try? collect(value)
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
}

public struct Field<T: DecodableValue where T.DecodedType == T>: FieldType, ArrayLiteralConvertible, IntegerLiteralConvertible, StringLiteralConvertible {

    public let path: [PathComponentType]

    public init(_ array: [PathComponentType]){
        path = array
    }

    public init(_ path: PathComponentType...){
        self.init(path)
    }

    public func get(value: Value) throws -> T {
        let result: ValueConvertible = try path.reduce(value) { (partialValue, path) -> ValueConvertible in
            return try path.subValue(partialValue.value)
        }
        guard let typedValue = T.decode(result.value) else { throw FieldPathError.UnexpectedType(value: result, expectedType: T.self, path: []) }
        return typedValue
    }

    public func collect(value: Value) throws -> [T] {
        let arr: Arr = try value.get(field: Field<Arr>(path))
        return try arr.map {
            guard let item = T.decode($0.value) else { throw FieldPathError.UnexpectedType(value: $0, expectedType: T.self, path: []) }
            return item
        }
    }
}

public struct FieldComposition {

    public static func zip<A: DecodableValue, B: DecodableValue>(field1 field1: Field<A>, field2: Field<B>) -> (Value throws -> (A, B)){
        return { try (field1.get($0), field2.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue>(field1 field1: Field<A>, field2: Field<B>) -> (Value  -> (A, B)?){
        return { try? (field1.get($0), field2.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue>(field1 field1: Field<A>, field2: Field<B>, field3: Field<C>) -> (Value throws -> (A, B, C)){
        return { try (field1.get($0), field2.get($0), field3.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue>(field1 field1: Field<A>, field2: Field<B>, field3: Field<C>) -> (Value -> (A, B, C)?){
        return { try? (field1.get($0), field2.get($0), field3.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(field1 field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) -> (Value throws -> (A, B, C, D)){
        return { try (field1.get($0), field2.get($0), field3.get($0), field4.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(field1 field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) -> (Value -> (A, B, C, D)?){
        return { try? (field1.get($0), field2.get($0), field3.get($0), field4.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(field1 field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) -> (Value throws  -> (A, B, C, D, E)){
        return { try (field1.get($0), field2.get($0), field3.get($0), field4.get($0), field5.get($0)) }
    }

    public static func zip<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(field1 field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) -> (Value -> (A, B, C, D, E)?){
        return { try? (field1.get($0), field2.get($0), field3.get($0), field4.get($0), field5.get($0)) }
    }
}
