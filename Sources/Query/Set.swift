import Foundation

public struct Match: Fn {

    var call: Fn.Call

    /**
     `Match` returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter index: index to use to perform the match.
     - parameter terms: terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.

     - returns: a Match expression.
     */
    public init(index: Expr, terms: Expr...) {
        self.call = fn(
            "match" => index,
            "terms" => (terms.count > 0 ? varargs(terms) : nil)
        )
    }
}

public struct Union: Fn {

    var call: Fn.Call

    /**
     `Union` represents the set of resources that are present in at least one of the specified sets.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sets: sets of resources to perform Union expression.

     - returns: An Union Expression.
     */
    public init(_ sets: Expr...) {
        self.call = fn("union" => varargs(sets))
    }

}

public struct Intersection: Fn {

    var call: Fn.Call

    /**
     `Intersection` represents the set of resources that are present in all of the specified sets.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sets: sets of resources to perform Intersection expression.

     - returns: An Intersection expression.
     */
    public init(_ sets: Expr...) {
        self.call = fn("intersection" => varargs(sets))
    }

}

public struct Difference: Fn {

    var call: Fn.Call

    /**
     `Difference` represents the set of resources present in the source set and not in any of the other specified sets.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sets: sets of resources to perform Difference expression.

     - returns: An Intersection expression.
     */
    public init(_ sets: Expr...) {
        self.call = fn("difference" => varargs(sets))
    }

}

public struct Distinct: Fn {

    var call: Fn.Call

    /**
     Distinct function returns the set after removing duplicates.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter set: determines the set where distinct function should be performed.

     - returns: A Distinct expression.
     */
    public init(_ set: Expr) {
        self.call = fn("distinct" => set)
    }

}

public struct Join: Fn {

    var call: Fn.Call

    /**
     `Join` derives a set of resources from target by applying each instance in `sourceSet` to `with` target. Target can be either an index reference or a lambda function.
     The index form is useful when the instances in the `sourceSet` match the terms in an index. The join returns instances from index (specified by with) that match the terms from `sourceSet`.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sourceSet: set to perform the join.
     - parameter with:      `with` target can be either an index reference or a lambda function.

     - returns: A `Join` expression.
     */
    public init(_ sourceSet: Expr, with: Expr) {
        self.call = fn("join" => sourceSet, "with" => with)
    }

    public init(_ sourceSet: Expr, fn: (Expr) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

}
