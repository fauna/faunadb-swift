//
//  MiscFuntions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public let NextId = Expr(fn(Obj(("next_id", Null()))))

/**
 *  `Equals` tests equivalence between a list of values.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Equals(terms terms: Expr...) -> Expr{
    return Expr(fn(Obj(("equals", varargs(terms)))))
}


/**
 *  `Contains` returns true if the argument passed to `in` contains a value at the specified `path`, and false otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Contains(path path: PathComponentType..., inExpr: Expr) -> Expr{
    return Expr(fn(Obj(("contains", varargs(path)), ("in", inExpr.value))))
}
    
public func Contains(path: Expr, inExpr: Expr) -> Expr{
    return Expr(fn(Obj(("contains", path.value), ("in", inExpr.value))))
}

/**
 *  `Select` traverses into the argument passed to from and returns the resulting value. If the path does not exist, it results in an error.
 *
 * [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
    
public func Select(path path: PathComponentType..., from: Expr, defaultValue: Expr? = nil) -> Expr{
    var obj: Obj = ["select": varargs(path), "from": from.value]
    obj["default"] = defaultValue?.value
    return Expr(fn(obj))
}
    
public func Select(path: Expr, from: Expr, defaultValue: Expr? = nil) -> Expr{
    var obj: Obj = ["select": path.value, "from": from.value]
    obj["default"] = defaultValue?.value
    return Expr(fn(obj))
}

/**
 *  `Add` computes the sum of a list of numbers. Attempting to add fewer that two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Add(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("add", varargs(terms)))))
}


/**
 *  `Multiply` computes the product of a list of numbers. Attempting to multiply fewer than two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Multiply(terms: Expr...) -> Expr {
    return Expr(fn(Obj(("multiply", varargs(terms)))))
}

/**
 *  `Subtract` computes the difference of a list of numbers. Attempting to subtract fewer than two numbers will result in an “invalid argument” error.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Subtract(terms: Expr...) -> Expr {
    return Expr(fn(Obj(("subtract", varargs(terms)))))
}

/**
 *  `Divide` computes the quotient of a list of numbers.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Divide(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("divide", varargs(terms)))))
}


/**
 *  `Modulo` computes the remainder after division of a list of numbers.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Modulo(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("modulo", varargs(terms)))))
}

/**
 *  `LT` returns true if each specified value compares as less than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func LT(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("lt", varargs(terms)))))
}


/**
 *  `LTE` returns true if each specified value compares as less than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns  true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func LTE(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("lte", varargs(terms)))))
}

/**
 *  `GT` returns true if each specified value compares as greater than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func GT(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("gt", varargs(terms)))))
}

/**
 *  `GTE` returns true if each specified value compares as greater than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func GTE(terms: Expr...)-> Expr{
    return Expr(fn(Obj(("gte", varargs(terms)))))
}

/**
 *  `And` computes the conjunction of a list of boolean values, returning `true` if all elements are true, and `false` otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func And(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("and", varargs(terms)))))
}

/**
 *  `Or` computes the disjunction of a list of boolean values, returning `true` if any elements are true, and `false` otherwise.
 *
 *  [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Or(terms: Expr...) -> Expr{
    return Expr(fn(Obj(("or", varargs(terms)))))
}

/**
 *  `Not` computes the negation of a boolean expression.
 Computes the negation of a boolean value, returning true if its argument is false, or false if its argument is true.
 
 - parameter boolExpr: indicates the expression to negate.
 *
 * [Reference](https://faunadb.com/documentation/queries#misc_functions)
 */
public func Not(boolExpr expr: Expr) -> Expr {
    return Expr(fn(Obj(("not", expr.value))))
}


