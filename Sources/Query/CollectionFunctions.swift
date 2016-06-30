//
//  CollectionFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/14/16.
//
//

import Foundation

protocol CollectionFunctionType: FunctionType {}

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


/**
 *  `Map` applies `lambda` expression to each member of the Array or Page coll, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
 *
 *  `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */
public struct Map: FunctionType{
    let lambda: Lambda
    let collection: Arr
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, lambda: Lambda){
        self.collection = Arr(arr)
        self.lambda = lambda
    }
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: (Value -> Expr)){
        let newVar = Var(Var.newName)
        self.init(arr: arr, lambda: Lambda(vars:  newVar, expr: lambda(newVar)))
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        let newVar = Var(Var.newName)
        self.init(arr: array, lambda: Lambda(vars: newVar, expr: lambda(newVar)))
    }
    
    public init<C: CollectionType where C.Generator.Element == Value>(arr: C, @noescape lambda: ((Value, Value) -> Expr)){
        let newVar = Var(Var.newName)
        let newVar2 = Var(Var.newName)
        self.init(arr: arr, lambda: Lambda(vars: newVar, newVar2, expr: lambda(newVar, newVar2)))
    }
    
    
    
}

extension Map: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["map": lambda.toJSON(),
                "collection": collection.toJSON()]
    }
}

//def Foreach(lambda: Expr, collection: Expr): Expr =
//Expr(ObjectV("foreach" -> lambda.value, "collection" -> collection.value)

/**
 * `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
 *
 * `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
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
        let newVar = Var(Var.newName)
        self.init(arr: arr, lambda: Lambda(vars: newVar, expr: lambda(newVar)))
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        let newVar = Var(Var.newName)
        self.init(arr: array, lambda: Lambda(vars: newVar, expr: lambda(newVar)))
    }
}

extension Foreach: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["foreach": lambda.toJSON(),
                "collection": collection.toJSON()]
    }
}

/**
 * `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
 *
 * Providing a lambda which does not return a Boolean results in an “invalid argument” error.
 *
 * [Filtrer Reference](https://faunadb.com/documentation/queries#collection_functions-filter_lambda_expr_collection_coll)
 */
public struct Filter: FunctionType {
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
        let newVar = Var.newVar
        self.init(arr: arr, lambda: Lambda(vars: newVar, expr: lambda(newVar)))
    }
    
    public init<C: CollectionType where C.Generator.Element: Value>(arr: C, @noescape lambda: (Value -> Expr)){
        var array: Arr = Arr()
        arr.forEach { array.append($0) }
        let newVar = Var.newVar
        self.init(arr: array, lambda: Lambda(vars: newVar, expr: lambda(newVar)))
    }
}


extension Filter: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["filter": lambda.toJSON(),
                "collection": collection.toJSON()]
    }
}


/**
 * `Take` returns a new Collection or Page that contains num elements from the head of the Collection or Page coll. 
 *
 * If `take` value is zero or negative, the resulting collection is empty.
 *
 * When applied to a page, the returned page’s after cursor is adjusted to only cover the taken elements.
 * As special cases:
 * * If `take` value is negative, after will be set to the same value as the original page’s  before.
 * * If all elements from the original page were taken, after does not change.
 *
 * [Take Reference](https://faunadb.com/documentation/queries#collection_functions-take_num_collection_coll)
 */
public struct Take: CollectionFunctionType{
    
    let take: Int
    let collection: Expr
    
    init(_ take: Int, collection: Expr){
        self.take = take
        self.collection = collection
    }
    
//    init<C: CollectionType where C.Generator.Element == Value>(_ take: Int, arr: C){
//        let expr = Arr(arr)
//        self.init(take, collection: expr)
//    }
//    
//    init<C: CollectionType where C.Generator.Element: Value>(_ take: Int, arr: C){
//        var expr: Arr = Arr()
//        arr.forEach { expr.append($0) }
//        self.init(take, collection: expr)
//    }
}

extension Take: Encodable {
    public func toJSON() -> AnyObject {
        return ["take": take.toJSON(), "collection": collection.toJSON()]
    }
}

/**
 * `Drop` returns a new Arr or Page that contains the remaining elements, after num have been removed from the head of the Arr or Page coll. If `drop` value is zero or negative, elements of coll are returned unmodified.
 *
 * When applied to a page, the returned page’s before cursor is adjusted to exclude the dropped elements. As special cases:
 * * If `drop` value is negative, before does not change.
 * * Otherwise if all elements from the original page were dropped (including the case where the page was already empty), before will be set to same value as the original page’s after.
 *
 *  [Drop Reference](https://faunadb.com/documentation/queries#collection_functions-drop_num_collection_coll)
 */
public struct Drop: CollectionFunctionType {
    let drop: Int
    let collection: Expr
    
    init(_ drop: Int, collection: Expr){
        self.drop = drop
        self.collection = collection
    }
    
//    init<C: CollectionType where C.Generator.Element == Value>(_ take: Int, arr: C){
//        let expr = Arr(arr)
//        self.init(take, collection: expr)
//    }
//    
//    init<C: CollectionType where C.Generator.Element: Value>(_ take: Int, arr: C){
//        var expr: Arr = Arr()
//        arr.forEach { expr.append($0) }
//        self.init(take, collection: expr)
//    }
}

extension Drop: Encodable {
    public func toJSON() -> AnyObject {
        return ["drop": drop.toJSON(), "collection": collection.toJSON()]
    }
}


/**
 * `Prepend` returns a new Array that is the result of prepending `elements` onto the Array `toCollection`.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */
public struct Prepend: CollectionFunctionType {
    
    let elements: Expr
    let collection: Expr
    
    init(_ elements: Expr, toCollection collection: Expr){
        self.elements = elements
        self.collection = collection
    }
}

extension Prepend: Encodable {
    public func toJSON() -> AnyObject {
        return ["collection": elements.toJSON(), "prepend": collection.toJSON()]
    }
}

/**
 * `Append` returns a new Array that is the result of appending `elements` onto the `toCollection` array.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */
public struct Append: CollectionFunctionType{
    
    let elements: Expr
    let collection: Expr
    
    init(_ elements: Expr, toCollection collection: Expr){
        self.elements = elements
        self.collection = collection
    }
}

extension Append: Encodable {
    public func toJSON() -> AnyObject {
        return ["collection": elements.toJSON(), "append": collection.toJSON()]
    }
}
