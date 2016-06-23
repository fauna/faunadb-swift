//
//  MiscFuntions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/13/16.
//
//

import Foundation

/**
 *  `Equals` tests equivalence between a list of values.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Equals: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Equals: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["equals": terms.varArgsToAnyObject ]
    }
}


/**
 *  `Contains` returns true if the argument passed to `in` contains a value at the specified `path`, and false otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Contains: Expr {
    
    let path: [Expr]
    let inExpr: Expr
    
    public init(path: PathComponentType..., inExpr: Expr){
        self.path = path.map { $0 as Expr }
        self.inExpr = inExpr
    }
    
    public init(pathExpr: Expr, inExpr: Expr){
        self.path = [pathExpr]
        self.inExpr = inExpr
    }
}

extension Contains: Encodable {
    public func toJSON() -> AnyObject {
        return ["contains": path.varArgsToAnyObject, "in": inExpr.toJSON()]
    }
}

/**
 *  `Select` traverses into the argument passed to from and returns the resulting value. If the path does not exist, it results in an error.
 *
 * [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Select: Expr {
    
    let path: [Expr]
    let from: Expr
    let defaultValue: Expr?
    
    public init(path: PathComponentType..., from: Expr, defaultValue: Expr? = nil){
        self.path = path.map { $0 as Expr }
        self.from = from
        self.defaultValue = defaultValue
    }
    
    public init(pathExpr: Expr, from: Expr, defaultValue: Expr? = nil){
        self.path = [pathExpr]
        self.from = from
        self.defaultValue = defaultValue
    }
    
    
}

extension Select: Encodable {
    
    public func toJSON() -> AnyObject {
        var result = [ "select": path.varArgsToAnyObject,
                   "from": from.toJSON()]
        result["default"] = defaultValue?.toJSON()
        return result
    }
}

/**
 *  `Add` computes the sum of a list of numbers. Attempting to add fewer that two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Add: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Add: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["add": terms.varArgsToAnyObject ]
    }
}

/**
 *  `Multiply` computes the product of a list of numbers. Attempting to multiply fewer than two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Multiply: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Multiply: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["multiply": terms.varArgsToAnyObject ]
    }
}

/**
 *  `Subtract` computes the difference of a list of numbers. Attempting to subtract fewer than two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Subtract: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Subtract: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["subtract": terms.varArgsToAnyObject ]
    }
}


/**
 *  `Divide` computes the quotient of a list of numbers.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Divide: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Divide: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["divide": terms.varArgsToAnyObject ]
    }
}


/**
 *  `Modulo` computes the remainder after division of a list of numbers.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Modulo: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Modulo: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["modulo": terms.varArgsToAnyObject ]
    }
}

/**
 *  `LT` returns true if each specified value compares as less than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct LT: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension LT: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["lt": terms.varArgsToAnyObject ]
    }
}

/**
 *  `LTE` returns true if each specified value compares as less than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns  true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct LTE: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension LTE: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["lte": terms.varArgsToAnyObject ]
    }
}

/**
 *  `GT` returns true if each specified value compares as greater than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct GT: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension GT: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["gt": terms.varArgsToAnyObject ]
    }
}

/**
 *  `GTE` returns true if each specified value compares as greater than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct GTE: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension GTE: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["gte": terms.varArgsToAnyObject ]
    }
}



/**
 *  `And` computes the conjunction of a list of boolean values, returning `true` if all elements are true, and `false` otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct And: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension And: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["and": terms.varArgsToAnyObject ]
    }
}


/**
 *  `Or` computes the disjunction of a list of boolean values, returning `true` if any elements are true, and `false` otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Or: Expr {
    let terms: [Expr]
    
    init(terms: Expr...){
        self.terms = terms
    }
}

extension Or: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["or": terms.varArgsToAnyObject ]
    }
}


/**
 *  `Not` computes the negation of a boolean expression.
 *
 * [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public struct Not: Expr {
    let expr: Expr
    
    /**
     Computes the negation of a boolean value, returning true if its argument is false, or false if its argument is true.
     
     - parameter boolExpr: indicates the expression to negate.
     
     - returns: A Not expression.
     */
    public init(boolExpr: Expr){
        self.expr = boolExpr
    }
}

extension Not: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["not": expr.toJSON()]
    }
}



