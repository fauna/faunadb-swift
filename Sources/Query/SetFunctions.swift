//
//  SetFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
    
/**
 * `Match` returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 - parameter index: index to use to perform the match.
 - parameter terms: terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.
 
 - returns: a Match expression.
 */
public func Match(index index: Ref, terms: Expr...) -> Expr{
    var obj: Obj = ["match": index.value]
    obj["terms"] = terms.count > 0 ? varargs(terms) : nil
    return Expr(fn(obj))
}

/**
 * `Match` returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 - parameter index: index to use to perform the match.
 - parameter terms: terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.
 
 - returns: a Match expression.
 */
public func Match(index index: Expr, terms: Expr...) -> Expr{
    var obj: Obj = ["match": index.value]
    obj["terms"] = terms.count > 0 ? varargs(terms) : nil
    return Expr(fn(obj))
}

/**
 * `Union` represents the set of resources that are present in at least one of the specified sets.
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 - parameter sets: sets of resources to perform Union expression.
 
 - returns: An Union Expression.
 */
public func Union(sets sets: Expr...) -> Expr{
    return Expr(fn(Obj(("union", varargs(sets)))))
}

/**
 * `Intersection` represents the set of resources that are present in all of the specified sets.
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 - parameter sets: sets of resources to perform Intersection expression.
 
 - returns: An Intersection expression.
 */
public func Intersection(sets sets: Expr...) -> Expr{
    return Expr(fn(Obj(("intersection", varargs(sets)))))
}


/**
 * `Difference` represents the set of resources present in the source set and not in any of the other specified sets.
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 - parameter sets: sets of resources to perform Difference expression.
 
 - returns: An Intersection expression.
 */
public func Difference(sets sets: Expr...) -> Expr{
    return Expr(fn(Obj(("difference", varargs(sets)))))
}

/**
 * Distinct function returns the set after removing duplicates.
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 - parameter set: determines the set where distinct function should be performed.
 
 - returns: A Distinct expression.
 */
public func Distinct(set: Expr) -> Expr{
    return Expr(fn(Obj(("distinct", set.value))))
}

/**
 * `Join` derives a set of resources from target by applying each instance in `sourceSet` to `with` target. Target can be either an index reference or a lambda function.
 *  The index form is useful when the instances in the `sourceSet` match the terms in an index. The join returns instances from index (specified by with) that match the terms from `sourceSet`.
 *
 * [Reference](https://faunadb.com/documentation/queries#sets)
 
 
 - parameter sourceSet: set to perform the join.
 - parameter with:      `with` target can be either an index reference or a lambda function.
 
 - returns: A `Join` expression.
 */
public func Join(sourceSet sourceSet: Expr, with: Expr) -> Expr{
    return Expr(fn(Obj(("join", sourceSet.value), ("with", with.value))))
}

