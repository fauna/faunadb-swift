//
//  BasicForms.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/14/16.
//
//

import Foundation

/**
 *  A `Var` expression refers to the value of a variable `varname` in the current lexical scope. Referring to a variable that is not in scope results in an “unbound variable” error.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */
public struct Var: Value {
    let varname: String
    
    public init(_ varname: String){
        self.varname = varname
    }
    
    //MARK: Helpers
    
    internal static var index: Int = 0
    internal static var newName: String {
        if index == Int.max {
            index = 0
        }
        index = index + 1
        return "v_\(index)"
    }
    
    internal static func resetIndex(){
        index = 0
    }
    
    internal static var newVar: Var {
        return Var(newName)
    }
}

extension Var: Encodable {
    public func toJSON() -> AnyObject {
        return ["var": varname ]
    }
}

extension Var: StringLiteralConvertible {
    
    public init(stringLiteral value: String){
        varname = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        varname = value
    }
    
    public init(unicodeScalarLiteral value: String){
        varname = value
    }
    
}

/**
 *  `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */
public struct Let: FunctionType {
    
    let bindings: [(String, Expr)]
    let expr: Expr
    
    
    public init(v1: String, e1: Expr, @noescape `in`: (Expr -> Expr)){
        bindings = [(v1, e1)]
        expr = `in`(Var(v1))
    }
    
    public init(v1: String, e1: Expr,
                v2: String, e2: Expr, @noescape `in`: ((Expr, Expr) -> Expr)){
        bindings = [(v1, e1), (v2, e2)]
        expr = `in`(Var(v1), Var(v2))
    }
    
    public init(v1: String, e1: Expr,
                v2: String, e2: Expr,
                v3: String, e3: Expr , @noescape `in`: ((Expr, Expr, Expr) -> Expr)){
        bindings = [(v1, e1), (v2, e2), (v3, e3)]
        expr = `in`(Var(v1), Var(v2),Var(v3))
    }
    
    public init(v1: String, e1: Expr,
                v2: String, e2: Expr,
                v3: String, e3: Expr,
                v4: String, e4: Expr,
                @noescape `in`: ((Expr, Expr, Expr, Expr) -> Expr)){
        bindings = [(v1, e1), (v2, e2), (v3, e3), (v4, e4)]
        expr = `in`(Var(v1), Var(v2), Var(v3), Var(v4))
    }
    
    public init(v1: String, e1: Expr,
                v2: String, e2: Expr,
                v3: String, e3: Expr,
                v4: String, e4: Expr,
                v5: String, e5: Expr,
                @noescape `in`: ((Expr, Expr, Expr, Expr, Expr) -> Expr)){
        bindings = [(v1, e1), (v2, e2), (v3, e3), (v4, e4), (v5, e5)]
        expr = `in`(Var(v1), Var(v2), Var(v3), Var(v4), Var(v5))
    }

    
    public init(_ e1: Expr, @noescape `in`: (Expr -> Expr)){
        self.init(v1: Var.newName, e1: e1, in: `in`)
        
    }
    
    public init(_ e1: Expr, _ e2: Expr, @noescape `in`: ((Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, in: `in`)
    }
    
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, @noescape `in`: ((Expr, Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, in: `in`)
    }
    
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, @noescape `in`: ((Expr, Expr, Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, v4: Var.newName, e4: e4, in: `in`)
    }
    
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, _ e5: Expr, @noescape `in`: ((Expr, Expr, Expr, Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, v4: Var.newName, e4: e4, v5: Var.newName, e5: e5, in: `in`)
    }    
}

extension Let: Encodable {
    public func toJSON() -> AnyObject {
        var vars = [String: AnyObject]()
        bindings.forEach { vars[$0.0] = $0.1.toJSON() }
        return ["let": vars, "in": expr.toJSON()]
    }
}


/**
 *  If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
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
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
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
        return ["do": exprs.varArgsToAnyObject]
    }
}


/**
 *  `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`.
 *  The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */
public struct Lambda: Expr {
    
    let vars: [Var]
    let expr: Expr
    
    public init(vars: Var..., expr: Expr){
        self.vars = vars
        self.expr = expr
    }
    public init(@noescape lambda: ((Value)-> Expr)){
        let newVar = Var.newVar
        self.init(vars: newVar, expr: lambda(newVar))
    }
    
    public init(@noescape lambda: ((Value, Value)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        self.init(vars: newVar, newVar2, expr: lambda(newVar, newVar2))
    }
    
    public init(@noescape lambda: ((Value, Value, Value)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, expr: lambda(newVar, newVar2, newVar3))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, expr: lambda(newVar, newVar2, newVar3, newVar4))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value, Value)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        let newVar5 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, newVar5, expr: lambda(newVar, newVar2, newVar3, newVar4, newVar5))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value, Value, Value)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        let newVar5 = Var.newVar
        let newVar6 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, newVar5, newVar6, expr: lambda(newVar, newVar2, newVar3, newVar4, newVar5, newVar6))
    }
    
    public init(@noescape lambda: ((Value, Value, Value, Value, Value, Value, Value)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        let newVar5 = Var.newVar
        let newVar6 = Var.newVar
        let newVar7 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, newVar5, newVar6, newVar7, expr: lambda(newVar, newVar2, newVar3, newVar4, newVar5, newVar6, newVar7))
    }
}

extension Lambda: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["expr": expr.toJSON(), "lambda": vars.map { $0.varname as Expr }.varArgsToAnyObject]
    }
}

