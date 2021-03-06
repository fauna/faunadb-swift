// swiftlint:disable file_length large_tuple
import Foundation

// MARK: Values

/// Ref creates a new RefV value with the ID provided.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#special-type).
public struct Ref: Fn {

    var call: Fn.Call

    /// - Parameter id: Id for resource reference.
    public init(_ id: String) {
        self.call = fn("@ref" => id)
    }

    /// - Parameters:
    ///     - class: The class reference for the resource
    ///     - id:    The id for the resource reference
    public init(class: Expr, id: Expr) {
        self.call = fn("ref" => `class`, "id" => id)
    }

}

// MARK: Basic Forms

/// Aborts the current query execution.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Abort: Fn {

    var call: Fn.Call

    /// - Parameter message: the abort message.
    public init(_ message: Expr) {
        self.call = fn("abort" => message)
    }
}

/// Returns a native reference to classes. This allows for example,
/// paginate over all classes in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Classes: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("classes" => (scope ?? NullV()))
    }
}

/// Returns a native reference to indexes. This allows for example,
/// paginate over all indexes in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Indexes: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("indexes" => (scope ?? NullV()))
    }
}

/// Returns a native reference to databases. This allows for example,
/// paginate over all databases in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Databases: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("databases" => (scope ?? NullV()))
    }
}

/// Returns a native reference to functions. This allows for example,
/// paginate over all functions in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Functions: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("functions" => (scope ?? NullV()))
    }
}

/// Returns a native reference to roles. This allows for example,
/// paginate over all roles in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Roles: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("roles" => (scope ?? NullV()))
    }
}

/// Returns a native reference to keys. This allows for example,
/// paginate over all keys in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Keys: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("keys" => (scope ?? NullV()))
    }
}

/// Returns a native reference to tokens. This allows for example,
/// paginate over all tokens in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Tokens: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("tokens" => (scope ?? NullV()))
    }
}

/// Returns a native reference to credentials. This allows for example,
/// paginate over all credentials in a database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Credentials: Fn {

    var call: Fn.Call

    /// - Parameter scope: the scope database.
    public init(scope: Expr? = nil) {
        self.call = fn("credentials" => (scope ?? NullV()))
    }
}

/// A `Var` expression refers to the value of a variable `varname` in the current
/// lexical scope. Referring to a variable that is not in scope results in an
/// “unbound variable” error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Var: Fn {

    fileprivate let name: String

    var call: Fn.Call

    /// - Parameter name: variable name.
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

/// `At` evaluates the expr at a given timestamp.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct At: Fn {

    var call: Fn.Call

    /// - Parameter timestamp: A timestamp in which the expr will be evaluated.
    /// - Parameter expr:      The expression to be evaluated.
    public init(timestamp: Expr, _ expr: Expr) {
        self.call = fn(
            "at" => timestamp,
            "expr" => expr
        )
    }
}

/// `Let` binds values to one or more variables. Variable values cannot refer to
/// other variables defined in the same let expression. Variables are lexically
/// scoped to the expression passed via `in`.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Let: Fn {

    private struct Bindings: Fn {
        var call: Fn.Call
    }

    var call: Fn.Call

    /// - Parameter bindings: Each array item is a tuple containing the variable name and its corresponding value.
    /// - Parameter expr:     Lambda expression where binding variables are available to use.
    public init(bindings: [(String, Expr?)], in: Expr) {
        self.call = fn(
            "let" => Let.Bindings(call: Dictionary(pairs: bindings).mapValuesT { $0 ?? NullV() }),
            "in" => `in`
        )
    }

    /// - Parameter bindings: Each tuple contains the variable name and its corresponding value.
    /// - Parameter expr:     Lambda expression where binding variables are available to use.
    public init(bindings: (String, Expr?)..., in: () -> Expr) {
        self.init(bindings: bindings, in: `in`())
    }

    /// - Parameter e1:  1st value.
    /// - Parameter in: Lambda expression as a Swift closure.
    public init(_ e1: Expr, in: (Expr) -> Expr) {
        let v1 = Var()
        self.init(bindings: [v1.name => e1], in: `in`(v1))
    }

    /// - Parameter e1: 1st value.
    /// - Parameter e2: 2nd value.
    /// - Parameter in: Lambda expression as a swift closure.
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

    /// - Parameter e1: 1st value.
    /// - Parameter e2: 2nd value.
    /// - Parameter e3: 3rd value.
    /// - Parameter in: Lambda expression as a swift closure.
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

    /// - Parameter e1: 1st value.
    /// - Parameter e2: 2nd value.
    /// - Parameter e3: 3rd value.
    /// - Parameter e4: 4th value.
    /// - Parameter in: Lambda expression as a swift closure.
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

    /// - Parameter e1: 1st value.
    /// - Parameter e2: 2nd value.
    /// - Parameter e3: 3rd value.
    /// - Parameter e4: 4th value.
    /// - Parameter e5: 5th value.
    /// - Parameter in: Lambda expression as a swift closure.
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

/// If evaluates and returns then expr or else expr depending on the value of
/// pred. If pred evaluates to anything other than a boolean, if returns an
/// “invalid argument” error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct If: Fn {

    var call: Fn.Call

    /// - Parameter pred: Predicate expression. Must evaluate to a boolean value.
    /// - Parameter then: Expression to execute if pred evaluation is true.
    /// - Parameter else: Expression to execute if pred evaluation is false.
    public init(_ pred: Expr, then: Expr, else: Expr) {
        self.call = fn("if" => pred, "then" => `then`, "else" => `else`)
    }
}

/// Do sequentially evaluates its arguments, and returns the evaluation of the
/// last expression. If no expressions are provided, do returns an error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Do: Fn {

    var call: Fn.Call

    /// - Parameter exprs: Expressions to evaluate.
    public init(_ exprs: Expr...) {
        self.call = fn("do" => varargs(exprs))
    }

}

/// `Lambda` creates an anonymous function that binds one or more variables in the
/// expression at `expr`. The lambda form is only permitted as a direct argument
/// to a form which applies it. It cannot be bound to a variable.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Lambda: Fn {

    var call: Fn.Call

    /// - Parameter vars: Variables.
    /// - Parameter expr: Expression in which the variables are bound.
    public init(vars: Expr..., in expr: Expr) {
        self.call = fn("lambda" => varargs(vars), "expr" => expr)
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: (Expr) -> Expr) {
        let v1 = Var()
        self.init(vars: v1.name, in: lambda(v1))
    }

    /// - Parameter lambda: Lambda expression represented by a swift closure.
    public init(_ lambda: ((Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        self.init(vars: v1.name, v2.name, in: lambda((v1, v2)))
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: ((Expr, Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        self.init(vars: v1.name, v2.name, v3.name, in: lambda((v1, v2, v3)))
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: ((Expr, Expr, Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        let v4 = Var()
        self.init(vars: v1.name, v2.name, v3.name, v4.name, in: lambda((v1, v2, v3, v4)))
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        let v1 = Var()
        let v2 = Var()
        let v3 = Var()
        let v4 = Var()
        let v5 = Var()
        self.init(vars: v1.name, v2.name, v3.name, v4.name, v5.name, in: lambda((v1, v2, v3, v4, v5)))
    }

}

/// `Call` invoke the specified function reference.
/// The function must be created using `CreateFunction` before it can be invoked.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Call: Fn {

    var call: Fn.Call

    /// - Parameter ref:       Reference to a function.
    /// - Parameter arguments: Variable list of arguments to be passed in to the function.
    public init(_ ref: Expr, arguments args: Expr...) {
        self.call = fn("call" => ref, "arguments" => varargs(args))
    }
}

/// `Query` constructs an instance of `@query` type with the specified lambda.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#basic-forms).
public struct Query: Fn {

    var call: Fn.Call

    /// - Parameter lambda: Lambda expression.
    public init(_ lambda: Expr) {
        self.call = fn("query" => lambda)
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: (Expr) -> Expr) {
        self.init(Lambda(lambda))
    }

    /// - Parameter lambda: Lambda expression represented by a swift closure.
    public init(_ lambda: ((Expr, Expr)) -> Expr) {
        self.init(Lambda(lambda))
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: ((Expr, Expr, Expr)) -> Expr) {
        self.init(Lambda(lambda))
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(Lambda(lambda))
    }

    /// - Parameter lambda: Lambda expression represented by a Swift closure.
    public init(_ lambda: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(Lambda(lambda))
    }
}

// MARK: Collections

/// `Map` applies `lambda` expression to each member of the Array or Page
/// collection, and returns the results of each application in a new collection of
/// the same type. If a Page is passed, its cursor is preserved in the result.
///
/// `Map` applies the `lambda` expression concurrently to each element of the
///  collection. Side-effects, such as writes, do not affect evaluation of other
///  lambda applications. The order of possible refs being generated within the
///  lambda are non-deterministic.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Map: Fn {

    var call: Fn.Call

    /// - Parameter collection: Collection to perform map.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(collection: Expr, to lambda: Expr) {
        self.call = fn("map" => lambda, "collection" => collection)
    }

    /// - Parameter collection: Collection to perform map.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: (Expr) -> Expr) {
        self.init(collection: collection, to: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform map expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform map expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform map expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform map expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(lambda))
    }
}

/// `Foreach` applies `lambda` expr to each member of the Array or Page coll. The
/// original collection is returned.
///
/// `Foreach` applies the `lambda` expr concurrently to each element of the
///  collection. Side-effects, such as writes, do not affect evaluation of other
///  lambda applications. The order of possible refs being generated within the
///  lambda are non-deterministic.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Foreach: Fn {

    var call: Fn.Call

    /// - Parameter collection: Collection to perform foreach expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(collection: Expr, in lambda: Expr) {
        self.call = fn("foreach" => lambda, "collection" => collection)
    }

    /// - Parameter collection: Collection to perform foreach expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: (Expr) -> Expr) {
        self.init(collection: collection, in: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform foreach expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform foreach expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform foreach expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform foreach expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(lambda))
    }
}

/// `Filter` applies `lambda` expr to each member of the Array or Page collection,
/// and returns a new collection of the same type containing only those elements
/// for which `lambda` expr returned true. If a Page is passed, its cursor is
/// preserved in the result.
///
/// Providing a lambda which does not return a Boolean results in an “invalid
/// argument” error.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Filter: Fn {

    var call: Fn.Call

    /// - Parameter collection: Collection to perform filter expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item. Must return a boolean value.
    public init(collection: Expr, with lambda: Expr) {
        self.call = fn("filter" => lambda, "collection" => collection)
    }

    /// - Parameter collection: Collection to perform filter expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item. Must return a boolean value.
    public init(_ collection: Expr, _ lambda: (Expr) -> Expr) {
        self.init(collection: collection, with: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform filter expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item. Must return a boolean value.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform filter expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item. Must return a boolean value.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform filter expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item. Must return a boolean value.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(lambda))
    }

    /// - Parameter collection: Collection to perform filter expression.
    /// - Parameter lambda:     Lambda expression to apply to each collection item. Must return a boolean value.
    public init(_ collection: Expr, _ lambda: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(lambda))
    }

}

/// `Take` returns a new Collection or Page that contains num elements from the
/// head of the Collection or Page coll.  If `take` value is zero or negative, the
/// resulting collection is empty.  When applied to a page, the returned page’s
/// after cursor is adjusted to only cover the taken elements.
///
/// As special cases:
/// * If `take` value is negative, after will be set to the same value as the
/// original page’s  before.
/// * If all elements from the original page were taken, after does not change.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Take: Fn {

    var call: Fn.Call

    /// - Parameter count:      Number of items to be taken.
    /// - Parameter collection: Collection or page.
    public init(count: Expr, from collection: Expr) {
        self.call = fn("take" => count, "collection" => collection)
    }
}

/// `Drop` returns a new Arr or Page that contains the remaining elements, after
/// num have been removed from the head of the Arr or Page coll. If `drop` value is
/// zero or negative, elements of coll are returned unmodified.
///
/// When applied to a page, the returned page’s before cursor is adjusted to
/// exclude the dropped elements. As special cases:
/// * If `drop` value is negative, before does not change.
/// * Otherwise if all elements from the original page were dropped (including
/// the case where the page was already empty), before will be set to same value as
/// the original page’s after.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Drop: Fn {

    var call: Fn.Call

    /// - Parameter count:      Number of items to be dropped.
    /// - Parameter collection: Collection or page.
    public init(count: Expr, from collection: Expr) {
        self.call = fn("drop" => count, "collection" => collection)
    }

}

/// `Prepend` returns a new Array that is the result of prepending `elements` onto
/// the Array `toCollection`.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Prepend: Fn {

    var call: Fn.Call

    /// - Parameter elements:   Elements to prepend.
    /// - Parameter collection: Collection to be prepended.
    public init(elements: Expr, to collection: Expr) {
        self.call = fn("prepend" => elements, "collection" => collection)
    }
}

/// `Append` returns a new Array that is the result of appending `elements` onto
/// the `collection` array.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#collections).
public struct Append: Fn {

    var call: Fn.Call

    /// - Parameter elements:   Elements to append.
    /// - Parameter collection: Collection to be appended.
    public init(elements: Expr, to collection: Expr) {
        self.call = fn("append" => elements, "collection" => collection)
    }

}

// MARK: Read Functions

/// Retrieves the instance identified by ref. If the instance does not exist, an
/// “instance not found” error will be returned. Use the exists predicate to avoid
/// “instance not found” errors.
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#read-functions-get_ref).
public struct Get: Fn {

    var call: Fn.Call

    /// - Parameter ref: Reference to the intance to retrive.
    /// - Parameter ts:  If `ts` is passed `Get` retrieves the instance
    ///   specified by ref parameter at specific time determined by `ts` parameter.
    public init(_ ref: Expr, ts: Expr? = nil) {
        self.call = fn("get" => ref, "ts" => ts)
    }

}

/// `KeyFromSecret` retrieves a key object associated to the given secret.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#read-functions).
public struct KeyFromSecret: Fn {

    var call: Fn.Call

    /// - Parameter secret: The secret of the key to be retrieved.
    public init(_ secret: Expr) {
        self.call = fn("key_from_secret" => secret)
    }
}

/// `Paginate` retrieves a page from the set identified by `resource`. A valid set
/// is any set identifier or instance ref. Instance refs represent singleton sets
/// of themselves.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#read-functions).
public struct Paginate: Fn {

    var call: Fn.Call

    /// - Parameter resource: Resource that contains the set to be paginated.
    /// - Parameter before:   Return the previous page of results before this cursor (exclusive).
    /// - Parameter after:    Return the next page of results after this cursor (inclusive).
    /// - Parameter ts:       If passed, it returns the set at the specified point in time.
    /// - Parameter size:     Maximum number of results to return. Default `16`.
    /// - Parameter events:   If true, return a page from the event history of the set. Default `false`.
    /// - Parameter sources:  If true, include the source sets along with each element. Default `false`.
    public init(
        _ resource: Expr,
        before: Expr? = nil,
        after: Expr? = nil,
        ts: Expr? = nil,
        size: Expr? = nil,
        events: Expr? = nil,
        sources: Expr? = nil
    ) {
        self.call = fn(
            "paginate" => resource,
            "before" => before,
            "after" => after,
            "ts" => ts,
            "size" => size,
            "events" => events,
            "sources" => sources
        )
    }

}

/// `Exists` returns boolean true if the provided ref exists (in the case of an
///  instance), or is non-empty (in the case of a set), and false otherwise.
///
///  [Reference](https://app.fauna.com/documentation/reference/queryapi#read-functions).
public struct Exists: Fn {

    var call: Fn.Call

    /// - Parameter ref: Ref value to check if exists.
    /// - Parameter ts:  Existence of the ref is checked at given time.
    public init(_ ref: Expr, ts: Expr? = nil) {
        self.call = fn("exists" => ref, "ts" => ts)
    }

}

// MARK: Write Functions

/// Creates an instance of the class referred to by `classRef`, using `params`.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct Create: Fn {

    var call: Fn.Call

    /// - Parameter classRef: Indicates the class where the instance should be created.
    /// - Parameter params:   Data to create the instance.
    public init(at classRef: Expr, _ params: Expr) {
        self.call = fn("create" => classRef, "params" => params)
    }

}

/// Updates a resource ref. Updates are partial, and only modify values that are
/// specified. Scalar values and arrays are replaced by newer versions, objects are
/// merged, and null removes a value.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct Update: Fn {

    var call: Fn.Call

    /// - Parameter ref:    Indicates the instance to be updated.
    /// - Parameter params: Data to update the instance.
    public init(ref: Expr, to params: Expr) {
        self.call = fn("update" => ref, "params" => params)
    }
}

/// Replaces the resource ref using the provided params. Values not specified are
/// removed.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct Replace: Fn {

    var call: Fn.Call

    /// - Parameter ref:    Indicates the instance to be updated.
    /// - Parameter params: New instance data.
    public init(ref: Expr, with params: Expr) {
        self.call = fn("replace" => ref, "params" => params)
    }

}

/// Removes a resource.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct Delete: Fn {

    var call: Fn.Call

    /// - Parameter ref: Indicates the resource to remove.
    public init(ref: Expr) {
        self.call = fn("delete" => ref)
    }

}

/// Enumeration for event action types.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions)
public enum Action: String {
    case create
    case delete
}

extension Action: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self.rawValue)
    }
}

/// Adds an event to an instance’s history. The ref must refer to an instance of a
/// user-defined class or a key - all other refs result in an “invalid argument”
/// error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct Insert: Fn {

    var call: Fn.Call

    /// - Parameter ref:    Indicates the resource.
    /// - Parameter ts:     Event timestamp.
    /// - Parameter action: .create or .delete.
    /// - Parameter params: Resource data.
    public init(ref: Expr, ts: Expr, action: Expr, params: Expr) {
        self.call = fn("insert" => ref, "ts" => ts, "action" => action, "params" => params)
    }

    /// - Parameter ref:    Indicates the resource.
    /// - Parameter ts:     Event timestamp.
    /// - Parameter action: "create" or "delete".
    /// - Parameter params: Resource data.
    public init(in ref: Expr, ts: Expr, action: Action, params: Expr) {
        self.init(ref: ref, ts: ts, action: action, params: params)
    }

}

/// Deletes an event from an instance’s history. The ref must refer to an instance
/// of an user-defined class - all other refs result in an “invalid argument” error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct Remove: Fn {

    var call: Fn.Call

    /// - Parameter ref:    Indicates the instance resource.
    /// - Parameter ts:     Event timestamp.
    /// - Parameter action: .create or .delete.
    public init(ref: Expr, ts: Expr, action: Expr) {
        self.call = fn("remove" => ref, "ts" => ts, "action" => action)
    }

    /// - Parameter ref:    Indicates the instance resource.
    /// - Parameter ts:     Event timestamp.
    /// - Parameter action: "create" or "delete".
    public init(from ref: Expr, ts: Expr, action: Action) {
        self.init(ref: ref, ts: ts, action: action)
    }

}

/// `CreateClass` creates a class object using `params`. It is a shortcut function
/// that has the same effect as `Create(Ref("classes"), params)`.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct CreateClass: Fn {

    var call: Fn.Call

    /// - Parameter params: Class configuration.
    public init(_ params: Expr) {
        self.call = fn("create_class" => params)
    }

}

/// `CreateDatabase` creates a new database using data from `params`. Since this
/// function creates a database, it requires an admin key to be passed
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct CreateDatabase: Fn {

    var call: Fn.Call

    /// - Parameter params: Database configuration.
    public init(_ params: Expr) {
        self.call = fn("create_database" => params)
    }

}

/// This function creates a new index where the name and source class are specified
/// in `params`.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct CreateIndex: Fn {

    var call: Fn.Call

    /// - Parameter params: Index configuration.
    public init(_ params: Expr) {
        self.call = fn("create_index" => params)
    }

}

/// This function creates a new key where the database and role are specified in
/// `params`. It needs the admin key for authentication.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct CreateKey: Fn {

    var call: Fn.Call

    /// - Parameter params: Key configuration.
    public init(_ params: Expr) {
        self.call = fn("create_key" => params)
    }

}

/// This function creates a new stored function where the name and body lambda
/// are specified in `params`.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct CreateFunction: Fn {

    var call: Fn.Call

    /// - Parameter params: Function configuration.
    public init(_ params: Expr) {
        self.call = fn("create_function" => params)
    }
}

/// This function creates a new role with the provided configuration.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#write-functions).
public struct CreateRole: Fn {

    var call: Fn.Call

    /// - Parameter params: Function configuration.
    public init(_ params: Expr) {
        self.call = fn("create_role" => params)
    }
}

// MARK: Set Functions

/// `Singleton` returns the history of the instance's presence of the provided ref.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Singleton: Fn {

    var call: Fn.Call

    /// - Parameter ref: a reference to get presence history.
    public init(_ ref: Expr) {
        self.call = fn("singleton" => ref)
    }
}

/// `Events` returns the history of instance's data of the provided ref.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Events: Fn {

    var call: Fn.Call

    /// - Parameter refSet: a ref or a set to get data history.
    public init(_ refSet: Expr) {
        self.call = fn("events" => refSet)
    }
}

/// `Match` returns the set of instances that match the terms, based on the
/// configuration of the specified index. `terms` can be either a single value, or an
/// array.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Match: Fn {

    var call: Fn.Call

    /// - Parameter index: Index to use to perform the match.
    /// - Parameter terms: Terms can be either a single value, or multiple values.
    public init(index: Expr, terms: Expr...) {
        self.call = fn(
            "match" => index,
            "terms" => (terms.count > 0 ? varargs(terms) : nil)
        )
    }
}

/// `Union` represents the set of resources that are present in at least one of the
/// specified sets.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Union: Fn {

    var call: Fn.Call

    /// - Parameter sets: Sets of resources to perform the union.
    public init(_ sets: Expr...) {
        self.call = fn("union" => varargs(sets))
    }

}

/// `Intersection` represents the set of resources that are present in all of the
/// specified sets.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Intersection: Fn {

    var call: Fn.Call

    /// - Parameter sets: Sets of resources to perform the intersection.
    public init(_ sets: Expr...) {
        self.call = fn("intersection" => varargs(sets))
    }

}

/// `Difference` represents the set of resources present in the source set and not
/// in any of the other specified sets.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Difference: Fn {

    var call: Fn.Call

    /// - Parameter sets: Sets of resources to perform the difference.
    public init(_ sets: Expr...) {
        self.call = fn("difference" => varargs(sets))
    }

}

/// Distinct function returns the set after removing duplicates.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Distinct: Fn {

    var call: Fn.Call

    /// - Parameter set: Determines the set where distinct function should be performed.
    public init(_ set: Expr) {
        self.call = fn("distinct" => set)
    }

}

/// `Join` derives a set of resources from target by applying each instance in
/// `sourceSet` to `with` target. Target can be either an index reference or a
/// lambda function.  The index form is useful when the instances in the
/// `sourceSet` match the terms in an index. The join returns instances from index
/// (specified by with) that match the terms from `sourceSet`.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#sets).
public struct Join: Fn {

    var call: Fn.Call

    /// - Parameter sourceSet: Set to perform the join.
    /// - Parameter target:    Can be either an index reference or a lambda function.
    public init(_ sourceSet: Expr, with target: Expr) {
        self.call = fn("join" => sourceSet, "with" => target)
    }

    /// - Parameter sourceSet: Set to perform the join.
    /// - Parameter lambda:    Lambda function to be used for join.
    public init(_ sourceSet: Expr, lambda: (Expr) -> Expr) {
        self.init(sourceSet, with: Lambda(lambda))
    }

    /// - Parameter sourceSet: Set to perform the join.
    /// - Parameter lambda:    Lambda function to be used for join.
    public init(_ sourceSet: Expr, lambda: ((Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(lambda))
    }

    /// - Parameter sourceSet: Set to perform the join.
    /// - Parameter lambda:    Lambda function to be used for join.
    public init(_ sourceSet: Expr, lambda: ((Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(lambda))
    }

    /// - Parameter sourceSet: Set to perform the join.
    /// - Parameter lambda:    Lambda function to be used for join.
    public init(_ sourceSet: Expr, lambda: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(lambda))
    }

    /// - Parameter sourceSet: Set to perform the join.
    /// - Parameter lambda:    Lambda function to be used for join.
    public init(_ sourceSet: Expr, lambda: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(lambda))
    }

}

// MARK: Auth Functions

/// `Login` creates a token for the provided ref.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#authentication).
public struct Login: Fn {

    var call: Fn.Call

    /// - Parameter ref:    A Ref instance for the resource to authenticate.
    /// - Parameter params: Password object.
    public init(for ref: Expr, _ params: Expr) {
        self.call = fn("login" => ref, "params" => params)
    }

}

/// `Logout` deletes all tokens associated with the current session if its
/// parameter is `true`, or just the token used in this request otherwise.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#authentication)..
public struct Logout: Fn {

    var call: Fn.Call

    /// - Parameter all: if true deletes all tokens associated with the current
    /// session. If false it deletes just the token used in this request.
    public init(all: Expr) {
        self.call = fn("logout" => all)
    }

}

/// `Identify` checks the given password against the ref’s credentials, returning
/// `true` if the credentials are valid, or `false` otherwise..
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#authentication)..
public struct Identify: Fn {

    var call: Fn.Call

    /// - Parameter ref:      The resource ref to identify.
    /// - Parameter password: Password for the resource.
    public init(ref: Expr, password: Expr) {
        self.call = fn("identify" => ref, "password" => password)
    }

}

/// `Identity` returns the instance reference associated with the current key token.
///
/// For example, the current key token created using:
///   `Create(at: Tokens(), Obj("instance" => someRef))`
/// or via:
///   `Login(for: someRef, Obj("password" => "sekrit"))`
/// will return `someRef` as the result of this function.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#authentication).
public struct Identity: Fn {

    var call: Fn.Call = fn("identity" => NullV())

    public init() {}
}

/// `HasIdentity` checks if the current key token has an identity associated to it.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#authentication).
public struct HasIdentity: Fn {

    var call: Fn.Call = fn("has_identity" => NullV())

    public init() {}
}

// MARK: String Functions

/// `Concat` joins a list of strings into a single string value.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#string-functions).
public struct Concat: Fn {

    var call: Fn.Call

    /// - Parameter strings:   Strings to be concatenated.
    /// - Parameter separator: A string separating each element in the result.
    public init(_ strings: Expr..., separator: Expr? = nil) {
        self.call = fn("concat" => varargs(strings), "separator" => separator)
    }
}

/// Represents the normalization operation to be used for `Casefold` function.
public enum Normalizer: String {
    case NFD
    case NFC
    case NFKD
    case NFKC
    case NFKCCaseFold
}

extension Normalizer: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self.rawValue)
    }
}

/// `Casefold` normalizes strings according to the Unicode Standard section 5.18
/// "Case Mappings".
///
/// To compare two strings for case-insensitive matching, transform each string
/// and use a binary comparison, such as  equals.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#string-functions).
public struct Casefold: Fn {

    var call: Fn.Call

    /// - Parameter str: String to be normalized.
    /// - Parameter normalizer: The normalization operation.
    public init(_ str: Expr, _ normalizer: Expr? = nil) {
        self.call = fn("casefold" => str, "normalizer" => normalizer)
    }

    /// - Parameter str: String to be normalized.
    /// - Parameter normalizer: The normalization operation.
    public init(_ str: Expr, normalizer: Normalizer? = nil) {
        self.call = fn("casefold" => str, "normalizer" => normalizer)
    }

}

// MARK: Date and Time Functions

/// `Time` constructs a time special type from an ISO 8601 offset date/time string.
/// The special string "now" may be used to construct a time from the current
/// request’s transaction time. Multiple references to "now" within the same query
/// will be equal.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#time-and-date).
public struct Time: Fn {

    var call: Fn.Call

    /// - Parameter string: ISO8601 offset date/time string, "now" can be used
    ///   to create current request evaluation time.
    public init(fromString string: Expr) {
        self.call = fn("time" => string)
    }

}

/// Represents a time unit to be used for `Epoch` function
public enum TimeUnit: String {
    case second
    case millisecond
    case microsecond
    case nanosecond
}

extension TimeUnit: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self.rawValue)
    }
}

/// `Epoch` constructs a time special type relative to the epoch
/// (1970-01-01T00:00:00Z). `offset` must be an integer type. `unit` may be a
/// valid time unit.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#time-and-date).
public struct Epoch: Fn {

    var call: Fn.Call

    /// - Parameter offset: Number relative to the epoch.
    /// - Parameter unit:   Offset unit.
    public init(_ offset: Expr, _ unit: Expr) {
        self.call = fn("epoch" => offset, "unit" => unit)
    }

    /// - Parameter offset: Number relative to the epoch.
    /// - Parameter unit:   Offset unit.
    public init(_ offset: Expr, unit: TimeUnit) {
        self.init(offset, unit)
    }

}

/// `DateFn` constructs a date special type from an ISO 8601 date string.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#time-and-date).
public struct DateFn: Fn {

    var call: Fn.Call

    /// - Parameter string: Date string to be parsed.
    public init(string: String) {
        self.call = fn("date" => string)
    }

}

// MARK: Miscellaneous Functions

/// `NextId` produces a new identifier suitable for use when constructing refs.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
@available(*, deprecated, message: "use NewId() instead")
public struct NextId: Fn {
    var call: Fn.Call = fn("next_id" => NullV())
    public init() {}
}

/// `NewId` produces a new identifier suitable for use when constructing refs.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
public struct NewId: Fn {
    var call: Fn.Call = fn("new_id" => NullV())
    public init() {}
}

/// Given the name of a database, this function returns a valid ref that points to
/// it. The database function only looks up child databases so finding a database
/// using this function requires you to provide an admin key from the parent
/// database.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
public struct Database: Fn {

    var call: Fn.Call

    /// - Parameter name: The database name.
    /// - Parameter scope: The scope database.
    public init(_ name: String, scope: Expr? = nil) {
        self.call = fn("database" => name, "scope" => scope)
    }

}

/// The index function returns a valid ref for the given index name
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
public struct Index: Fn {

    var call: Fn.Call

    /// - Parameter name: The index name.
    /// - Parameter scope: The scope database.
    public init(_ name: String, scope: Expr? = nil) {
        self.call = fn("index" => name, "scope" => scope)
    }

}

/// The class function returns a valid ref for the given class name
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
public struct Class: Fn {

    var call: Fn.Call

    /// - Parameter name: The class name.
    /// - Parameter scope: The scope database.
    public init(_ name: String, scope: Expr? = nil) {
        self.call = fn("class" => name, "scope" => scope)
    }

}

/// The `Function` function returns a valid ref for the given function name
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
public struct Function: Fn {

    var call: Fn.Call

    /// - Parameter name: The function name.
    /// - Parameter scope: The scope database.
    public init(_ name: String, scope: Expr? = nil) {
        self.call = fn("function" => name, "scope" => scope)
    }

}

/// The `Role` function returns a valid ref for the given role name
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions)
public struct Role: Fn {

    var call: Fn.Call

    /// - Parameter name: The role name.
    /// - Parameter scope: The scope database.
    public init(_ name: String, scope: Expr? = nil) {
        self.call = fn("role" => name, "scope" => scope)
    }

}

/// `Equals` tests equivalence between a list of values.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Equals: Fn {

    var call: Fn.Call

    /// - Parameter terms: values to test equivalence.
    public init(_ terms: Expr...) {
        self.call = fn("equals" => varargs(terms))
    }

}

/// `Contains` returns true if the argument passed to `in` contains a value at
/// the specified `path`, and false otherwise.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Contains: Fn {

    var call: Fn.Call

    /// - Parameter path:   Determines a location within `in` data.
    /// - Parameter object: Value to check if `path` is present.
    public init(path: Expr..., in object: Expr) {
        self.call = fn("contains" => varargs(path), "in" => object)
    }
}

/// `Select` traverses into the argument passed to from and returns the resulting
/// value. If the path does not exist, it results in an error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Select: Fn {

    var call: Fn.Call

    /// - Parameter path:    Determines a location within `object`.
    /// - Parameter object:  Value in which `path` should be selected.
    /// - Parameter default: Return this value instead of an error if the path does not exist.
    public init(path: Expr..., from object: Expr, default: Expr? = nil) {
        self.call = fn("select" => varargs(path), "from" => object, "default" => `default`)
    }
}

/// `SelectAll` traverses into the argument passed to from flattening all values into an array.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct SelectAll: Fn {

    var call: Fn.Call

    /// - Parameter path:    Determines a location within `object`.
    /// - Parameter object:  Value in which `path` should be selected.
    public init(path: Expr..., from object: Expr) {
        self.call = fn("select_all" => varargs(path), "from" => object)
    }
}

/// `Add` computes the sum of a list of numbers. Attempting to add fewer that two
/// numbers will result in an “invalid argument” error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Add: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to be added.
    public init(_ terms: Expr...) {
        self.call = fn("add" => varargs(terms))
    }
}

/// `Multiply` computes the product of a list of numbers. Attempting to multiply
/// fewer than two numbers will result in an “invalid argument” error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Multiply: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to be multiplied.
    public init(_ terms: Expr...) {
        self.call = fn("multiply" => varargs(terms))
    }
}

/// `Subtract` computes the difference of a list of numbers. Attempting to subtract
/// fewer than two numbers will result in an “invalid argument” error.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Subtract: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to be subtracted.
    public init(_ terms: Expr...) {
        self.call = fn("subtract" => varargs(terms))
    }
}

/// `Divide` computes the quotient of a list of numbers.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Divide: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to divide.
    public init(_ terms: Expr...) {
        self.call = fn("divide" => varargs(terms))
    }
}

/// `Modulo` computes the remainder after division of a list of numbers.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Modulo: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to computes modulo on.
    public init(_ terms: Expr...) {
        self.call = fn("modulo" => varargs(terms))
    }
}

/// `LT` returns true if each specified value compares as less than the ones
/// following it, and false otherwise. The function takes one or more arguments; it
/// always returns true if it has a single argument.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct LT: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to compare.
    public init(_ terms: Expr...) {
        self.call = fn("lt" => varargs(terms))
    }
}

/// `LTE` returns true if each specified value compares as less than or equal to
/// the ones following it, and false otherwise. The function takes one or more
/// arguments; it always returns  true if it has a single argument.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct LTE: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to compare.
    public init(_ terms: Expr...) {
        self.call = fn("lte" => varargs(terms))
    }
}

/// `GT` returns true if each specified value compares as greater than the ones
/// following it, and false otherwise. The function takes one or more arguments; it
/// always returns true if it has a single argument.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct GT: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to compare.
    public init(_ terms: Expr...) {
        self.call = fn("gt" => varargs(terms))
    }
}

/// `GTE` returns true if each specified value compares as greater than or equal to
/// the ones following it, and false otherwise. The function takes one or more
/// arguments; it always returns true if it has a single argument.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct GTE: Fn {

    var call: Fn.Call

    /// - Parameter terms: Numbers to compare.
    public init(_ terms: Expr...) {
        self.call = fn("gte" => varargs(terms))
    }
}

/// `And` computes the conjunction of a list of boolean values, returning `true` if
/// all elements are true, and `false` otherwise.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct And: Fn {

    var call: Fn.Call

    /// - Parameter terms: Booleans to compare.
    public init(_ terms: Expr...) {
        self.call = fn("and" => varargs(terms))
    }
}

/// `Or` computes the disjunction of a list of boolean values, returning `true` if
/// any elements are true, and `false` otherwise.
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Or: Fn {

    var call: Fn.Call

    /// - Parameter terms: Booleans to compare.
    public init(_ terms: Expr...) {
        self.call = fn("or" => varargs(terms))
    }
}

/// `Not` computes the negation of a boolean expression. Computes the negation of a
/// boolean value, returning true if its argument is false, or false if its
/// argument is true..
///
/// [Reference](https://app.fauna.com/documentation/reference/queryapi#miscellaneous-functions).
public struct Not: Fn {

    var call: Fn.Call

    /// - Parameter expr: Boolean to negate.
    public init(_ expr: Expr) {
        self.call = fn("not" => expr)
    }
}
