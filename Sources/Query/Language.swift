//
//  Language.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss

public enum Action {
    case Create
    case Delete
}

extension Action: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject {
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

extension Create: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["create" ~~> ref,
                        "params" ~~> params])
    }
    
    public func toAnyObjectJSON() -> AnyObject {
        return toJSON()!
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

extension Update: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["update" ~~> ref,
            "object" ~~> params])
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
    
    public func toJSON() -> JSON? {
        return jsonify(["replace" ~~> ref,
                        "params" ~~> params])
    }
}


public struct Delete: FunctionType {
    
    var ref: Ref
    
    init(_ ref: Ref){
        self.ref = ref
    }
}

extension Delete: Encodable {
    
    public func toJSON() -> JSON? {
        return "delete" ~~> ref
    }
}

public struct Insert: FunctionType {
    let ref: Ref
    let ts: Timestamp
    let action: Action
    let params: Obj
}

extension Insert: Encodable, FaunaEncodable {
 
    public func toJSON() -> JSON? {
        return jsonify(["insert" ~~> ref,
                        "ts" ~~> ts,
                        "action" ~~> action.toAnyObjectJSON(),
                        "params" ~~> params
            ])
    }
}

public struct Remove: FunctionType {
    let ref: Ref
    let ts: Timestamp
    let action: Action
}


extension Remove: Encodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["remove" ~~> ref,
                        "ts" ~~> ts,
                        "action" ~~> action.toAnyObjectJSON()
            ])
    }
}

public struct Get: FunctionType {
    let ref: Ref
    
    public init(_ ref: Ref){
        self.ref = ref
    }
}

extension Get: Encodable {
    
    public func toJSON() -> JSON? {
        return "get" ~~> ref
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
    
    public func toJSON() -> JSON? {
        if let ts = ts {
            return jsonify(["exists" ~~> ref,
                            "ts" ~~> ts])
        }
        return "exists" ~~> ref
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
    
    public func toJSON() -> JSON? {
        return jsonify(["if" ~~> pred.toAnyObjectJSON(),
                        "then" ~~> then.toAnyObjectJSON(),
                        "else" ~~> `else`.toAnyObjectJSON()])
    }
}

public struct Do: FunctionType {
    let exprs: [Expr]
    
    init (_ exprs: Expr...){
        self.exprs = exprs
    }
}

extension Do: Encodable {
    
    public func toJSON() -> JSON? {
        let expArray = exprs.map { $0.toAnyObjectJSON() }
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
    public func toJSON() -> JSON? {
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

extension Lambda: FaunaEncodable {
    public func toAnyObjectJSON() -> AnyObject{
        return ["lambda": (exprs[0] as! Var).name,
                "expr": expr.toAnyObjectJSON()]
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
    
    public func toJSON() -> JSON? {
        return ["map": lambda.toAnyObjectJSON(),
                "collection": collection.toAnyObjectJSON()]
    }
}


extension CollectionType where Self.Generator.Element == Value {
    public func mapFauna(@noescape lambda: ((Value) -> Expr)) -> Map {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Value) -> Expr)) -> Foreach {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Foreach(arr: arr, lambda: lambda)
    }
}

extension CollectionType where Self.Generator.Element: Value {
    
    public func mapFauna(@noescape lambda: ((Value) -> Expr)) -> Map {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Value) -> Expr)) -> Foreach {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Foreach(arr: arr, lambda: lambda)
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
    
    public func toJSON() -> JSON? {
        return ["foreach": lambda.toAnyObjectJSON(),
                "collection": collection.toAnyObjectJSON()]
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
    
    public func toJSON() -> JSON? {
        return ["filter": lambda.toAnyObjectJSON(),
                "collection": collection.toAnyObjectJSON()]
    }
}



