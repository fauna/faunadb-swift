//
//  MiscFuntions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 * `NextId` produces a new identifier suitable for use when constructing refs.
 *  
 * [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - returns: A NextId expression.
 */
public let NextId = Expr(fn(["next_id": Null()]))

/**
 *  `Equals` tests equivalence between a list of values.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: values to test equivalence.
 
 - returns: A equals expression.
 */
public func Equals(terms terms: Expr...) -> Expr{
    return Expr(fn(["equals": varargs(terms)]))
}


/**
 *  `Contains` returns true if the argument passed to `inExpr` contains a value at the specified `path`, and false otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter path:   Determines a location within `inExpr` data.
 - parameter inExpr: value or expression that prodices a value.
 
 - returns: A contains expression.
 */
public func Contains(path path: PathComponentType..., inExpr: Expr) -> Expr{
    return Expr(fn(["contains": varargs(path), "in": inExpr.value]))
}

/**
 *  `Contains` returns true if the argument passed to `inExpr` contains a value at the specified `path`, and false otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter path:   Determines a location within `inExpr` data.
 - parameter inExpr: value or expression that prodices a value.
 
 - returns: A contains expression.
 */
public func Contains(path: Expr, inExpr: Expr) -> Expr{
    return Expr(fn(["contains": path.value, "in": inExpr.value]))
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
public func Select(path path: PathComponentType..., from: Expr, defaultValue: Expr? = nil) -> Expr{
    var obj: Obj = ["select": varargs(path), "from": from.value]
    obj["default"] = defaultValue?.value
    return Expr(fn(obj))
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
public func Select(path: Expr, from: Expr, defaultValue: Expr? = nil) -> Expr{
    var obj: Obj = ["select": path.value, "from": from.value]
    obj["default"] = defaultValue?.value
    return Expr(fn(obj))
}

/**
 *  `Add` computes the sum of a list of numbers. Attempting to add fewer that two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func Add(terms terms: Expr...) -> Expr{
    return Expr(fn(["add": varargs(terms)]))
}


/**
 *  `Multiply` computes the product of a list of numbers. Attempting to multiply fewer than two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func Multiply(terms terms: Expr...) -> Expr {
    return Expr(fn(["multiply": varargs(terms)]))
}

/**
 *  `Subtract` computes the difference of a list of numbers. Attempting to subtract fewer than two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func Subtract(terms terms: Expr...) -> Expr {
    return Expr(fn(["subtract": varargs(terms)]))
}

/**
 *  `Divide` computes the quotient of a list of numbers.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func Divide(terms terms: Expr...) -> Expr{
    return Expr(fn(["divide": varargs(terms)]))
}


/**
 *  `Modulo` computes the remainder after division of a list of numbers.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func Modulo(terms terms: Expr...) -> Expr{
    return Expr(fn(["modulo": varargs(terms)]))
}

/**
 *  `LT` returns true if each specified value compares as less than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func LT(terms terms: Expr...) -> Expr{
    return Expr(fn(["lt": varargs(terms)]))
}


/**
 *  `LTE` returns true if each specified value compares as less than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns  true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func LTE(terms terms: Expr...) -> Expr{
    return Expr(fn(["lte": varargs(terms)]))
}

/**
 *  `GT` returns true if each specified value compares as greater than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func GT(terms terms: Expr...) -> Expr{
    return Expr(fn(["gt": varargs(terms)]))
}

/**
 *  `GTE` returns true if each specified value compares as greater than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: number or expression that evalues to a number.
 
 - returns: A Add expression.
 */
public func GTE(terms terms: Expr...)-> Expr{
    return Expr(fn(["gte": varargs(terms)]))
}

/**
 *  `And` computes the conjunction of a list of boolean values, returning `true` if all elements are true, and `false` otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: boolean or expression that evalues to a boolean.
 
 - returns: A Add expression.
 */
public func And(terms terms: Expr...) -> Expr{
    return Expr(fn(["and": varargs(terms)]))
}

/**
 *  `Or` computes the disjunction of a list of boolean values, returning `true` if any elements are true, and `false` otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: boolean or expression that evalues to a boolean.
 
 - returns: A Add expression.
 */
public func Or(terms terms: Expr...) -> Expr{
    return Expr(fn(["or": varargs(terms)]))
}

/**
 *  `Not` computes the negation of a boolean expression. Computes the negation of a boolean value, returning true if its argument is false, or false if its argument is true.
 
 - parameter boolExpr: indicates the expression to negate.
 *
 * [Reference](https://faunadb.com/documentation/queries#misc_functions)
 
 - parameter terms: boolean or expression that evalues to a boolean.
 
 - returns: A Add expression.
 */
public func Not(boolExpr expr: Expr) -> Expr {
    return Expr(fn(["not": expr.value]))
}


