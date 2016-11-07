//
//  ValueConvertible.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
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

    public func get<T: DecodableValue>(path: PathComponentType...) throws -> [T] where T.DecodedType == T{
        return try get(field: Field<T>(path))
    }

    public func get<T: DecodableValue>(field: Field<T>) throws -> [T] where T.DecodedType == T{
        return try field.collect(value)
    }

    public func get<T: DecodableValue>(path: PathComponentType...) -> [T]? where T.DecodedType == T{
        return try? get(field: Field<T>(path))
    }

    public func get<T: DecodableValue>(field: Field<T>) -> [T]? where T.DecodedType == T{
        return try? field.collect(value)
    }
}

extension ValueConvertible {

    public func get<T: DecodableValue>(path: PathComponentType...) throws -> T where T.DecodedType == T{
        return try get(field: Field<T>(path))
    }

    public func get<T: DecodableValue>(field: Field<T>) throws -> T where T.DecodedType == T{
        return try field.get(value)
    }

    public func get<T: DecodableValue>(path: PathComponentType...) -> T? where T.DecodedType == T{
        return get(field: Field<T>(path))
    }

    public func get<T: DecodableValue>(field: Field<T>) -> T?  where T.DecodedType == T{
        return field.getOptional(value)
    }

    public func get<A: DecodableValue, B: DecodableValue>(field1: Field<A>, field2: Field<B>) throws -> (A, B) where A.DecodedType == A, B.DecodedType == B{
        return try (field1.get(value), field2.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue>(field1: Field<A>, field2: Field<B>) -> (A, B)? where A.DecodedType == A, B.DecodedType == B{
        return try? (field1.get(value), field2.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue>(fieldComposition: ((Value) throws -> (A, B))) throws ->  (A, B) where A.DecodedType == A, B.DecodedType == B{
        return try fieldComposition(value)
    }

    public func get<A: DecodableValue, B: DecodableValue>(fieldComposition: ((Value) throws -> (A, B))) ->  (A, B)? where A.DecodedType == A, B.DecodedType == B{
        return try? fieldComposition(value)
    }



    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>) throws -> (A, B, C) where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C{
        return try (field1.get(value), field2.get(value), field3.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>) -> (A, B, C)?  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C{
        return try? (field1.get(value), field2.get(value), field3.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue>(fieldComposition: ((Value) throws -> (A, B, C))) throws ->  (A, B, C)  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C{
        return try fieldComposition(value)
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue>(fieldComposition: ((Value) throws -> (A, B, C))) ->  (A, B, C)?  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C{
        return try? fieldComposition(value)
    }



    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) throws -> (A, B, C, D)  where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D{
        return try (field1.get(value), field2.get(value), field3.get(value), field4.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>) -> (A, B, C, D)? where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D{
        return try? (field1.get(value), field2.get(value), field3.get(value), field4.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(fieldComposition: ((Value) throws -> (A, B, C, D))) throws ->  (A, B, C, D) where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D{
        return try fieldComposition(value)
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue>(fieldComposition: ((Value) throws -> (A, B, C, D))) ->  (A, B, C, D)? where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D{
        return try? fieldComposition(value)
    }



    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) throws ->  (A, B, C, D, E) where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E{
        return try (field1.get(value), field2.get(value), field3.get(value), field4.get(value), field5.get(value))
    }


    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(field1: Field<A>, field2: Field<B>, field3: Field<C>, field4: Field<D>, field5: Field<E>) -> (A, B, C, D, E)? where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E{
        return try? (field1.get(value), field2.get(value), field3.get(value), field4.get(value), field5.get(value))
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(fieldComposition: ((Value) throws -> (A, B, C, D, E))) throws ->  (A, B, C, D, E) where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E{
        return try fieldComposition(value)
    }

    public func get<A: DecodableValue, B: DecodableValue, C: DecodableValue, D: DecodableValue, E: DecodableValue>(fieldComposition: ((Value) throws -> (A, B, C, D, E))) ->  (A, B, C, D, E)? where A.DecodedType == A, B.DecodedType == B, C.DecodedType == C, D.DecodedType == D, E.DecodedType == E{
        return try? fieldComposition(value)
    }
}
