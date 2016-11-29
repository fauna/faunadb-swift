import Foundation

public struct NextId: Fn {

    var call: Fn.Call = fn("next_id" => NullV())

    /**
     `NextId` produces a new identifier suitable for use when constructing refs.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - returns: A NextId expression.
     */
    public init() {}
}

public struct Database: Fn {

    var call: Fn.Call

    public init(_ name: String) {
        self.call = fn("database" => name)
    }

}

public struct Index: Fn {

    var call: Fn.Call

    public init(_ name: String) {
        self.call = fn("index" => name)
    }

}

public struct Class: Fn {

    var call: Fn.Call

    public init(_ name: String) {
        self.call = fn("class" => name)
    }

}

public struct Equals: Fn {

    var call: Fn.Call

    /**
     `Equals` tests equivalence between a list of values.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: values to test equivalence.

     - returns: A equals expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("equals" => varargs(terms))
    }

}

public struct Contains: Fn {

    var call: Fn.Call

    /**
     `Contains` returns true if the argument passed to `inExpr` contains a value at the specified `path`, and false otherwise.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter path:   Determines a location within `inExpr` data.
     - parameter inExpr: value or expression that prodices a value.

     - returns: A contains expression.
     */
    public init(path: Expr..., in: Expr) {
        self.call = fn("contains" => varargs(path), "in" => `in`)
    }
}

public struct Select: Fn {

    var call: Fn.Call

    /**
     `Select` traverses into the argument passed to from and returns the resulting value. If the path does not exist, it results in an error.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter path:         determines a location within `inExpr` data.
     - parameter from:         value or expression that evaluates into a Value to get the data located in path.
     - parameter defaultValue: -

     - returns: A Select expression.
     */
    public init(path: Expr..., from: Expr, default: Expr? = nil) {
        self.call = fn("select" => varargs(path), "from" => from, "default" => `default`)
    }
}

public struct Add: Fn {

    var call: Fn.Call

    /**
     `Add` computes the sum of a list of numbers. Attempting to add fewer that two numbers will result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("add" => varargs(terms))
    }
}

public struct Multiply: Fn {

    var call: Fn.Call

    /**
     `Multiply` computes the product of a list of numbers. Attempting to multiply fewer than two numbers will result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("multiply" => varargs(terms))
    }
}

public struct Subtract: Fn {

    var call: Fn.Call

    /**
     `Subtract` computes the difference of a list of numbers. Attempting to subtract fewer than two numbers will result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("subtract" => varargs(terms))
    }
}

public struct Divide: Fn {

    var call: Fn.Call

    /**
     `Divide` computes the quotient of a list of numbers.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("divide" => varargs(terms))
    }
}

public struct Modulo: Fn {

    var call: Fn.Call

    /**
     `Modulo` computes the remainder after division of a list of numbers.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("modulo" => varargs(terms))
    }
}

public struct LT: Fn {

    var call: Fn.Call

    /**
     `LT` returns true if each specified value compares as less than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("lt" => varargs(terms))
    }
}

public struct LTE: Fn {

    var call: Fn.Call

    /**
     `LTE` returns true if each specified value compares as less than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns  true if it has a single argument.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("lte" => varargs(terms))
    }
}

public struct GT: Fn {

    var call: Fn.Call

    /**
     `GT` returns true if each specified value compares as greater than the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("gt" => varargs(terms))
    }
}

public struct GTE: Fn {

    var call: Fn.Call

    /**
     `GTE` returns true if each specified value compares as greater than or equal to the ones following it, and false otherwise. The function takes one or more arguments; it always returns true if it has a single argument.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: number or expression that evalues to a number.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("gte" => varargs(terms))
    }
}

public struct And: Fn {

    var call: Fn.Call

    /**
     `And` computes the conjunction of a list of boolean values, returning `true` if all elements are true, and `false` otherwise.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: boolean or expression that evalues to a boolean.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("and" => varargs(terms))
    }
}

public struct Or: Fn {

    var call: Fn.Call

    /**
     `Or` computes the disjunction of a list of boolean values, returning `true` if any elements are true, and `false` otherwise.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: boolean or expression that evalues to a boolean.

     - returns: A Add expression.
     */
    public init(_ terms: Expr...) {
        self.call = fn("or" => varargs(terms))
    }
}

public struct Not: Fn {

    var call: Fn.Call

    /**
     `Not` computes the negation of a boolean expression. Computes the negation of a boolean value, returning true if its argument is false, or false if its argument is true.

     - parameter boolExpr: indicates the expression to negate.

     [Reference](https://faunadb.com/documentation/queries#misc_functions)

     - parameter terms: boolean or expression that evalues to a boolean.

     - returns: A Add expression.
     */
    public init(_ expr: Expr) {
        self.call = fn("not" => expr)
    }
}
