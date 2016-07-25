//
//  BasicFormsFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

//MARK: Variable

public struct Var: Expr {
    let name: String
    
    /**
     A `Var` expression refers to the value of a variable `varname` in the current lexical scope. Referring to a variable that is not in scope results in an “unbound variable” error.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter name: variable name
     
     - returns: A variable instance.
     */
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
        return Obj(fnCall:["var": name])
    }
}

public struct Let: Expr {
    
    public var value: Value
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter bindings: Each array item is a tuple containing the variable name and its corresponding value.
     - parameter expr:     Lambda expression where binding variables are available to use.
     
     - returns: A Let expression.
     */
    public init(bindings:[(String, Expr)], in: Expr){
        var bindingsData = Obj(fnCall:[:])
        bindings.forEach { key, value in  bindingsData[key] = value  }
        value = Obj(fnCall:["let": bindingsData, "in": `in`])
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter v1:   variable name
     - parameter e1:   variable value
     - parameter in: Lambda expression where binding variables are available to use.
     
     - returns: A Let expression.
     */
    init(v1: String, e1: Expr, @noescape `in`: (Expr -> Expr)){
        self.init(bindings: [(v1, e1)], in: `in`(Var(v1)))
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter v1:   variable1 name
     - parameter e1:   variable1 value
     - parameter v2:   variable2 name
     - parameter e2:   variable2 value
     - parameter in: Lambda expression where binding variables are available to use.
     
     - returns: A Let expression.
     */
    init(v1: String, e1: Expr,
         v2: String, e2: Expr, @noescape `in`: ((Expr, Expr) -> Expr)){
         self.init(bindings: [(v1, e1), (v2, e2)], in: `in`(Var(v1), Var(v2)))
    }
    
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter v1:   variable1 name
     - parameter e1:   variable1 value
     - parameter v2:   variable1 name
     - parameter e2:   variable2 value
     - parameter v3:   variable1 name
     - parameter e3:   variable3 value
     - parameter in: Lambda expression where binding variables are available to use.
     
     - returns: A Let expression.
     */
    init(v1: String, e1: Expr,
         v2: String, e2: Expr,
         v3: String, e3: Expr ,
         @noescape `in`: ((Expr, Expr, Expr) -> Expr)){
         self.init(bindings: [(v1, e1), (v2, e2), (v3, e3)], in: `in`(Var(v1), Var(v2), Var(v3)))
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     - parameter v1:   variable1 name
     - parameter e1:   variable1 value
     - parameter v2:   variable2 name
     - parameter e2:   variable2 value
     - parameter v3:   variable3 name
     - parameter e3:   variable3 value
     - parameter v4:   variable4 name
     - parameter e4:   variable4 value
     - parameter in: Lambda expression where binding variables are available to use.
     
     - returns: A Let expression.
     */
    init(v1: String, e1: Expr,
         v2: String, e2: Expr,
         v3: String, e3: Expr,
         v4: String, e4: Expr,
         @noescape `in`: ((Expr, Expr, Expr, Expr) -> Expr)){
         self.init(bindings: [(v1, e1), (v2, e2), (v3, e3), (v4, e4)], in: `in`(Var(v1), Var(v2), Var(v3), Var(v4)))
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter v1:   variable1 name
     - parameter e1:   variable1 value
     - parameter v2:   variable2 name
     - parameter e2:   variable2 value
     - parameter v3:   variable3 name
     - parameter e3:   variable3 value
     - parameter v4:   variable4 name
     - parameter e4:   variable4 value
     - parameter v5:   variable5 name
     - parameter e5:   variable5 value
     - parameter in: Lambda expression where binding variables are available to use.
     
     - returns: A Let expression.
     */
    init(v1: String, e1: Expr,
                v2: String, e2: Expr,
                v3: String, e3: Expr,
                v4: String, e4: Expr,
                v5: String, e5: Expr,
                @noescape `in`: ((Expr, Expr, Expr, Expr, Expr) -> Expr)){
        self.init(bindings: [(v1, e1), (v2, e2), (v3, e3), (v4, e4), (v5, e5)], in: `in`(Var(v1), Var(v2), Var(v3), Var(v4), Var(v5)))
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter e1:  variable1 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1 value.
     
     - returns: A Let expression.
     */
    public init(_ e1: Expr, @noescape `in`: (Expr -> Expr)){
        self.init(v1: Var.newName, e1: e1, in: `in`)
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter e1: variable1 value
     - parameter e2: variable2 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1 and e2 values respectively.
     
     - returns: A Let expression.
     */
    public init(_ e1: Expr, _ e2: Expr, @noescape `in`: ((Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, in: `in`)
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter e1: variable1 value
     - parameter e2: variable2 value
     - parameter e3: variable3 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1, e2, e3 values respectively.
     
     - returns: A Let expression.
     */
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, @noescape `in`: ((Expr, Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, in: `in`)
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter e1: variable1 value
     - parameter e2: variable2 value
     - parameter e3: variable3 value
     - parameter e4: variable4 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1, e2, e3 values respectively.
     
     - returns: A Let expression.
     */
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, @noescape `in`: ((Expr, Expr, Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, v4: Var.newName, e4: e4, in: `in`)
    }
    
    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter e1: variable1 value
     - parameter e2: variable2 value
     - parameter e3: variable3 value
     - parameter e4: variable4 value
     - parameter e5: variable5 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1, e2, e3 values respectively.
     
     - returns: A Let expression.
     */
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, _ e5: Expr, @noescape `in`: ((Expr, Expr, Expr, Expr, Expr) -> Expr)){
        self.init(v1: Var.newName, e1: e1, v2: Var.newName, e2: e2, v3: Var.newName, e3: e3, v4: Var.newName, e4: e4, v5: Var.newName, e5: e5, in: `in`)
    }
}
    

public struct If: Expr {
    
    public var value: Value
    
    /**
     If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter pred: Predicate expression. Must evaluate to Bool value.
     - parameter then: Expression to execute if pred evaluation is true.
     - parameter else: Expression to execute if pred evaluation fails.
     
     - returns: An If expression.
     */
    public init(pred: Expr, @autoclosure `then`: (()-> Expr), @autoclosure `else`: (()-> Expr)){
        value = Obj(fnCall:["if": pred, "then": `then`(), "else": `else`()])
    }
}

public struct Do: Expr{

    public var value: Value
   
    /**
     Do sequentially evaluates its arguments, and returns the evaluation of the last expression. If no expressions are provided, do returns an error.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter exprs: Expressions to evaluate.
     
     - returns: A Do expression.
     */
    public init(exprs: Expr...){
        value = Obj(fnCall:["do": varargs(exprs)])
    }
    
}


public struct Lambda: Expr {

    public var value: Value

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter vars: variables
     - parameter expr: Expression in which the variables are binding
     
     - returns: A Let expression.
     */
    public init(vars: Var..., expr: Expr){
        value = Obj(fnCall:["expr": expr, "lambda": varargs(vars.map { $0.name })])
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr)-> Expr)){
        let newVar = Var.newVar
        self.init(vars: newVar, expr: lambda(newVar))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr, Expr)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        self.init(vars: newVar, newVar2, expr: lambda(newVar, newVar2))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr, Expr, Expr)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, expr: lambda(newVar, newVar2, newVar3))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr, Expr, Expr, Expr)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, expr: lambda(newVar, newVar2, newVar3, newVar4))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr, Expr, Expr, Expr, Expr)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        let newVar5 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, newVar5, expr: lambda(newVar, newVar2, newVar3, newVar4, newVar5))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr, Expr, Expr, Expr, Expr, Expr)-> Expr)){
        let newVar = Var.newVar
        let newVar2 = Var.newVar
        let newVar3 = Var.newVar
        let newVar4 = Var.newVar
        let newVar5 = Var.newVar
        let newVar6 = Var.newVar
        self.init(vars: newVar, newVar2, newVar3, newVar4, newVar5, newVar6, expr: lambda(newVar, newVar2, newVar3, newVar4, newVar5, newVar6))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.
     
     [Reference](https://faunadb.com/documentation/queries#basic_forms)
     
     - parameter lambda: lambda expression represented by a swift closure.
     
     - returns: A Let expression.
     */
    public init(@noescape lambda: ((Expr, Expr, Expr, Expr, Expr, Expr, Expr)-> Expr)){
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
