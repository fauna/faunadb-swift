//
//  File.swift
//  FaunaDB
//
//  Created by Martin Barreto on 7/13/16.
//
//

import Foundation


public protocol ValueConvertible {
    var value: Value { get }
}

extension ValueConvertible {
    func toJSON() -> AnyObject {
        return (value as! Encodable).toJSON()
    }
}

extension ValueConvertible {
    
    public func get<T: DecodableValue where T.DecodedType == T>(path path: PathComponentType...) throws -> [T]{
        return try get(field: Field<T>(path))
    }
    
    public func get<T: DecodableValue where T.DecodedType == T>(field field: Field<T>) throws -> [T]{
        return try field.getArray(value)
    }
    
    public func get<T: DecodableValue where T.DecodedType == T>(path path: PathComponentType...) throws -> [T]?{
        return try? get(field: Field<T>(path))
    }
    
    public func get<T: DecodableValue where T.DecodedType == T>(field field: Field<T>) throws -> [T]?{
        return try? field.getArray(value)
    }
}

extension ValueConvertible {
    
    public func get<T: DecodableValue where T.DecodedType == T>(path path: PathComponentType...) throws -> T{
        return try get(field: Field<T>(path))
    }
    
    public func get<T: DecodableValue where T.DecodedType == T>(field field: Field<T>) throws -> T{
        return try field.get(value)
    }
    
    public func get<T: DecodableValue where T.DecodedType == T>(path path: PathComponentType...) -> T?{
        return get(field: Field<T>(path))
    }
    
    public func get<T: DecodableValue  where T.DecodedType == T>(field field: Field<T>) -> T?{
        return field.getOptional(value)
    }
    
    public func get<A: DecodableValue, B: DecodableValue where A.DecodedType == A, B.DecodedType == B>(field1 field1: Field<A>, field2: Field<B>) throws -> (A, B){
        return try (field1.get(value), field2.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue where A.DecodedType == A, B.DecodedType == B>(field1 field1: Field<A>, field2: Field<B>) -> (A, B)?{
        return try? (field1.get(value), field2.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue where A.DecodedType == A, B.DecodedType == B>(fieldComposition fieldComposition: (Value throws -> (A, B))) throws ->  (A, B){
        return try fieldComposition(value)
    }
    
    public func get<A: DecodableValue, B: DecodableValue where A.DecodedType == A, B.DecodedType == B>(fieldComposition fieldComposition: (Value throws -> (A, B))) ->  (A, B)?{
        return try? fieldComposition(value)
    }
    
    
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C>(field1: Field<A>, field2: Field<B>, field3: Field<C>) throws -> (A, B, C){
        return try (field1.get(value), field2.get(value), field3.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C>(field1: Field<A>, field2: Field<B>, field3: Field<C>) -> (A, B, C)?{
        return try? (field1.get(value), field2.get(value), field3.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C>(fieldComposition: (Value throws -> (A, B, C))) throws ->  (A, B, C){
        return try fieldComposition(value)
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C>(fieldComposition: (Value throws -> (A, B, C))) ->  (A, B, C)?{
        return try? fieldComposition(value)
    }
    
    
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) throws -> (A, B, C, D){
        return try (field1.get(value), field2.get(value), field3.get(value), field4.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) -> (A, B, C, D)?{
        return try? (field1.get(value), field2.get(value), field3.get(value), field4.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D>(fieldComposition: (Value throws -> (A, B, C, D))) throws ->  (A, B, C, D){
        return try fieldComposition(value)
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D>(fieldComposition: (Value throws -> (A, B, C, D))) ->  (A, B, C, D)?{
        return try? fieldComposition(value)
    }
    
    
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) throws ->  (A, B, C, D, E){
        return try (field1.get(value), field2.get(value), field3.get(value), field4.get(value), field5.get(value))
    }
    
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) -> (A, B, C, D, E)?{
        return try? (field1.get(value), field2.get(value), field3.get(value), field4.get(value), field5.get(value))
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E>(fieldComposition: (Value throws -> (A, B, C, D, E))) throws ->  (A, B, C, D, E){
        return try fieldComposition(value)
    }
    
    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E>(fieldComposition: (Value throws -> (A, B, C, D, E))) ->  (A, B, C, D, E)?{
        return try? fieldComposition(value)
    }
}