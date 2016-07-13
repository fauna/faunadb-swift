//
//  Value.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

internal protocol Encodable {
    func toJSON() -> AnyObject
}

public protocol ValueConvertible {
    var value: Value { get }
}

public protocol Value: Expr{}
public protocol ScalarValue: Value {}

extension ValueConvertible {
    func toJSON() -> AnyObject {
        return (value as! Encodable).toJSON()
    }
}

extension Value {
    
    public var value: Value { return self }
    
    public func isEquals(other: Value) -> Bool {
        
        switch (self, other) {
        case (let exp1 as Arr, let exp2 as Arr):
            return exp1 == exp2
        case (let exp1 as Obj, let exp2 as Obj):
            return exp1 == exp2
        case (let exp1 as Ref, let exp2 as Ref):
            return exp1 == exp2
        case (let exp1 as Int, let exp2 as Int):
            return exp1 == exp2
        case (let exp1 as Double, let exp2 as Double):
            return exp1 == exp2
        case (let exp1 as Float, let exp2 as Float):
            return exp1 == exp2
        case (let exp1 as String, let exp2 as String):
            return exp1 == exp2
        case (let exp1 as Timestamp, let exp2 as Timestamp):
            return exp1 == exp2
        case (let exp1 as Date, let exp2 as Date):
            return exp1 == exp2
        case  (let exp1 as Bool, let exp2 as Bool):
            return exp1 == exp2
        case ( _ as Null, _ as Null):
            return true
        default:
            return false
        }
    }
}

extension ValueConvertible {
    
    public func get<T: Value>(path: PathComponentType...) throws -> T{
        return try get(Field<T>(path))
    }
    
    public func get<T: Value>(field: Field<T>) throws -> T{
        return try field.get(value)
    }
    
    public func get<T: Value>(path: PathComponentType...) -> T?{
        return get(Field<T>(path))
    }
    
    public func get<T: Value>(field: Field<T>) -> T?{
        return field.getOptional(value)
    }
    
    public func get<A: Value, B: Value>(field1: Field<A>, field2: Field<B>) throws -> (A, B){
        return try (field1.get(value), field2.get(value))
    }
    
    public func get<A: Value, B: Value>(field1: Field<A>, field2: Field<B>) -> (A, B)?{
        return try? (field1.get(value), field2.get(value))
    }
    
    public func get<A: Value, B: Value>(fieldComposition: (Value throws -> (A, B))) throws ->  (A, B){
        return try fieldComposition(value)
    }
    
    public func get<A: Value, B: Value>(fieldComposition: (Value throws -> (A, B))) ->  (A, B)?{
        return try? fieldComposition(value)
    }

    
    
    public func get<A: Value, B: Value, C: Value>(field1: Field<A>, field2: Field<B>, field3: Field<C>) throws -> (A, B, C){
        return try (field1.get(value), field2.get(value), field3.get(value))
    }
    
    public func get<A: Value, B: Value, C: Value>(field1: Field<A>, field2: Field<B>, field3: Field<C>) -> (A, B, C)?{
        return try? (field1.get(value), field2.get(value), field3.get(value))
    }
    
    public func get<A: Value, B: Value, C: Value>(fieldComposition: (Value throws -> (A, B, C))) throws ->  (A, B, C){
        return try fieldComposition(value)
    }
    
    public func get<A: Value, B: Value, C: Value>(fieldComposition: (Value throws -> (A, B, C))) ->  (A, B, C)?{
        return try? fieldComposition(value)
    }
    
    
    
    public func get<A: Value, B: Value, C: Value, D: Value>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) throws -> (A, B, C, D){
        return try (field1.get(value), field2.get(value), field3.get(value), field4.get(value))
    }
    
    public func get<A: Value, B: Value, C: Value, D: Value>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) -> (A, B, C, D)?{
        return try? (field1.get(value), field2.get(value), field3.get(value), field4.get(value))
    }
    
    public func get<A: Value, B: Value, C: Value, D: Value>(fieldComposition: (Value throws -> (A, B, C, D))) throws ->  (A, B, C, D){
        return try fieldComposition(value)
    }
    
    public func get<A: Value, B: Value, C: Value, D: Value>(fieldComposition: (Value throws -> (A, B, C, D))) ->  (A, B, C, D)?{
        return try? fieldComposition(value)
    }
    
    
    
    public func get<A: Value, B: Value, C: Value, D: Value, E: Value>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) throws ->  (A, B, C, D, E){
        return try (field1.get(value), field2.get(value), field3.get(value), field4.get(value), field5.get(value))
    }
    
    
    public func get<A: Value, B: Value, C: Value, D: Value, E: Value>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) -> (A, B, C, D, E)?{
        return try? (field1.get(value), field2.get(value), field3.get(value), field4.get(value), field5.get(value))
    }
    
    public func get<A: Value, B: Value, C: Value, D: Value, E: Value>(fieldComposition: (Value throws -> (A, B, C, D, E))) throws ->  (A, B, C, D, E){
        return try fieldComposition(value)
    }
    
    public func get<A: Value, B: Value, C: Value, D: Value, E: Value>(fieldComposition: (Value throws -> (A, B, C, D, E))) ->  (A, B, C, D, E)?{
        return try? fieldComposition(value)
    }
    
}















