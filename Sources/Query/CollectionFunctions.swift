//
//  CollectionFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 *  `Map` applies `lambda` expression to each member of the Array or Page coll, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
 *
 *  `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */
    
public func Map<C: CollectionType where C.Generator.Element == Value>(arr arr: C, lambda: Expr) -> Expr{
    return Expr(fn(["map": lambda.value, "collection": Arr(arr)] as Obj))
}

public func Map<C: CollectionType where C.Generator.Element == Value>(arr arr: C, @noescape lambda: (Expr -> Expr)) -> Expr{
    let newVar = Var.newVar
    return Map(arr: arr, lambda: Lambda(vars: newVar, expr: lambda(Expr(newVar))))
}

public func Map<C: CollectionType where C.Generator.Element: ValueConvertible>(arr arr: C, @noescape lambda: (Expr -> Expr)) -> Expr{
    var array: Arr = Arr()
    arr.forEach { array.append($0.value) }
    let newVar = Var.newVar
    return Map(arr: array, lambda: Lambda(vars: newVar, expr: lambda(Expr(newVar))))
}

public func Map<C: CollectionType where C.Generator.Element == Value>(arr arr: C, @noescape lambda: ((Expr, Expr) -> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    return Map(arr: arr, lambda: Lambda(vars: newVar, newVar2, expr: lambda(Expr(newVar), Expr(newVar2))))
}

public func Map(collection collection: Expr, lambda: Expr) -> Expr {
    return Expr(fn(["map": lambda.value, "collection": collection.value] as Obj))
}


/**
 * `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
 *
 * `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */

    
public func Foreach<C: CollectionType where C.Generator.Element == Value>(arr arr: C, lambda: Expr) -> Expr{
    return Expr(fn(["foreach": lambda.value, "collection": Arr(arr)] as Obj))
}

public func Foreach<C: CollectionType where C.Generator.Element: ValueConvertible>(arr arr: C, lambda: Expr) -> Expr{
    var array: Arr = Arr()
    arr.forEach { array.append($0.value) }
    return Foreach(arr: array, lambda: lambda)
}


public func Foreach<C: CollectionType where C.Generator.Element == Value>(arr arr: C, @noescape lambda: (Expr -> Expr)) -> Expr{
    let newVar = Var.newVar
    return Foreach(arr: arr, lambda: Lambda(vars: newVar, expr: lambda(Expr(newVar))))
}

public func Foreach<C: CollectionType where C.Generator.Element: ValueConvertible>(arr arr: C, @noescape lambda: (Expr -> Expr)) -> Expr{
    var array: Arr = Arr()
    arr.forEach { array.append($0.value) }
    let newVar = Var.newVar
    return Foreach(arr: array, lambda: Lambda(vars: newVar, expr: lambda(Expr(newVar))))
}


/**
 * `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
 *
 * Providing a lambda which does not return a Boolean results in an “invalid argument” error.
 *
 * [Filtrer Reference](https://faunadb.com/documentation/queries#collection_functions-filter_lambda_expr_collection_coll)
 */
public func Filter<C: CollectionType where C.Generator.Element == Value>(arr arr: C, lambda: Expr) -> Expr{
    return Expr(fn(["filter": lambda.value, "collection": Arr(arr)] as Obj))
}

public func Filter<C: CollectionType where C.Generator.Element: Value>(arr arr: C, lambda: Expr) -> Expr{
    var array: Arr = Arr()
    arr.forEach { array.append($0) }
    return Filter(arr: array, lambda: lambda)
}

public func Filter<C: CollectionType where C.Generator.Element == Value>(arr arr: C, @noescape lambda: (Expr -> Expr)) -> Expr{
    let newVar = Var.newVar
    return Filter(arr: arr, lambda: Lambda(vars: newVar, expr: lambda(Expr(newVar))))
}

public func Filter<C: CollectionType where C.Generator.Element: ValueConvertible>(arr arr: C, @noescape lambda: (Expr -> Expr)) -> Expr{
    var array: Arr = Arr()
    arr.forEach { array.append($0.value) }
    let newVar = Var.newVar
    return Filter(arr: array, lambda: Lambda(vars: newVar, expr: lambda(Expr(newVar))))
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
public func Take(count count: Int, collection: Expr) -> Expr{
    return Expr(fn(["take": count, "collection": collection.value] as Obj))
}

public func Take(count count: Expr, collection: Expr) -> Expr{
    return Expr(fn(["take": count.value, "collection": collection.value] as Obj))
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
public func Drop(count count: Int, collection: Expr) -> Expr{
    return Expr(fn(["drop": count, "collection": collection.value] as Obj))
}

public func Drop(count count: Expr, collection: Expr) -> Expr{
    return Expr(fn(["drop": count.value, "collection": collection.value] as Obj))
}

/**
 * `Prepend` returns a new Array that is the result of prepending `elements` onto the Array `toCollection`.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */
public func Prepend(elements elements: Expr, toCollection collection: Expr) -> Expr{
    return Expr(fn(["collection": elements.value, "prepend": collection.value] as Obj))
}


/**
 * `Append` returns a new Array that is the result of appending `elements` onto the `toCollection` array.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 */
public func Append(elements elements: Expr, toCollection collection: Expr) -> Expr{
    return Expr(fn(["collection": elements.value, "append": collection.value] as Obj))
}
