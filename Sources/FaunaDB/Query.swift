// swiftlint:disable file_length
import Foundation

// MARK: Values

public struct Ref: Fn {

    var call: Fn.Call

    public init(_ id: String) {
        self.call = fn("@ref" => id)
    }

    public init(class: Expr, id: Expr) {
        self.call = fn("ref" => `class`, "id" => id)
    }

}

// MARK: Basic Forms

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

// MARK: Collections

public struct Map: Fn {

    var call: Fn.Call

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.

     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item.

     - returns: A Map expression.
     */
    public init(collection: Expr, to lambda: Expr) {
        self.call = fn("map" => lambda, "collection" => collection)
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.

     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item.

     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: (Expr) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.

     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection:    collection to perform map expression. Collection elements must be an array of 2 elements which will be bounded to lamba arguments.
     - parameter lambda:        lambda expression to apply to each collection item.

     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.

     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 3 elements which will be bounded to lamba arguments.

     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.

     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 4 elements which will be bounded to lamba arguments.


     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }

    /**
     `Map` applies `lambda` expression to each member of the Array or Page collection, and returns the results of each application in a new collection of the same type. If a Page is passed, its cursor is preserved in the result.

     `Map` applies the `lambda` expression concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection:    collection to perform map expression.
     - parameter lambda:        lambda expression to apply to each collection item. Collection elements must be an array of 4 elements which will be bounded to lamba arguments.


     - returns: A Map expression.
     */
    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, to: Lambda(fn))
    }
}

public struct Foreach: Fn {

    var call: Fn.Call

    /**
     `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.

     `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection: collection to perform foreach expression.
     - parameter lambda:     lambda expression to apply to each collection item.

     - returns: A Foreach expression.
     */
    public init(collection: Expr, in lambda: Expr) {
        self.call = fn("foreach" => lambda, "collection" => collection)
    }

    /**
     `Foreach` applies `lambda` expr to each member of the Array or Page coll. The original collection is returned.

     `Foreach` applies the lambda_expr concurrently to each element of the collection. Side-effects, such as writes, do not affect evaluation of other lambda applications. The order of possible refs being generated within the lambda are non-deterministic.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection: collection to perform foreach expression.
     - parameter lambda:     lambda expression to apply to each collection item.

     - returns: A Foreach expression.
     */
    public init(_ collection: Expr, _ fn: (Expr) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, in: Lambda(fn))
    }
}

public struct Filter: Fn {

    var call: Fn.Call

    /**
     `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.

     Providing a lambda which does not return a Boolean results in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection: collection to perform filter expression.
     - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.

     - returns: A Filter expression.
     */
    public init(collection: Expr, with lambda: Expr) {
        self.call = fn("filter" => lambda, "collection" => collection)
    }

    /**
     `Filter` applies `lambda` expr to each member of the Array or Page collection, and returns a new collection of the same type containing only those elements for which `lambda` expr returned true. If a Page is passed, its cursor is preserved in the result.

     Providing a lambda which does not return a Boolean results in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter collection: collection to perform filter expression.
     - parameter lambda:      lambda expression to apply to each collection item. Must return a boolean value.

     - returns: A Filter expression.
     */
    public init(_ collection: Expr, _ fn: (Expr) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

    public init(_ collection: Expr, _ fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(collection: collection, with: Lambda(fn))
    }

}

public struct Take: Fn {

    var call: Fn.Call

    /**
     `Take` returns a new Collection or Page that contains num elements from the head of the Collection or Page coll.
     If `take` value is zero or negative, the resulting collection is empty.
     When applied to a page, the returned page’s after cursor is adjusted to only cover the taken elements.

     As special cases:
     * If `take` value is negative, after will be set to the same value as the original page’s  before.
     * If all elements from the original page were taken, after does not change.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter count:      number of items to take.
     - parameter collection: collection or page.

     - returns: A take expression.
     */
    public init(count: Expr, from collection: Expr) {
        self.call = fn("take" => count, "collection" => collection)
    }
}

public struct Drop: Fn {

    var call: Fn.Call

    /**
     `Drop` returns a new Arr or Page that contains the remaining elements, after num have been removed from the head of the Arr or Page coll. If `drop` value is zero or negative, elements of coll are returned unmodified.

     When applied to a page, the returned page’s before cursor is adjusted to exclude the dropped elements. As special cases:
     * If `drop` value is negative, before does not change.
     * Otherwise if all elements from the original page were dropped (including the case where the page was already empty), before will be set to same value as the original page’s after.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter count:      number of items to drop.
     - parameter collection: collection or page.

     - returns: A Drop expression.
     */
    public init(count: Expr, from collection: Expr) {
        self.call = fn("drop" => count, "collection" => collection)
    }

}

public struct Prepend: Fn {

    var call: Fn.Call

    /**
     `Prepend` returns a new Array that is the result of prepending `elements` onto the Array `toCollection`.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter elements:     elements to prepend onto `toCollection` collection.
     - parameter toCollection: collection.

     - returns: A Prepend expression.
     */
    public init(elements: Expr, to collection: Expr) {
        self.call = fn("prepend" => elements, "collection" => collection)
    }
}

public struct Append: Fn {

    var call: Fn.Call

    /**
     `Append` returns a new Array that is the result of appending `elements` onto the `toCollection` array.

     [Reference](https://faunadb.com/documentation/queries#collection_functions)

     - parameter elements:   elements to append to `toCollectiopn` collection.
     - parameter toCollection: collection.

     - returns: An Append expression.
     */
    public init(elements: Expr, to collection: Expr) {
        self.call = fn("append" => elements, "collection" => collection)
    }

}

// MARK: Read Functions

public struct Get: Fn {

    var call: Fn.Call

    /**
     Retrieves the instance identified by ref. If the instance does not exist, an “instance not found” error will be returned. Use the exists predicate to avoid “instance not found” errors.
     [Reference](https://faunadb.com/documentation/queries#read_functions-get_ref)

     - parameter ref: reference to the intance to retrive.
     - parameter ts:  if `ts` is passed `Get` retrieves the instance specified by ref parameter at specific time determined by ts parameter. Optional.

     - returns: a Get expression.
     */
    public init(_ ref: Expr, ts: Expr? = nil) {
        self.call = fn("get" => ref, "ts" => ts)
    }

}

public struct Paginate: Fn {

    var call: Fn.Call

    /**
     `Paginate` retrieves a page from the set identified by `resource`. A valid set is any set identifier or instance ref. Instance refs represent singleton sets of themselves.

     [Reference](https://faunadb.com/documentation/queries#read_functions)

     - parameter resource: Resource that contains the set to be paginated.
     - parameter cursor:   Indicates from where the page should be retrieved.
     - parameter ts:       If passed, it returns the set at the specified point in time.
     - parameter size:     Maximum number of results to return. Default `16`.
     - parameter events:   If true, return a page from the event history of the set. Default `false`.
     - parameter sources:  If true, include the source sets along with each element. Default `false`.

     - returns: A Paginate expression.
     */
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

public struct Exists: Fn {

    var call: Fn.Call

    /**
     `Exists` returns boolean true if the provided ref exists (in the case of an instance), or is non-empty (in the case of a set), and false otherwise.

     [Reference](https://faunadb.com/documentation/queries#read_functions)

     - parameter ref: Ref value to check if exists.
     - parameter ts:  Existence of the ref is checked at given time.

     - returns: A Exists expression.
     */
    public init(_ ref: Expr, ts: Expr? = nil) {
        self.call = fn("exists" => ref, "ts" => ts)
    }

}

// MARK: Write Functions

public struct Create: Fn {

    var call: Fn.Call

    /**
     Creates an instance of the class referred to by ref, using params.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref: Indicates the class where the instance should be created.
     - parameter params: Data to create the instance.

     - returns: A Create expression.
     */
    public init(at classRef: Expr, _ params: Expr) {
        self.call = fn("create" => classRef, "params" => params)
    }

}

public struct Update: Fn {

    var call: Fn.Call

    /**
     Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance to be updated.
     - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.

     - returns: An Update expression.
     */
    public init(ref: Expr, to params: Expr) {
        self.call = fn("update" => ref, "params" => params)
    }
}

public struct Replace: Fn {

    var call: Fn.Call

    /**
     Replaces the resource ref using the provided params. Values not specified are removed.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance to be updated.
     - parameter params: new instance data.

     - returns: A Replace expression.
     */
    public init(ref: Expr, with params: Expr) {
        self.call = fn("replace" => ref, "params" => params)
    }

}

public struct Delete: Fn {

    var call: Fn.Call

    /**
     Removes a resource.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref: Indicates the resource to remove.

     - returns: A Delete expression.
     */
    public init(ref: Expr) {
        self.call = fn("delete" => ref)
    }

}

/**
 Enumeration for event action types.

 [Reference](https://faunadb.com/documentation/queries#write_functions)
 */
public enum Action: String {
    case create = "create"
    case delete = "delete"
}

extension Action: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self.rawValue)
    }
}

public struct Insert: Fn {

    var call: Fn.Call

    /**
     Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the resource.
     - parameter ts:     Event timestamp.
     - parameter action: .Create or .Delete
     - parameter params: Resource data.

     - returns: An Insert expression.
     */
    public init(ref: Expr, ts: Expr, action: Expr, params: Expr) {
        self.call = fn("insert" => ref, "ts" => ts, "action" => action, "params" => params)
    }

    public init(in ref: Expr, ts: Expr, action: Action, params: Expr) {
        self.init(ref: ref, ts: ts, action: action, params: params)
    }

}

public struct Remove: Fn {

    var call: Fn.Call

    /**
     Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance resource.
     - parameter ts:     Event timestamp.
     - parameter action: .Create or .Delete

     - returns: A Remove expression.
     */
    public init(ref: Expr, ts: Expr, action: Expr) {
        self.call = fn("remove" => ref, "ts" => ts, "action" => action)
    }

    public init(from ref: Expr, ts: Expr, action: Action) {
        self.init(ref: ref, ts: ts, action: action)
    }

}

public struct CreateClass: Fn {

    var call: Fn.Call

    public init(_ params: Expr) {
        self.call = fn("create_class" => params)
    }

}

public struct CreateDatabase: Fn {

    var call: Fn.Call

    public init(_ params: Expr) {
        self.call = fn("create_database" => params)
    }

}

public struct CreateIndex: Fn {

    var call: Fn.Call

    public init(_ params: Expr) {
        self.call = fn("create_index" => params)
    }

}

public struct CreateKey: Fn {

    var call: Fn.Call

    public init(_ params: Expr) {
        self.call = fn("create_key" => params)
    }

}

// MARK: Set Functions

public struct Match: Fn {

    var call: Fn.Call

    /**
     `Match` returns the set of instances that match the terms, based on the configuration of the specified index. terms can be either a single value, or an array.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter index: index to use to perform the match.
     - parameter terms: terms can be either a single value, or multiple values. The number of terms provided must match the number of term fields indexed by indexRef. If indexRef is configured with no terms, then terms may be omitted.

     - returns: a Match expression.
     */
    public init(index: Expr, terms: Expr...) {
        self.call = fn(
            "match" => index,
            "terms" => (terms.count > 0 ? varargs(terms) : nil)
        )
    }
}

public struct Union: Fn {

    var call: Fn.Call

    /**
     `Union` represents the set of resources that are present in at least one of the specified sets.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sets: sets of resources to perform Union expression.

     - returns: An Union Expression.
     */
    public init(_ sets: Expr...) {
        self.call = fn("union" => varargs(sets))
    }

}

public struct Intersection: Fn {

    var call: Fn.Call

    /**
     `Intersection` represents the set of resources that are present in all of the specified sets.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sets: sets of resources to perform Intersection expression.

     - returns: An Intersection expression.
     */
    public init(_ sets: Expr...) {
        self.call = fn("intersection" => varargs(sets))
    }

}

public struct Difference: Fn {

    var call: Fn.Call

    /**
     `Difference` represents the set of resources present in the source set and not in any of the other specified sets.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sets: sets of resources to perform Difference expression.

     - returns: An Intersection expression.
     */
    public init(_ sets: Expr...) {
        self.call = fn("difference" => varargs(sets))
    }

}

public struct Distinct: Fn {

    var call: Fn.Call

    /**
     Distinct function returns the set after removing duplicates.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter set: determines the set where distinct function should be performed.

     - returns: A Distinct expression.
     */
    public init(_ set: Expr) {
        self.call = fn("distinct" => set)
    }

}

public struct Join: Fn {

    var call: Fn.Call

    /**
     `Join` derives a set of resources from target by applying each instance in `sourceSet` to `with` target. Target can be either an index reference or a lambda function.
     The index form is useful when the instances in the `sourceSet` match the terms in an index. The join returns instances from index (specified by with) that match the terms from `sourceSet`.

     [Reference](https://faunadb.com/documentation/queries#sets)

     - parameter sourceSet: set to perform the join.
     - parameter with:      `with` target can be either an index reference or a lambda function.

     - returns: A `Join` expression.
     */
    public init(_ sourceSet: Expr, with: Expr) {
        self.call = fn("join" => sourceSet, "with" => with)
    }

    public init(_ sourceSet: Expr, fn: (Expr) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

    public init(_ sourceSet: Expr, fn: ((Expr, Expr, Expr, Expr, Expr)) -> Expr) {
        self.init(sourceSet, with: Lambda(fn))
    }

}

// MARK: Auth Functions

public struct Login: Fn {

    var call: Fn.Call

    /**
     `Login` creates a token for the provided ref.

     [Reference](https://faunadb.com/documentation/queries#auth_functions)

     - parameter ref:    A Ref instance or something that evaluates to a `Ref` instance.
     - parameter params: Expression which provides the password.

     - returns: A `Login` expression.
     */
    public init(for ref: Expr, _ params: Expr) {
        self.call = fn("login" => ref, "params" => params)
    }

}

public struct Logout: Fn {

    var call: Fn.Call

    /**
     `Logout` deletes all tokens associated with the current session if its parameter is `true`, or just the token used in this request otherwise.

     - parameter invalidateAll: if true deletes all tokens associated with the current session. If false it deletes just the token used in this request.

     - returns: A `Logout` expression.
     */
    public init(all: Expr) {
        self.call = fn("logout" => all)
    }

}

public struct Identify: Fn {

    var call: Fn.Call

    /**
     `Identify` checks the given password against the ref’s credentials, returning `true` if the credentials are valid, or `false` otherwise.

     - parameter ref:      Identifies an instance.
     - parameter password: Password to check agains `ref` instance.

     - returns: A `Identify` expression.
     */
    public init(ref: Expr, password: Expr) {
        self.call = fn("identify" => ref, "password" => password)
    }

}

// MARK: String Functions

public struct Concat: Fn {

    var call: Fn.Call

    /**
     `Concat` joins a list of strings into a single string value.

     [Reference](https://faunadb.com/documentation/queries#string_functions)

     - parameter strs:      Expresion that should evaluate to a list of strings.
     - parameter separator: A string separating each element in the result. Optional. Default value: Empty String.

     - returns: A Concat expression.
     */
    public init(_ strings: Expr..., separator: Expr? = nil) {
        self.call = fn("concat" => varargs(strings), "separator" => separator)
    }
}

public struct Casefold: Fn {

    var call: Fn.Call

    /**
     `Casefold` normalizes strings according to the Unicode Standard section 5.18 “Case Mappings”.

     To compare two strings for case-insensitive matching, transform each string and use a binary comparison, such as  equals.

     [Reference](https://faunadb.com/documentation/queries#string_functions)

     - parameter str: Expression that exaluates to a string value.

     - returns: A Casefold expression.
     */
    public init(_ str: Expr) {
        self.call = fn("casefold" => str)
    }

}

// MARK: Date and Time Functions

public struct Time: Fn {

    var call: Fn.Call

    /**
     `Time` constructs a time special type from an ISO 8601 offset date/time string. The special string “now” may be used to construct a time from the current request’s transaction time. Multiple references to “now” within the same query will be equal.

     [Reference](https://faunadb.com/documentation/queries#time_functions)

     - parameter expr: ISO8601 offset date/time string, "now" can be used to create current request evaluation time.

     - returns: A time expression.
     */
    public init(fromString string: Expr) {
        self.call = fn("time" => string)
    }

}

public enum TimeUnit: String {
    case second = "second"
    case millisecond = "millisecond"
    case microsecond = "microsecond"
    case nanosecond = "nanosecond"
}

extension TimeUnit: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self.rawValue)
    }
}

public struct Epoch: Fn {

    var call: Fn.Call

    /**
     `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”.

     [Reference](https://faunadb.com/documentation/queries#time_functions)

     - parameter offset: number relative to the epoch.
     - parameter unit:   offset unit.

     - returns: A Epoch expression.
     */
    public init(_ offset: Expr, _ unit: Expr) {
        self.call = fn("epoch" => offset, "unit" => unit)
    }

    /**
     `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”.

     [Reference](https://faunadb.com/documentation/queries#time_functions)

     - parameter offset: number relative to the epoch.
     - parameter unit:   offset unit.

     - returns: A Epoch expression.
     */
    public init(offset: Expr, unit: TimeUnit) {
        self.init(offset, unit)
    }

}

public struct DateFn: Fn {

    var call: Fn.Call

    /**
     `Date` constructs a date special type from an ISO 8601 date string.

     [Reference](https://faunadb.com/documentation/queries#time_functions)
     */
    public init(string: String) {
        self.call = fn("date" => string)
    }

}

// MARK: Miscellaneous Functions

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
