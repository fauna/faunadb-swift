//
//  CollectionFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 *  `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
 *
 *  `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter collection:    collection to perform map expression.
 - parameter lambda:        lambda expression to apply to each collection item.
 
 - returns: A Map expression.
 */
public func Map(collection collection: Expr, lambda: Expr) -> Expr {
    return Expr(fn(["map": lambda.value, "collection": collection.value]))
}

/**
 *  `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
 *
 *  `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter collection:    collection to perform map expression.
 - parameter lambda:        lambda expression to apply to each collection item.
 
 - returns: A Map expression.
 */
public func Map(collection collection: Expr, @noescape lambda: (Expr)-> Expr) -> Expr {
    return Map(collection: collection, lambda: Lambda(lambda: lambda))
}


/**
 * `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
 *
 * `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter collection: collection to perform foreach expression.
 - parameter lambda:     lambda expression to apply to each collection item.
 
 - returns: A Foreach expression.
 */
public func Foreach(collection collection: Expr, lambda: Expr) -> Expr {
    return Expr(fn(["foreach": lambda.value, "collection": collection.value]))
}

/**
 * `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
 *
 * `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter collection: collection to perform foreach expression.
 - parameter lambda:     lambda expression to apply to each collection item.
 
 - returns: A Foreach expression.
 */
public func Foreach(collection collection: Expr, @noescape lambda: (Expr)-> Expr) -> Expr {
    return Foreach(collection: collection, lambda: Lambda(lambda: lambda))
}

/**
 * `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
 *
 * Providing a lambda which does not return a Boolean results in an “invalid argument” error.
 *
 * [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter collection: collection to perform filter expression.
 - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.
 
 - returns: A Filter expression.
 */
public func Filter(collection collection: Expr, lambda: Expr) -> Expr {
    return Expr(fn(["filter": lambda.value, "collection": collection.value]))
}

/**
 * `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
 *
 * Providing a lambda which does not return a Boolean results in an “invalid argument” error.
 *
 * [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter collection: collection to perform filter expression.
 - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.
 
 - returns: A Filter expression.
 */
public func Filter(collection collection: Expr, @noescape lambda: (Expr)-> Expr) -> Expr {
    return Filter(collection: collection, lambda: Lambda(lambda: lambda))
}

/**
 * `Take` returns a new Collection or Page that contains num elements from the head of the Collection or Page coll. 
 * If `take` value is zero or negative, the resulting collection is empty.
 * When applied to a page, the returned page’s after cursor is adjusted to only cover the taken elements.
 
 * As special cases:
 * * If `take` value is negative, after will be set to the same value as the original page’s  before.
 * * If all elements from the original page were taken, after does not change.
 *
 * [Reference](https://faunadb.com/documentation/queries#collection_functions)

 - parameter count:      number of items to take.
 - parameter collection: collection or page.
 
 - returns: A take expression.
 */
public func Take(count count: Int, collection: Expr) -> Expr{
    return Expr(fn(["take": count, "collection": collection.value]))
}

/**
 * `Take` returns a new Collection or Page that contains num elements from the head of the Collection or Page coll.
 * If `take` value is zero or negative, the resulting collection is empty.
 * When applied to a page, the returned page’s after cursor is adjusted to only cover the taken elements.
 
 * As special cases:
 * * If `take` value is negative, after will be set to the same value as the original page’s  before.
 * * If all elements from the original page were taken, after does not change.
 *
 * [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter count:      number of items to take.
 - parameter collection: collection or page.
 
 - returns: A take expression.
 */
public func Take(count count: Expr, collection: Expr) -> Expr{
    return Expr(fn(["take": count.value, "collection": collection.value]))
}

/**
 * `Drop` returns a new Arr or Page that contains the remaining elements, after num have been removed from the head of the Arr or Page coll. If `drop` value is zero or negative, elements of coll are returned unmodified.
 *
 * When applied to a page, the returned page’s before cursor is adjusted to exclude the dropped elements. As special cases:
 * * If `drop` value is negative, before does not change.
 * * Otherwise if all elements from the original page were dropped (including the case where the page was already empty), before will be set to same value as the original page’s after.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter count:      number of items to drop.
 - parameter collection: collection or page.
 
 - returns: A Drop expression.
 */
public func Drop(count count: Int, collection: Expr) -> Expr{
    return Expr(fn(["drop": count, "collection": collection.value]))
}

/**
 * `Drop` returns a new Arr or Page that contains the remaining elements, after num have been removed from the head of the Arr or Page coll. If `drop` value is zero or negative, elements of coll are returned unmodified.
 *
 * When applied to a page, the returned page’s before cursor is adjusted to exclude the dropped elements. As special cases:
 * * If `drop` value is negative, before does not change.
 * * Otherwise if all elements from the original page were dropped (including the case where the page was already empty), before will be set to same value as the original page’s after.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter count:      number of items to drop.
 - parameter collection: collection or page.
 
 - returns: A Drop expression.
 */
public func Drop(count count: Expr, collection: Expr) -> Expr{
    return Expr(fn(["drop": count.value, "collection": collection.value]))
}

/**
 * `Prepend` returns a new Array that is the result of prepending `elements` onto the Array `toCollection`.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)

 - parameter elements:     elements to prepend onto `toCollection` collection.
 - parameter toCollection: collection.
 
 - returns: A Prepend expression.
 */
public func Prepend(elements elements: Expr, toCollection collection: Expr) -> Expr{
    return Expr(fn(["collection": elements.value, "prepend": collection.value]))
}

/**
 * `Append` returns a new Array that is the result of appending `elements` onto the `toCollection` array.
 *
 *  [Reference](https://faunadb.com/documentation/queries#collection_functions)
 
 - parameter elements:   elementos to append to `toCollectiopn` collection.
 - parameter toCollection: collection.
 
 - returns: An Append expression.
 */
public func Append(elements elements: Expr, toCollection collection: Expr) -> Expr{
    return Expr(fn(["collection": elements.value, "append": collection.value]))
}
