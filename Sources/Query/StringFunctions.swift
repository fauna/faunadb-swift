//
//  StringFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Concat: Expr{

    public var value: Value
    
    /**
     `Concat` joins a list of strings into a single string value.
     
     - parameter strs:      Expresion that should evaluate to a list of strings.
     - parameter separator: A string separating each element in the result. Optional. Default value: Empty String.

     - returns: A Concat expression.
     */
    public init(strList: Expr, separator: Expr? = nil){
        value = {
            var obj = Obj(fnCall: ["concat": strList])
            obj["separator"] = separator
            return obj
        }()
    }
}


public struct Casefold: Expr{
    
    public var value: Value
    
    /**
     * `Casefold` normalizes strings according to the Unicode Standard section 5.18 “Case Mappings”.
     
     * To compare two strings for case-insensitive matching, transform each string and use a binary comparison, such as  equals.
     
     - parameter str: Expression that exaluates to a string value.
     
     - returns: A Casefold expression.
     */
    public init(str: Expr){
        value = Obj(fnCall:["casefold": str])
    }
}
