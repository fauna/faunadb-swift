import Foundation

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
