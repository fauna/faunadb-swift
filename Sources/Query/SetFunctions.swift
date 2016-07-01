//
//  SetFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
    
/**
 `Match` returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.
 
 - parameter indexRef: index to use to perform the match.
 - parameter terms:    terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.
 
 - returns: a Match expression.

[Match Reference](https://faunadb.com/documentation/queries#sets-match_index_ref_terms_terms)
 */
public func Match(index index: Ref, terms: Expr...) -> Expr{
    var obj: Obj = ["match": index.value]
    obj["terms"] = terms.count > 0 ? varargs(terms) : nil
    return Expr(fn(obj))
}


public func Match(index index: Ref) -> Expr{
    return Expr(fn(["match": index.value] as Obj))
}
    
    
public func Match(index: Expr, terms: Expr...) -> Expr{
    var obj: Obj = ["match": index.value]
    obj["terms"] = terms.count > 0 ? varargs(terms) : nil
    return Expr(fn(obj))
}

public func Match(index: Expr) -> Expr{
    return Expr(fn(["match": index.value] as Obj))
}

/**
 *  `Union` represents the set of resources that are present in at least one of the specified sets.
 *
 * [Union Reference](https://faunadb.com/documentation/queries#sets-union_set_1_set_2)
 */
public func Union(sets sets: Expr...) -> Expr{
    return Expr(fn(Obj(("union", varargs(sets)))))
}

/**
 *  `Intersection` represents the set of resources that are present in all of the specified sets.
 *
 *  [Intersection Reference](https://faunadb.com/documentation/queries#sets-intersection_set_1_set_2)
 */
/**
 Creates an Intersection expression.
 
 - parameter sets: sets of resources to perform Intersection expression.
 
 - returns: an Intersection expression.
 */
public func Intersection(sets sets: Expr...) -> Expr{
    return Expr(fn(Obj(("intersection", varargs(sets)))))
}


/**
 * `Difference` represents the set of resources present in the source set and not in any of the other specified sets.
 *
 * [Difference Reference](https://faunadb.com/documentation/queries#sets-difference_source_set_1_set_2)
 */
public func Difference(sets sets: Expr...) -> Expr{
    return Expr(fn(Obj(("difference", varargs(sets)))))
}

/**
 *  Distinct function returns the set after removing duplicates.
 *
 * [Distinct Reference](https://faunadb.com/documentation/queries#sets-distinct_set)
 */
/**
 Instantiate a Distinct expression.
 
 - parameter set: determines the set where distinct function should be performed.
 
 - returns: a Distinct instance.
 */
public func Distinct(set: Expr) -> Expr{
    return Expr(fn(Obj(("distinct", set.value))))
}

/**
 *  `Join` derives a set of resources from target by applying each instance in `sourceSet` to `with` target. Target can be either an index reference or a lambda function
 *
 *  The index form is useful when the instances in the `sourceSet` match the terms in an index. The join returns instances from index (specified by with) that match the terms from `sourceSet`.
 *
 * [Join Reference](https://faunadb.com/documentation/queries#sets-join_source_set_with_target)
 */
/**
 Creates a `Join` expression.
 
 - parameter sourceSet: set to perform the join.
 - parameter with:      `with` target can be either an index reference or a lambda function.
 
 - returns: A `Join` Expression.
 */
public func Join(sourceSet sourceSet: Expr, with: Expr) -> Expr{
    return Expr(fn(Obj(("join", sourceSet.value), ("with", with.value))))
}

