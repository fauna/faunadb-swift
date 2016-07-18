//
//  MiscFuntions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct NextId: Expr {
    
    public let value: Value = fn(["next_id": Null()])

    /**
     * `NextId` produces a new identifier suitable for use when constructing refs.
     *
     * [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - returns: A NextId expression.
     */
    public init(){
    }
}

public struct Equals: Expr {
    
    public let value: Value
    
    /**
     *  `Equals` tests equivalence between a list of values.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: values to test equivalence.
     
     - returns: A equals expression.
     */
    public init(terms: Expr...){
        value = fn(["equals": varargs(terms)])
    }
}



public struct Contains: Expr {
    
    public let value: Value
    
    /**
     *  `Contains` returns true if the argument passed to `inExpr` contains a value at the specified `path`, and false otherwise.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter path:   Determines a location within `inExpr` data.
     - parameter inExpr: value or expression that prodices a value.
     
     - returns: A contains expression.
     */
    public init(pathComponents: PathComponentType..., inExpr: Expr){
        value = fn(["contains": varargs(pathComponents), "in": inExpr.value])
    }

    /**
     *  `Contains` returns true if the argument passed to `inExpr` contains a value at the specified `path`, and false otherwise.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter path:   Determines a location within `inExpr` data.
     - parameter inExpr: value or expression that prodices a value.
     
     - returns: A contains expression.
     */
    public init(path: Expr, inExpr: Expr){
        value = fn(["contains": path.value, "in": inExpr.value])
    }
}

public struct Select: Expr {
    
    public let value: Value
    
    /**
     *  `Select` traverses into the argument passed to from and returns the resulting value. If the path does not exist, it results in an error.
     *
     * [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter path:         determines a location within `inExpr` data.
     - parameter from:         value or expression that evaluates into a Value to get the data located in path.
     - parameter defaultValue: -
     
     - returns: A Select expression.
     */
    public init(pathComponents: PathComponentType..., from: Expr, defaultValue: Expr? = nil){
        var obj: Obj = ["select": varargs(pathComponents), "from": from.value]
        obj["default"] = defaultValue?.value
        value = fn(obj)
    }
    
    /**
     *  `Select` traverses into the argument passed to from and returns the resulting value. If the path does not exist, it results in an error.
     *
     * [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter path:         determines a location within `inExpr` data.
     - parameter from:         value or expression that evaluates into a Value to get the data located in path.
     - parameter defaultValue: -
     
     - returns: A Select expression.
     */
    public init(path: Expr, from: Expr, defaultValue: Expr? = nil){
        var obj: Obj = ["select": path.value, "from": from.value]
        obj["default"] = defaultValue?.value
        value = fn(obj)
    }
}

public struct Add: Expr {
    
    public let value: Value
    
    /**
     *  `Add` computes the sum of a list of numbers. Attempting to add fewer that two numbers will result in an “invalid argument” error.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["add": varargs(terms)])
    }
}

public struct Multiply: Expr {
    
    public let value: Value

    /**
     *  `Multiply` computes the product of a list of numbers. Attempting to multiply fewer than two numbers will result in an “invalid argument” error.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["multiply": varargs(terms)])
    }
}

public struct Subtract: Expr {
    
    public let value: Value
    
    /**
     *  `Subtract` computes the difference of a list of numbers. Attempting to subtract fewer than two numbers will result in an “invalid argument” error.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["subtract": varargs(terms)])
    }
}

public struct Divide: Expr {
    
    public let value: Value

    /**
     *  `Divide` computes the quotient of a list of numbers.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["divide": varargs(terms)])
    }
}


public struct Modulo: Expr {
    
    public let value: Value

    /**
     *  `Modulo` computes the remainder after division of a list of numbers.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["modulo": varargs(terms)])
    }
}

public struct LT: Expr {
    
    public let value: Value
    
    /**
     *  `LT` returns true if each specified value compares as less than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["lt": varargs(terms)])
    }
}

public struct LTE: Expr {
    
    public let value: Value
    

    /**
     *  `LTE` returns true if each specified value compares as less than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns  true if it has a single argument.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["lte": varargs(terms)])
    }
}

public struct GT: Expr {
    
    public let value: Value
    
    /**
     `GT` returns true if each specified value compares as greater than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
     
     [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["gt": varargs(terms)])
    }
}

public struct GTE: Expr {
    
    public let value: Value
    
    /**
     *  `GTE` returns true if each specified value compares as greater than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: number or expression that evalues to a number.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["gte": varargs(terms)])
    }
}

public struct And: Expr {
    
    public let value: Value
    
    /**
     *  `And` computes the conjunction of a list of boolean values, returning `true` if all elements are true, and `false` otherwise.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: boolean or expression that evalues to a boolean.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["and": varargs(terms)])
    }
}

public struct Or: Expr {
    
    public let value: Value
    

    /**
     *  `Or` computes the disjunction of a list of boolean values, returning `true` if any elements are true, and `false` otherwise.
     *
     *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: boolean or expression that evalues to a boolean.
     
     - returns: A Add expression.
     */
    public init(terms: Expr...){
        value = fn(["or": varargs(terms)])
    }
}

public struct Not: Expr {
    
    public let value: Value
    

    /**
     *  `Not` computes the negation of a boolean expression. Computes the negation of a boolean value, returning true if its argument is false, or false if its argument is true.
     
     - parameter boolExpr: indicates the expression to negate.
     *
     * [Reference](https://faunadb.com/documentation/queries#misc_functions)
     
     - parameter terms: boolean or expression that evalues to a boolean.
     
     - returns: A Add expression.
     */
    public init(boolExpr expr: Expr){
        value = fn(["not": expr.value])
    }
}

