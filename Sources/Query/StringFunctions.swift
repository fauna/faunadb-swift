//
//  StringFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 7/11/16.
//
//

import Foundation

/**
 `Concat` joins a list of strings into a single string value.
 
 - parameter strs:      Expresion that should evaluate to a list of strings.
 - parameter separator: A string separating each element in the result. Optional. Default value: Empty String.

 - returns: A Concat expression.
 */
public func Concat(strList strList: Expr, separator: Expr? = nil) -> Expr{
    var obj: Obj = ["concat": strList.value]
    obj["separator"] = separator?.value
     return Expr(fn(obj))
}


/**
 * `Casefold` normalizes strings according to the Unicode Standard section 5.18 “Case Mappings”.
 
 * To compare two strings for case-insensitive matching, transform each string and use a binary comparison, such as  equals.
 
 - parameter str: Expression that exaluates to a string value.
 
 - returns: A Casefold expression.
 */
public func Casefold(str str: Expr) -> Expr {
    return Expr(fn(["casefold": str.value]))
}

