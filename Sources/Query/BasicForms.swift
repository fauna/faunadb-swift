//
//  BasicForms.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/14/16.
//
//

import Foundation

/**
 *  If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.
 */
public struct If: FunctionType {
    
    let pred: Expr
    let `then`: Expr
    let `else`: Expr
    
    /**
     If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.
     
     - parameter pred:   Predicate expression. Must evaluate to Bool value.
     - parameter `then`: Expression to execute if pred evaluation is true.
     - parameter `else`: Expression to execute if pred evaluation fails.
     
     - returns: An If expression.
     */
    public init(pred: Expr, @autoclosure `then`: (()-> Expr), @autoclosure `else`: (()-> Expr)) {
        self.pred = pred
        self.`then` = `then`()
        self.`else` = `else`()
    }
}

extension If: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["if": pred.toJSON(),
                "then": `then`.toJSON(),
                "else": `else`.toJSON()]
    }
}

/**
 *  Do sequentially evaluates its arguments, and returns the evaluation of the last expression. If no expressions are provided, do returns an error.
 */
public struct Do: FunctionType {
    let exprs: [Expr]
    
    /**
     Do sequentially evaluates its arguments, and returns the evaluation of the last expression. If no expressions are provided, do returns an error.
     
     - parameter exprs: Expressions to evaluate.
     
     - returns: A Do expression.
     */
    public init (exprs: Expr...){
        self.exprs = exprs
    }
}

extension Do: Encodable {
    
    public func toJSON() -> AnyObject {
        let expArray = exprs.map { $0.toJSON() }
        return ["do": expArray]
    }
}


/**
 *  Lambda creates an anonymous function that binds one or more variables in the expression at expr.
 *  The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
 */
public struct Lambda {
    
    let vars: [Var]
    let expr: Expr
    
    public init(vars: Var..., expr: Expr){
        self.vars = vars.map { $0 as Var }
        self.expr = expr
    }
    public init(@noescape lambda: ((Value)-> Expr)){
        self.init(vars: "x", expr: lambda(Var("x")))
    }
    
    public init(@noescape lambda: ((Value, Value)-> Expr)){
        self.init(vars: "x", "y", expr: lambda(Var("x"), Var("y")))
    }
    
    public init(@noescape lambda: ((Value, Value, Value)-> Expr)){
        self.init(vars: "x", "y", "z", expr: lambda(Var("x"), Var("y"), Var("z")))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value)-> Expr)){
        self.init(vars: "x", "y", "z", "a", expr: lambda(Var("x"), Var("y"), Var("z"), Var("a")))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value, Value)-> Expr)){
        self.init(vars: "x", "y", "z", "a", "b", expr: lambda(Var("x"), Var("y"), Var("z"), Var("a"), Var("b")))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value, Value, Value)-> Expr)){
        self.init(vars: "x", "y", "z", "a", "b", "c", expr: lambda(Var("x"), Var("y"), Var("z"), Var("a"), Var("b"), Var("c")))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value, Value, Value, Value)-> Expr)){
        self.init(vars: "x", "y", "z", "a", "b", "c", "d", expr: lambda(Var("x"), Var("y"), Var("z"), Var("a"), Var("b"), Var("c"), Var("d")))
    }
}

extension Lambda: Encodable {
    public func toJSON() -> AnyObject {
        var result = ["expr": expr.toJSON()]
        result["lambda"] = {    if vars.count == 1 {
                                    return vars.first?.name
                                }
                                return vars.map { $0.name }
                            }()
        return result
    }
}

