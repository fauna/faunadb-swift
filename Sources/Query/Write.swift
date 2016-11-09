import Foundation

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
