//
//  MiscFuntions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/13/16.
//
//

import Foundation

public struct Equals: Expr {
    let terms: [Value]
    
    init(terms: Value...){
        self.terms = terms
    }
}

extension Equals: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["equals": terms.map { $0.toJSON()} ]
    }
}

/**
 *  Not computes the negation of a boolean expression.
 */
public struct Not: Expr {
    let expr: Expr
    
    /**
     Computes the negation of a boolean value, returning true if its argument is false, or false if its argument is true.
     
     - parameter bool: indicates the value to negate.
     
     - returns: A Not expression.
     */
    public init(bool: Bool){
        self.init(expr: bool)
    }
    
    /**
     Computes the negation of a boolean expression.
     
     - parameter expr: indicates the expression to negate.
     
     - returns: A Not expression.
     */
    public init(expr: Expr){
        self.expr = expr
    }
}

extension Not: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["not": expr.toJSON()]
    }
}
