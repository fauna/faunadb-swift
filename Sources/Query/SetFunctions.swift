//
//  SetFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/13/16.
//
//
import Foundation



public protocol SetFunctionType: FunctionType {}

/**
 *  Match returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.
 */
public struct Match: SetFunctionType {
    let indexRef: Ref
    let terms: [Value]
    
    /**
     Creates a Match expression.
     
     - parameter indexRef: index to use to perform the match.
     - parameter terms:    terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.
     
     - returns: a Match expression.
     */
    public init(indexRef: Ref, terms: Value...){
        self.indexRef = indexRef
        self.terms = terms
    }
}

extension Match: Encodable {
    
    public func toJSON() -> AnyObject {
        if terms.count > 1 {
            return [ "match": indexRef.toJSON(),
                 "terms":  terms.map { $0.toJSON() }]
            
        }
        else if terms.count == 1 {
            return [ "match": indexRef.toJSON(),
                     "terms":  terms[0].toJSON()]
        }
        return ["match": indexRef.toJSON() ]
    }
}




/**
 *  Union represents the set of resources that are present in at least one of the specified sets.
 */
public struct Union: SetFunctionType {
    
    let sets: [SetFunctionType]
    
    /**
     Creates an Union expression.
     
     - parameter sets: sets of resources to perform Union expression.
     
     - returns: an Union expression.
     */
    public init(sets: SetFunctionType...){
        self.sets = sets
    }
    
}

extension Union: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["union" : sets.map { $0.toJSON() }]
    }
}

/**
 *  Intersection represents the set of resources that are present in all of the specified sets.
 */
public struct Intersection: SetFunctionType {
    
    let sets: [SetFunctionType]
    
    /**
     Creates an Intersection expression.
     
     - parameter sets: sets of resources to perform Intersection expression.
     
     - returns: an Intersection expression.
     */
    public init(sets: SetFunctionType...){
        self.sets = sets
    }
    
}

extension Intersection: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["intersection" : sets.map { $0.toJSON() }]
    }
}


/**
 *   Difference represents the set of resources present in the source set and not in any of the other specified sets.
 */
public struct Difference: SetFunctionType {
    
    let source: SetFunctionType
    let sets: [SetFunctionType]
    
    /**
     Creates an Difference expression.
     
     - parameter source: Difference resources must be present on source collection.
     - parameter sets:   Any resource present in sets respurces will not be present in Difference resource set.
     
     - returns: An Difference expression.
     */
    public init(source: SetFunctionType,  sets: SetFunctionType...){
        self.source = source
        self.sets = sets
    }
    
}

extension Difference: Encodable {
    
    public func toJSON() -> AnyObject {
        var array = [source]
        array.appendContentsOf(sets)
        return ["difference" : array.map { $0.toJSON() }]
    }
}


/**
 *  Distinct function returns the set after removing duplicates.
 */
public struct Distinct: SetFunctionType {
    
    let set: SetFunctionType
    
    /**
     Instantiate a Distinct expression.
     
     - parameter set: determines the set where distinct function should be performed.
     
     - returns: a Distinct instance.
     */
    public init(set: SetFunctionType){
        self.set = set
    }
}

extension Distinct: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["distinct": set.toJSON()]
    }
}




// Paginate(Union
// Paginate(Intersection
//


