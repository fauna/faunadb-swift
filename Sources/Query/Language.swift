//
//  Language.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation

public struct Exists: FunctionType {
    
    let ref: Ref
    let ts: Timestamp?
    
    init(_ ref: Ref, ts: Timestamp? = nil){
        self.ref = ref
        self.ts = ts
    }
}

extension Exists: Encodable {
    
    public func toJSON() -> AnyObject {
        if let ts = ts {
            return ["exists": ref.toJSON(),
                    "ts": ts.toJSON()]
        }
        return ["exists": ref.toJSON()]
    }
}


public struct Var: Value {
    
    let name: String
    
    public init(_ name: String){
        self.name = name
    }
}

extension Var: Encodable {
    public func toJSON() -> AnyObject {
        return ["var": name ]
    }
}

extension Var: StringLiteralConvertible {
    
    public init(stringLiteral value: String){
        name = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        name = value
    }
    
    public init(unicodeScalarLiteral value: String){
        name = value
    }

}

/**
 * A Map expression.
 *
 * '''Reference''': [[https:faunadb.com/documentation/queries#collection_functions]]
 //        client.query(
 //            Map(
 //                Lambda { name => Concat(Arr(name, "Wen")) },
 //                Arr("Hen ")))
 
 
 
 
 //        client.query(
 //            Map(
 //                Lambda { (f, l) => Concat(Arr(f, l), " ") },
 //                Arr(Arr("Hen", "Wen"))))
 
 
 
 //        client.query(
 //            Map(
 //                Lambda { (f, _) => f },
 //                Arr(Arr("Hen", "Wen"))))
 
 */
public struct Map: FunctionType{
    let lambda: Lambda
    let collection: Arr
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, lambda: Lambda){
        self.collection = Arr(arr)
        self.lambda = lambda
    }
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: (Value -> Expr)){
        self.init(arr: arr, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        self.init(arr: array, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: ((Value, Value) -> Expr)){
        self.init(arr: arr, lambda: Lambda(vars: "x", "y", expr: lambda(Var("x"), Var("y"))))
    }
}

extension Map: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["map": lambda.toJSON(),
                "collection": collection.toJSON()]
    }
}


/**
 * A Foreach expression.
 *
 * '''Reference''': [[https://faunadb.com/documentation/queries#collection_functions]]
 
 def Foreach(lambda: Expr, collection: Expr): Expr =
 Expr(ObjectV("foreach" -> lambda.value, "collection" -> collection.value))

 */
public struct Foreach: FunctionType {
    let lambda: Lambda
    let collection: Arr
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, lambda: Lambda){
        self.collection = Arr(arr)
        self.lambda = lambda
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, lambda: Lambda){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        self.init(arr: array, lambda: lambda)
    }
    
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: (Value -> Expr)){
        self.init(arr: arr, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        self.init(arr: array, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
}

extension Foreach: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["foreach": lambda.toJSON(),
                "collection": collection.toJSON()]
    }
}


public struct Filter: FunctionType {
    let lambda: Lambda
    let collection: Arr
    
    /**
     * A Filter expression.
     *
     * '''Reference''': [[https://faunadb.com/documentation/queries#collection_functions]]
     */
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, lambda: Lambda){
        self.collection = Arr(arr)
        self.lambda = lambda
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, lambda: Lambda){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        self.init(arr: array, lambda: lambda)
    }
    
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: (Value -> Expr)){
        self.init(arr: arr, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        self.init(arr: array, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
}


extension Filter: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["filter": lambda.toJSON(),
                "collection": collection.toJSON()]
    }
}



