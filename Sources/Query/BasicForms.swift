//
//  BasicForms.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 *  A `Var` expression refers to the value of a variable `varname` in the current lexical scope. Referring to a variable that is not in scope results in an “unbound variable” error.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */
public struct Var: ValueConvertible {
    let name: String
    
    public init(_ name: String){
        self.name = name
    }
    
    //MARK: Helpers
    
    private static var index: Int = 0
    private static var newName: String {
        index = index == Int.max ? 0 : index + 1
        return "v\(index)"
    }
    
    internal static func resetIndex(){
        index = 0
    }
    
    internal static var newVar: Var {
        return Var(newName)
    }
}

extension Var {
    public var value: Value {
        return fn(Obj(("var", name)))
    }
}

extension Var: StringLiteralConvertible {
    
    public init(stringLiteral value: String){
        name = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        name = value
    }
    
    public init(unicodeScalarLiteral value: String){
        name = value
    }
}

/**
 *  `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */

    
public func Let(bindings bindings:[(String, Expr)], expr: Expr) -> Expr{
    var bindingsData = Obj()
    bindings.forEach { bindingsData[$0.0] = $0.1.value  }
    return Expr(fn(["let": fn(bindingsData), "in": expr.value] as Obj))
}
    
public func Let(v1 v1: String, e1: Expr, @noescape `in`: (Expr -> Expr)) -> Expr{
    return Let(bindings: [(v1, e1)], expr: `in`(Expr(Var(v1))))
}

public func Let(v1 v1: String, e1: Expr,
                   v2: String, e2: Expr, @noescape `in`: ((Expr, Expr) -> Expr)) -> Expr{
    return Let(bindings: [(v1, e1), (v2, e2)], expr: `in`(Expr(Var(v1)), Expr(Var(v2))))
}

public func Let(v1 v1: String, e1: Expr,
            v2: String, e2: Expr,
            v3: String, e3: Expr , @noescape `in`: ((Expr, Expr, Expr) -> Expr)) -> Expr{
    return Let(bindings: [(v1, e1), (v2, e2), (v3, e3)], expr: `in`(Expr(Var(v1)), Expr(Var(v2)), Expr(Var(v3))))
}

public func Let(v1 v1: String, e1: Expr,
            v2: String, e2: Expr,
            v3: String, e3: Expr,
            v4: String, e4: Expr,
            @noescape `in`: ((Expr, Expr, Expr, Expr) -> Expr)) -> Expr{
    return Let(bindings: [(v1, e1), (v2, e2), (v3, e3), (v4, e4)], expr: `in`(Expr(Var(v1)), Expr(Var(v2)), Expr(Var(v3)), Expr(Var(v4))))
}

public func Let(v1 v1: String, e1: Expr,
            v2: String, e2: Expr,
            v3: String, e3: Expr,
            v4: String, e4: Expr,
            v5: String, e5: Expr,
            @noescape `in`: ((Expr, Expr, Expr, Expr, Expr) -> Expr)) -> Expr{
    return Let(bindings: [(v1, e1), (v2, e2), (v3, e3), (v4, e4), (v5, e5)], expr: `in`(Expr(Var(v1)), Expr(Var(v2)), Expr(Var(v3)), Expr(Var(v4)), Expr(Var(v5))))
}

public func Let(e1: Expr, @noescape `in`: (Expr -> Expr)) -> Expr{
    return Let(v1: Var.newName, e1: e1, in: `in`)
}

public func Let(e1: Expr, _ e2: Expr, @noescape `in`: ((Expr, Expr) -> Expr)) -> Expr{
    return Let(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, in: `in`)
}

public func Let(e1: Expr, _ e2: Expr, _ e3: Expr, @noescape `in`: ((Expr, Expr, Expr) -> Expr)) -> Expr{
    return Let(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, in: `in`)
}

public func Let(e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, @noescape `in`: ((Expr, Expr, Expr, Expr) -> Expr)) -> Expr{
    return Let(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, v4: Var.newName, e4: e4, in: `in`)
}

public func Let(e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, _ e5: Expr, @noescape `in`: ((Expr, Expr, Expr, Expr, Expr) -> Expr)) -> Expr{
    return Let(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, v4: Var.newName, e4: e4, v5: Var.newName, e5: e5, in: `in`)
}

/**
 *  If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */

/**
 If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.
 
 - parameter pred:   Predicate expression. Must evaluate to Bool value.
 - parameter `then`: Expression to execute if pred evaluation is true.
 - parameter `else`: Expression to execute if pred evaluation fails.
 
 - returns: An If expression.
 */
public func If(pred pred: Expr, @autoclosure `then`: (()-> Expr), @autoclosure `else`: (()-> Expr)) -> Expr{
    return Expr(fn(["if": pred.value, "then": `then`().value, "else": `else`().value] as Obj))
}

/**
 *  Do sequentially evaluates its arguments, and returns the evaluation of the last expression. If no expressions are provided, do returns an error.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */
/**
 Do sequentially evaluates its arguments, and returns the evaluation of the last expression. If no expressions are provided, do returns an error.
 
 - parameter exprs: Expressions to evaluate.
 
 - returns: A Do expression.
 */
public func Do(exprs exprs: Expr...) -> Expr{
    return Expr(fn(Obj(("do", varargs(exprs)))))
}

/**
 *  `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`.
 *  The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
 *
 * [Reference](https://faunadb.com/documentation/queries#basic_forms)
 */

    
public func Lambda(vars vars: Var..., expr: Expr) -> Expr{
    return Expr(fn(Obj(("expr", expr.value),("lambda", varargs(vars.map { $0.name })))))
}

public func Lambda(@noescape lambda lambda: ((Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    return Lambda(vars: newVar, expr: lambda(Expr(newVar)))
}

public func Lambda(@noescape lambda lambda: ((Expr, Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    return Lambda(vars: newVar, newVar2, expr: lambda(Expr(newVar), Expr(newVar2)))
}

public func Lambda(@noescape lambda lambda: ((Expr, Expr, Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    let newVar3 = Var.newVar
    return Lambda(vars: newVar, newVar2, newVar3, expr: lambda(Expr(newVar), Expr(newVar2), Expr(newVar3)))
}

public func Lambda(@noescape lambda lambda: ((Expr, Expr, Expr, Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    let newVar3 = Var.newVar
    let newVar4 = Var.newVar
    return Lambda(vars: newVar, newVar2, newVar3, newVar4, expr: lambda(Expr(newVar), Expr(newVar2), Expr(newVar3), Expr(newVar4)))
}

public func Lambda(@noescape lambda lambda: ((Expr, Expr, Expr, Expr, Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    let newVar3 = Var.newVar
    let newVar4 = Var.newVar
    let newVar5 = Var.newVar
    return Lambda(vars: newVar, newVar2, newVar3, newVar4, newVar5, expr: lambda(Expr(newVar), Expr(newVar2), Expr(newVar3), Expr(newVar4), Expr(newVar5)))
}

public func Lambda(@noescape lambda lambda: ((Expr, Expr, Expr, Expr, Expr, Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    let newVar3 = Var.newVar
    let newVar4 = Var.newVar
    let newVar5 = Var.newVar
    let newVar6 = Var.newVar
    return Lambda(vars: newVar, newVar2, newVar3, newVar4, newVar5, newVar6, expr: lambda(Expr(newVar), Expr(newVar2), Expr(newVar3), Expr(newVar4), Expr(newVar5), Expr(newVar6)))
}


public func Lambda(@noescape lambda lambda: ((Expr, Expr, Expr, Expr, Expr, Expr, Expr)-> Expr)) -> Expr{
    let newVar = Var.newVar
    let newVar2 = Var.newVar
    let newVar3 = Var.newVar
    let newVar4 = Var.newVar
    let newVar5 = Var.newVar
    let newVar6 = Var.newVar
    let newVar7 = Var.newVar
    return Lambda(vars: newVar, newVar2, newVar3, newVar4, newVar5, newVar6, newVar7, expr: lambda(Expr(newVar), Expr(newVar2), Expr(newVar3), Expr(newVar4), Expr(newVar5), Expr(newVar6), Expr(newVar7)))
}

