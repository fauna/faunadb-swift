//
//  CollectionFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Map: Expr {
    public let value: Value

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item.
     
     - returns: A Map expression.
     */
    public init(collection: Expr, lambda: Expr) {
        value = Obj(fnCall:["map": lambda, "collection": collection])
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item.
     
     - returns: A Map expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr)-> Expr){
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
    
    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression. Collection elements must be an array of 2 elements which will be bounded to lamba arguments.
     - parameter lambda:        lambda expression to apply to each collection item.
     
     - returns: A Map expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr, Expr)-> Expr){
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
    
    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 3 elements which will be bounded to lamba arguments.
     
     - returns: A Map expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr, Expr, Expr)-> Expr){
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
    
    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 4 elements which will be bounded to lamba arguments.

     
     - returns: A Map expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr, Expr, Expr, Expr)-> Expr){
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
    
    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 4 elements which will be bounded to lamba arguments.

     
     - returns: A Map expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr, Expr, Expr, Expr, Expr)-> Expr){
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
}

public struct Foreach: Expr {
    public let value: Value
    
    /**
     `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
     
     `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform foreach expression.
     - parameter lambda:     lambda expression to apply to each collection item.
     
     - returns: A Foreach expression.
     */
    public init(collection: Expr, lambda: Expr){
        value = Obj(fnCall:["foreach": lambda, "collection": collection])
    }

    /**
     `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
     
     `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform foreach expression.
     - parameter lambda:     lambda expression to apply to each collection item.
     
     - returns: A Foreach expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr)-> Expr) {
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
    
}

public struct Filter: Expr {
    public let value: Value
   
    /**
     `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
     
     Providing a lambda which does not return a Boolean results in an “invalid argument” error.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform filter expression.
     - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.
     
     - returns: A Filter expression.
     */
    public init(collection: Expr, lambda: Expr) {
        value = Obj(fnCall:["filter": lambda, "collection": collection])
    }

    /**
     `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
     
     Providing a lambda which does not return a Boolean results in an “invalid argument” error.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform filter expression.
     - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.
     
     - returns: A Filter expression.
     */
    public init(collection: Expr, @noescape lambda: (Expr)-> Expr){
        self.init(collection: collection, lambda: Lambda(lambda: lambda))
    }
    
}

public struct Take: Expr {
    
    public var value: Value
    
    /**
     `Take` returns a new Collection or Page that contains num elements from the head of the Collection or Page coll.
     If `take` value is zero or negative, the resulting collection is empty.
     When applied to a page, the returned page’s after cursor is adjusted to only cover the taken elements.
     
     As special cases:
     * If `take` value is negative, after will be set to the same value as the original page’s  before.
     * If all elements from the original page were taken, after does not change.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter count:      number of items to take.
     - parameter collection: collection or page.
     
     - returns: A take expression.
     */
    public init(count: Int, collection: Expr){
        self.init(count: count as Expr, collection: collection)
    }

    /**
     `Take` returns a new Collection or Page that contains num elements from the head of the Collection or Page coll.
     If `take` value is zero or negative, the resulting collection is empty.
     When applied to a page, the returned page’s after cursor is adjusted to only cover the taken elements.
     
     As special cases:
     * If `take` value is negative, after will be set to the same value as the original page’s  before.
     * If all elements from the original page were taken, after does not change.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter count:      number of items to take.
     - parameter collection: collection or page.
     
     - returns: A take expression.
     */
    public init (count: Expr, collection: Expr){
        value = Obj(fnCall:["take": count, "collection": collection])
    }
}

public struct Drop: Expr {
    public var value: Value

    /**
     `Drop` returns a new Arr or Page that contains the remaining elements, after num have been removed from the head of the Arr or Page coll. If `drop` value is zero or negative, elements of coll are returned unmodified.
     
     When applied to a page, the returned page’s before cursor is adjusted to exclude the dropped elements. As special cases:
     * If `drop` value is negative, before does not change.
     * Otherwise if all elements from the original page were dropped (including the case where the page was already empty), before will be set to same value as the original page’s after.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter count:      number of items to drop.
     - parameter collection: collection or page.
     
     - returns: A Drop expression.
     */
    public init(count: Int, collection: Expr){
        self.init(count: count as Expr, collection: collection)
    }

    /**
     `Drop` returns a new Arr or Page that contains the remaining elements, after num have been removed from the head of the Arr or Page coll. If `drop` value is zero or negative, elements of coll are returned unmodified.
     
     When applied to a page, the returned page’s before cursor is adjusted to exclude the dropped elements. As special cases:
     * If `drop` value is negative, before does not change.
     * Otherwise if all elements from the original page were dropped (including the case where the page was already empty), before will be set to same value as the original page’s after.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter count:      number of items to drop.
     - parameter collection: collection or page.
     
     - returns: A Drop expression.
     */
    public init(count: Expr, collection: Expr) {
        value = Obj(fnCall:["drop": count, "collection": collection])
    }
    
}

public struct Prepend: Expr {

    public var value: Value
    
    /**
     `Prepend` returns a new Array that is the result of prepending `elements` onto the Array `toCollection`.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter elements:     elements to prepend onto `toCollection` collection.
     - parameter toCollection: collection.
     
     - returns: A Prepend expression.
     */
    public init(elements: Expr, toCollection collection: Expr){
        value = Obj(fnCall:["collection": elements, "prepend": collection])
    }
}


public struct Append: Expr {
    
    public var value: Value

    /**
     `Append` returns a new Array that is the result of appending `elements` onto the `toCollection` array.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter elements:   elements to append to `toCollectiopn` collection.
     - parameter toCollection: collection.
     
     - returns: An Append expression.
     */
    public init(elements: Expr, toCollection collection: Expr){
        value = Obj(fnCall:["collection": elements, "append": collection])
    }
}
