import Foundation

/**
    `Expr` is the top level of the query language expression tree.

    For convenience, some native types are considered valid expressions:
    `String`, `Int`, `Double`, `Bool`, `Optional`, and `Date`.

    [Reference](https://fauna.com/documentation/queries#values)

    ## Motivation

    The FaunaDB query language is a non-typed expression based language.
    You can think about it as an actual programming language.

    In order to express an non-typed language in a typed language like Swift,
    we need to remove the types from the provided DSL so that we don't restrict
    function composition with type constraints.

    In practice, query language functions will always receive and return pure `Expr`
    types. That means you can compose your queries by combining functions together.

    For example:

        // Just return a reference to an user
        client.query(
            Ref("classes/users/42")
        )

        // Combine Ref and Get to return the user entry
        client.query(
            Get(
                Ref("classes/users/42")
            )
        )

        // Combine Ref, Get, and Select to return the user name
        client.query(
            Select(
                path: "data", "name"
                from: Get(
                    Ref("classes/users/42")
                )
            )
        )
*/
public protocol Expr {}

precedencegroup ExprTuplePrecedence {
    assignment: true
    associativity: left
    lowerThan: CastingPrecedence
}

infix operator => : ExprTuplePrecedence

/// Expression tuple constructor. See `FaunaDB.Obj` for more information.
public func => (key: String, value: Expr?) -> (String, Expr?) {
    return (key, value)
}

protocol Fn: Expr, AsJson, CustomStringConvertible {
    typealias Call = [String: Expr]
    var call: Call { get }
}

internal extension Fn {
    func escape() -> JsonType {
        return .object(call.mapValuesT(JSON.escape))
    }
}

extension Fn {
    public var description: String {
        return call.description
    }
}

internal func fn(_ pairs: (String, Expr?)...) -> Fn.Call {
    return Dictionary(pairs:
        pairs.flatMap { (key, value) in
            guard let value = value else { return nil }
            return (key, value)
        }
    )
}

internal func varargs(_ args: [Expr]) -> Expr {
    if args.count == 1 {
        return args.first!
    }

    return Arr(wrap: args)
}

/**
    Represents a hash map in FaunaDB where the key is always a `String`
    and the value can be a primitive value or an expression to be evaluated.

    You can use the operator `=>` as a syntax sugar while building new objects.

    [Reference](https://fauna.com/documentation/queries#values)

    For example:

        // Using a primitive value
        Obj("name" => "John")

        // Using a call to `Time` function
        Obj("created_at" => Time("now"))
*/
public struct Obj: Expr, AsJson, CustomStringConvertible {

    private let wrapped: [String: Expr?]

    public var description: String {
        return wrapped.description
    }

    /// Converts a native dictionary to an `Obj` instance.
    public init(wrap: [String: Expr?]) {
        self.wrapped = wrap
    }

    /// Initializes a new `Obj` instance with the key value tuples provided.
    /// You can use the operator `=>` as a syntax sugar while building new objects.
    public init(_ pairs: (String, Expr?)...) {
        self.wrapped = Dictionary(pairs: pairs)
    }

    func escape() -> JsonType {
        return .object([
            "object": .object(wrapped.mapValuesT(JSON.escape))
        ])
    }

}

/**
    Represents an array in FaunaDB where its elements can be a primitive value
    or an expression to be evaluated.

    [Reference](https://fauna.com/documentation/queries#values)

    For example:

        // Using a primitive value
        Arr(1, "Two", 3)

        // Using a call to the `Time` function
        Arr(Time("now"))
*/
public struct Arr: Expr, AsJson, CustomStringConvertible {

    private let wrapped: [Expr?]

    public var description: String {
        return wrapped.description
    }

    /// Initializes a new `Arr` instance with the elements provided.
    public init(_ elements: Expr?...) {
        self.wrapped = elements
    }

    /// Converts a primitive array to an `Arr` instance.
    public init(wrap: [Expr?]) {
        self.wrapped = wrap
    }

    func escape() -> JsonType {
        return .array(wrapped.map(JSON.escape))
    }

}

extension String: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self)
    }
}

extension Int: Expr, AsJson {
    func escape() -> JsonType {
        return .number(self)
    }
}

extension Double: Expr, AsJson {
    func escape() -> JsonType {
        return .double(self)
    }
}

extension Bool: Expr, AsJson {
    func escape() -> JsonType {
        return .boolean(self)
    }
}

extension Optional: Expr, AsJson {
    func escape() -> JsonType {
        switch self {
        case .some(let value): return JSON.escape(value: value)
        case .none           : return .null
        }
    }
}

extension Date: Expr, AsJson {
    func escape() -> JsonType {
        return TimeV(date: self).escape()
    }
}

extension HighPrecisionTime: Expr, AsJson {
    func escape() -> JsonType {
        return TimeV(self).escape()
    }
}
