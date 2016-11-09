import Foundation

public struct Var: Fn {

    fileprivate let name: String

    var call: Fn.Call

    /**
     A `Var` expression refers to the value of a variable `varname` in the current lexical scope. Referring to a variable that is not in scope results in an “unbound variable” error.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter name: variable name

     - returns: A variable instance.
     */
    public init(_ name: String) {
        self.name = name
        self.call = fn("var" => name)
    }

    private static var atomicLabel = "FaunaDB.Var.Index"
    private static var index = AtomicInt(label: atomicLabel)

    internal static func resetIndex() {
        index = AtomicInt(label: atomicLabel)
    }

    fileprivate init() {
        self.init("v\(Var.index.incrementAndGet())")
    }
}

public struct Let: Fn {

    private struct Bindings: Fn {
        var call: Fn.Call
    }

    var call: Fn.Call

    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter bindings: Each array item is a tuple containing the variable name and its corresponding value.
     - parameter expr:     Lambda expression where binding variables are available to use.

     - returns: A Let expression.
     */
    public init(bindings: [(String, Expr?)], in: Expr) {
        self.call = fn(
            "let" => Let.Bindings(call: Dictionary(pairs: bindings).mapValuesT { $0 ?? NullV() }),
            "in" => `in`
        )
    }

    public init(bindings: (String, Expr?)..., in: () -> Expr) {
        self.init(bindings: bindings, in: `in`())
    }

    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter e1:  variable1 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1 value.

     - returns: A Let expression.
     */
    public init(_ e1: Expr, in: (Expr) -> Expr) {
        let v1 = Var()
        self.init(bindings: [v1.name => e1], in: `in`(v1))
    }

    /**
     `Let` binds values to one or more variables. Variable values cannot refer to other variables defined in the same let expression. Variables are lexically scoped to the expression passed via `in`.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter e1: variable1 value
     - parameter e2: variable2 value
     - parameter in: Lambda expression as a swift closure. Clousure argument can be used as e1 and e2 values respectively.

     - returns: A Let expression.
     */
    public init(_ e1: Expr, _ e2: Expr, in: (Expr, Expr) -> Expr) {
        let v1 = Var()
        let v2 = Var()

        self.init(
            bindings: [
                v1.name => e1,
                v2.name => e2
            ],
            in: `in`(v1, v2)
        )
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
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, in: (Expr, Expr, Expr) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()

        self.init(
            bindings: [
                v1.name => e1,
                v2.name => e2,
                v3.name => e3
            ],
            in: `in`(v1, v2, v3)
        )
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
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, in: (Expr, Expr, Expr, Expr) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        let v4 = Var()

        self.init(
            bindings: [
                v1.name => e1,
                v2.name => e2,
                v3.name => e3,
                v4.name => e4
            ],
            in: `in`(v1, v2, v3, v4)
        )
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
    public init(_ e1: Expr, _ e2: Expr, _ e3: Expr, _ e4: Expr, _ e5: Expr, in: (Expr, Expr, Expr, Expr, Expr) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        let v4 = Var()
        let v5 = Var()

        self.init(
            bindings: [
                v1.name => e1,
                v2.name => e2,
                v3.name => e3,
                v4.name => e4,
                v5.name => e5
            ],
            in: `in`(v1, v2, v3, v4, v5)
        )
    }
}

public struct If: Fn {

    var call: Fn.Call

    /**
     If evaluates and returns then expr or else expr depending on the value of pred. If cond evaluates to anything other than a Boolean, if returns an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter pred: Predicate expression. Must evaluate to Bool value.
     - parameter then: Expression to execute if pred evaluation is true.
     - parameter else: Expression to execute if pred evaluation fails.

     - returns: An If expression.
     */
    public init(_ pred: Expr, then: @autoclosure () -> Expr, else: @autoclosure () -> Expr) {
        self.call = fn("if" => pred, "then" => `then`(), "else" => `else`())
    }
}

public struct Do: Fn {

    var call: Fn.Call

    /**
     Do sequentially evaluates its arguments, and returns the evaluation of the last expression. If no expressions are provided, do returns an error.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter exprs: Expressions to evaluate.

     - returns: A Do expression.
     */
    public init(_ exprs: Expr...) {
        self.call = fn("do" => varargs(exprs))
    }

}

public struct Lambda: Fn {

    var call: Fn.Call

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter vars: variables
     - parameter expr: Expression in which the variables are binding

     - returns: A Let expression.
     */
    public init(vars: Expr..., in expr: Expr) {
        self.call = fn("lambda" => varargs(vars), "expr" => expr)
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter lambda: lambda expression represented by a swift closure.

     - returns: A Let expression.
     */
    public init(_ fn: (Expr) -> Expr) {
        let v1 = Var()
        self.init(vars: v1.name, in: fn(v1))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter lambda: lambda expression represented by a swift closure.

     - returns: A Let expression.
     */
    public init(_ fn: ((Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        self.init(vars: v1.name, v2.name, in: fn((v1, v2)))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter lambda: lambda expression represented by a swift closure.

     - returns: A Let expression.
     */
    public init(_ fn: ((Expr, Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        self.init(vars: v1.name, v2.name, v3.name, in: fn((v1, v2, v3)))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter lambda: lambda expression represented by a swift closure.

     - returns: A Let expression.
     */
    public init(_ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        let v4 = Var()
        self.init(vars: v1.name, v2.name, v3.name, v4.name, in: fn((v1, v2, v3, v4)))
    }

    /**
     `Lambda` creates an anonymous function that binds one or more variables in the expression at `expr`. The lambda form is only permitted as a direct argument to a form which applies it. It cannot be bound to a variable.

     [Reference](https://faunadb.com/documentation/queries#basic_forms)

     - parameter lambda: lambda expression represented by a swift closure.

     - returns: A Let expression.
     */
    public init(_ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        let v4 = Var()
        let v5 = Var()
        self.init(vars: v1.name, v2.name, v3.name, v4.name, v5.name, in: fn((v1, v2, v3, v4, v5)))
    }

}
