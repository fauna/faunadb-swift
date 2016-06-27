//
//  SetFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/13/16.
//
//
import Foundation


/**
 *  `Match` returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.
 *
 * [Match Reference](https://faunadb.com/documentation/queries#sets-match_index_ref_terms_terms)
 */
public struct Match: FunctionType {
    let indexRef: Expr
    let terms: [Expr]
    
    /**
     Creates a Match expression.
     
     - parameter indexRef: index to use to perform the match.
     - parameter terms:    terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.
     
     - returns: a Match expression.
     */
    public init(index: Ref, terms: Expr...){
        self.indexRef = index
        self.terms = terms
    }
    
    public init(index: Ref){
        self.indexRef = index
        self.terms = []
    }
    
    
    public init(_ indexRefExpr: Expr, terms: Expr...){
        self.indexRef = indexRefExpr
        self.terms = terms
    }
    
    public init(_ indexRefExpr: Expr){
        self.indexRef = indexRefExpr
        self.terms = []
    }
}

extension Match: Encodable {
    
    public func toJSON() -> AnyObject {
        if terms > 0 {
            return [ "match": indexRef.toJSON(),
                     "terms":  terms.varArgsToAnyObject ]
        }
        return [ "match": indexRef.toJSON()]
    }
}




/**
 *  `Union` represents the set of resources that are present in at least one of the specified sets.
 *
 * [Union Reference](https://faunadb.com/documentation/queries#sets-union_set_1_set_2)
 */
public struct Union: FunctionType {
    
    let sets: [Expr]
    
    /**
     Creates an Union expression.
     
     - parameter sets: sets of resources to perform Union expression.
     
     - returns: an Union expression.
     */
    public init(sets: Expr...){
        self.sets = sets
    }
    
}

extension Union: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["union" : sets.varArgsToAnyObject]
    }
}

/**
 *  `Intersection` represents the set of resources that are present in all of the specified sets.
 *
 *  [Intersection Reference](https://faunadb.com/documentation/queries#sets-intersection_set_1_set_2)
 */
public struct Intersection: FunctionType {
    
    let sets: [Expr]
    
    /**
     Creates an Intersection expression.
     
     - parameter sets: sets of resources to perform Intersection expression.
     
     - returns: an Intersection expression.
     */
    public init(sets: Expr...){
        self.sets = sets
    }
    
}

extension Intersection: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["intersection" : sets.varArgsToAnyObject]
    }
}


/**
 * `Difference` represents the set of resources present in the source set and not in any of the other specified sets.
 *
 * [Difference Reference](https://faunadb.com/documentation/queries#sets-difference_source_set_1_set_2)
 */
public struct Difference: FunctionType {
    
    let sets: [Expr]
    
    /**
     Creates an Difference expression.
     
     - parameter source: Difference resources must be present on source collection.
     - parameter sets:   Any resource present in sets resources will not be present in Difference resource set.
     
     - returns: An Difference expression.
     */
    public init(source: Expr, sets: Expr...){
        var sourceC = [source]
        sourceC.appendContentsOf(sets)
        self.sets = sourceC
    }
    
}

extension Difference: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["difference" : sets.varArgsToAnyObject]
    }
}


/**
 *  Distinct function returns the set after removing duplicates.
 *
 * [Distinct Reference](https://faunadb.com/documentation/queries#sets-distinct_set)
 */
public struct Distinct: FunctionType {
    
    let set: Expr
    
    /**
     Instantiate a Distinct expression.
     
     - parameter set: determines the set where distinct function should be performed.
     
     - returns: a Distinct instance.
     */
    public init(set: Expr){
        self.set = set
    }
}

extension Distinct: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["distinct": set.toJSON()]
    }
}


/**
 *  `Join` derives a set of resources from target by applying each instance in `sourceSet` to `with` target. Target can be either an index reference or a lambda function
 *
 *  The index form is useful when the instances in the `sourceSet` match the terms in an index. The join returns instances from index (specified by with) that match the terms from `sourceSet`.
 *
 * [Join Reference](https://faunadb.com/documentation/queries#sets-join_source_set_with_target)
 */
public struct Join: FunctionType {
    
    let sourceSet: Expr
    let with: Expr
    
    /**
     Creates a `Join` expression.
     
     - parameter sourceSet: set to perform the join.
     - parameter with:      `with` target can be either an index reference or a lambda function.
     
     - returns: A `Join` Expression.
     */
    public init(sourceSet: Expr, with: Expr){
        self.sourceSet = sourceSet
        self.with = with
    }
    
}

extension Join: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["join": sourceSet.toJSON(),
                "with": with.toJSON()]
    }
}

