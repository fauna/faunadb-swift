//
//  Language.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation

public enum Action {
    case Create
    case Delete
}

extension Action: Encodable {
    
    public func toJSON() -> AnyObject {
        switch self {
        case .Create:
            return "create"
        case .Delete:
            return "delete"
        }
    }
}

protocol SimpleFunctionType: FunctionType {
    init(_ ref: Ref, _ params: Obj)
}

public struct Create: SimpleFunctionType {
    var ref: Ref
    var params: Obj
    
    public init(_ ref: Ref, _ params: Obj){
        self.ref = ref
        self.params = params
    }
}

extension Create: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["create": ref.toJSON(),
                "params": params.toJSON()]
    }
}

public struct Update: SimpleFunctionType {
    var ref: Ref
    var params: Obj
    
    public init(_ ref: Ref, _ params: Obj){
        self.ref = ref
        self.params = params
    }
}

extension Update: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["update": ref.toJSON(),
                "params": params.toJSON()]
    }
}

public struct Replace: SimpleFunctionType {
    var ref: Ref
    var params: Obj
    
    public init(_ ref: Ref, _ params: Obj){
        self.ref = ref
        self.params = params
    }
}

extension Replace: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["replace": ref.toJSON(),
                "params": params.toJSON()]
    }
}


public struct Delete: FunctionType {
    
    var ref: Ref
    
    init(_ ref: Ref){
        self.ref = ref
    }
}

extension Delete: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["delete": ref.toJSON()]
    }
}

public struct Insert: FunctionType {
    let ref: Ref
    let ts: Timestamp
    let action: Action
    let params: Obj
}

extension Insert: Encodable {
 
    public func toJSON() -> AnyObject {
        return ["insert": ref.toJSON(),
                "ts": ts.toJSON(),
                "action": action.toJSON(),
                "params": params.toJSON()
                ]
    }
}

public struct Remove: FunctionType {
    let ref: Ref
    let ts: Timestamp
    let action: Action
}


extension Remove: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["remove": ref.toJSON(),
                "ts": ts.toJSON(),
                "action": action.toJSON()]
    }
}



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

public struct If: FunctionType {
    let pred: Expr
    let then: Expr
    let `else`: Expr
    
    init(_ pred: Expr, then: Expr, `else`: Expr) {
        self.pred = pred
        self.then = then
        self.`else` = `else`
    }
}

extension If: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["if": pred.toJSON(),
                "then": then.toJSON(),
                "else": `else`.toJSON()]
    }
}

public struct Do: FunctionType {
    let exprs: [Expr]
    
    init (_ exprs: Expr...){
        self.exprs = exprs
    }
}

extension Do: Encodable {
    
    public func toJSON() -> AnyObject {
        let expArray = exprs.map { $0.toJSON() }
        return ["do": expArray]
    }
}

public struct Var: Value {
    let name: String
    
    init(_ name: String){
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


public struct Lambda {
    
//    let vars: [Var]?
    let exprs: [Expr]
    let expr: Expr
    
    public init(vars: Var..., expr: Expr){
        self.exprs = vars.map { $0 as Expr }
        self.expr = expr
    }
    
    public init(exprs: Expr..., expr: Expr){
        self.exprs = exprs
        self.expr = expr
    }
    
    public init(@noescape lambda: ((Value)-> Expr)){
        self.init(vars: "x", expr: lambda(Var("x")))
    }
    
    public init(@noescape lambda: ((Value, Value)-> Expr)){
        self.init(vars: "x", "y", expr: lambda(Var("x"), Var("y")))
    }
    
}

extension Lambda: Encodable {
    public func toJSON() -> AnyObject {
        return ["lambda": (exprs[0] as! Var).name,
                "expr": expr.toJSON()]
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
public struct Map: LambdaFunctionType{
    let lambda: Lambda
    let collection: Arr
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, lambda: Lambda){
        self.collection = Arr(arr)
        self.lambda = lambda
    }
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: (Value -> Expr)){
        self.init(arr: arr, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
    }
    
//    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
//        var array: Arr = Arr()
//        arr.forEach { array.append($0) }
//        self.init(arr: array, lambda: Lambda(vars: "x", expr: lambda(Var("x"))))
//    }
    
//    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: ((Value, Value) -> Expr)){
//        self.init(arr: arr, lambda: Lambda(vars: "x", "y", expr: lambda(Var("x"), Var("y"))))
//    }
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
public struct Foreach: LambdaFunctionType {
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



