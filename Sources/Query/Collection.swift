import Foundation

public struct Map: Fn {

    var call: Fn.Call

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item.
     
     - returns: A Map expression.
     */
    public init(collection: Expr, to lambda: Expr) {
        self.call = fn("map" => lambda, "collection" => collection)
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item.
     
     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: (Expr) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression. Collection elements must be an array of 2 elements which will be bounded to lamba arguments.
     - parameter lambda:        lambda expression to apply to each collection item.
     
     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 3 elements which will be bounded to lamba arguments.
     
     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 4 elements which will be bounded to lamba arguments.

     
     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.
     
     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 4 elements which will be bounded to lamba arguments.

     
     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }
}

public struct Foreach: Fn {

    var call: Fn.Call

    /**
     `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
     
     `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform foreach expression.
     - parameter lambda:     lambda expression to apply to each collection item.
     
     - returns: A Foreach expression.
     */
    public init(collection: Expr, in lambda: Expr) {
        self.call = fn("foreach" => lambda, "collection" => collection)
    }

    /**
     `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.
     
     `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform foreach expression.
     - parameter lambda:     lambda expression to apply to each collection item.
     
     - returns: A Foreach expression.
     */
    public init(_ collection: Expr, _ fn: (Expr) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }
}

public struct Filter: Fn {

    var call: Fn.Call

    /**
     `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
     
     Providing a lambda which does not return a Boolean results in an “invalid argument” error.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform filter expression.
     - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.
     
     - returns: A Filter expression.
     */
    public init(collection: Expr, with lambda: Expr) {
        self.call = fn("filter" => lambda, "collection" => collection)
    }

    /**
     `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.
     
     Providing a lambda which does not return a Boolean results in an “invalid argument” error.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter collection: collection to perform filter expression.
     - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.
     
     - returns: A Filter expression.
     */
    public init(_ collection: Expr, _ fn: (Expr) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

}

public struct Take: Fn {

    var call: Fn.Call

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
    public init(count: Expr, from collection: Expr) {
        self.call = fn("take" => count, "collection" => collection)
    }
}

public struct Drop: Fn {

    var call: Fn.Call

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
    public init(count: Expr, from collection: Expr) {
        self.call = fn("drop" => count, "collection" => collection)
    }

}

public struct Prepend: Fn {

    var call: Fn.Call

    /**
     `Prepend` returns a new Array that is the result of prepending `elements` onto the Array `toCollection`.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter elements:     elements to prepend onto `toCollection` collection.
     - parameter toCollection: collection.
     
     - returns: A Prepend expression.
     */
    public init(elements: Expr, to collection: Expr) {
        self.call = fn("prepend" => elements, "collection" => collection)
    }
}

public struct Append: Fn {

    var call: Fn.Call

    /**
     `Append` returns a new Array that is the result of appending `elements` onto the `toCollection` array.
     
     [Reference](https://faunadb.com/documentation/queries#collection_functions)
     
     - parameter elements:   elements to append to `toCollectiopn` collection.
     - parameter toCollection: collection.
     
     - returns: An Append expression.
     */
    public init(elements: Expr, to collection: Expr) {
        self.call = fn("append" => elements, "collection" => collection)
    }

}
