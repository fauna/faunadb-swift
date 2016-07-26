//
//  AuthenticationFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Login: Expr{
    
    public var value: Value
    
    /**
     `Login` creates a token for the provided ref.
     
     - parameter ref:    A `Ref` instance.
     - parameter params: Typically ["password": "the_password"]
     
     - returns: A `Login` expression.
     */
    public init(ref: Ref, params: Obj){
        self.init(ref: ref as Expr, params: params as Expr)
    }
    
    
    /**
     `Login` creates a token for the provided ref.
     
     - parameter ref:    A Ref instance or something that evaluates to a `Ref` instance.
     - parameter params: Expression which provides the password.
     
     - returns: A `Login` expression.
     */
    public init(ref: Expr, params: Expr){
        value = Obj(fnCall:["login": ref, "params": params])
    }
    
}


public struct Logout: Expr{
    
    public var value: Value
    
    /**
     `Logout` deletes all tokens associated with the current session if its parameter is `true`, or just the token used in this request otherwise.
     
     - parameter invalidateAll: if true deletes all tokens associated with the current session. If false it deletes just the token used in this request.
     
     - returns: A `Logout` expression.
     */
    public init(invalidateAll: Bool){
        self.init(invalidateAll: invalidateAll as Expr)
    }
    
    /**
     `Logout` deletes all tokens associated with the current session if its parameter is `true`, or just the token used in this request otherwise.
     
     - parameter invalidateAll: if true deletes all tokens associated with the current session. If false it deletes just the token used in this request.
     
     - returns: A `Logout` expression.
     */
    public init(invalidateAll: Expr){
        value = Obj(fnCall:["logout": invalidateAll])
    }
    
}


public struct Identify: Expr{
    
    public var value: Value
    
    /**
     `Identify` checks the given password against the ref’s credentials, returning `true` if the credentials are valid, or `false` otherwise.
     
     - parameter ref:      Identifies an instance.
     - parameter password: Password to check agains `ref` instance.
     
     - returns: A `Identify` expression.
     */
    public init(ref: Ref, password: String){
        self.init(ref: ref as Expr, password: password as Expr)
    }
    
    /**
     `Identify` checks the given password against the ref’s credentials, returning `true` if the credentials are valid, or `false` otherwise.
     
     - parameter ref:      Identifies an instance.
     - parameter password: Password to check agains `ref` instance.
     
     - returns: A `Identify` expression.
     */
    public init(ref: Expr, password: Expr){
        value = Obj(fnCall:["identify": ref, "password": password])
    }
}
