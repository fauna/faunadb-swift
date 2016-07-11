//
//  WriteFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 * Enumeration for event action types.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 */
public enum Action: String, ValueConvertible {
    case Create = "create"
    case Delete = "delete"
}

extension Action {
    public var value: Value {
        return rawValue
    }
}

/**
 * Creates an instance of the class referred to by ref, using params.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref: Indicates the calss where the instance should be created.
 - parameter params: Data to create the instance.
 
 - returns: A Create expression.
 */
public func Create(ref ref: Ref, params: Obj) -> Expr{
    return Expr(fn(Obj(("create", ref),("params", params))))
}

/**
 * Creates an instance of the class referred to by ref, using params.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref: Indicates the calss where the instance should be created.
 - parameter params: Data to create the instance.
 
 - returns: A Create expression.
 */
public func Create(ref ref: Ref, params: Expr) -> Expr{
    return Expr(fn(Obj(("create", ref),("params", params.value))))
}

/**
 * Creates an instance of the class referred to by ref, using params.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref: Indicates the calss where the instance should be created.
 - parameter params: Data to create the instance.
 
 - returns: A Create expression.
 */
public func Create(ref ref: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("create", ref.value),("params", params.value))))
}

    
/**
 * Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.
 
 - returns: An Update expression.
 */
public func Update(ref ref: Ref, params: Obj) -> Expr{
    return Expr(fn(Obj(("update", ref),("params", params))))
}

/**
 * Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.
 
 - returns: An Update expression.
 */
public func Update(ref ref: Ref, params: Expr) -> Expr{
    return Expr(fn(Obj(("update", ref),("params", params.value))))
}


/**
 * Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.
 
 - returns: An Update expression.
 */
public func Update(ref ref: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("update", ref.value),("params", params.value))))
}

/**
 * Replaces the resource ref using the provided params. Values not specified are removed.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: new instance data.
 
 - returns: A Replace expression.
 */
public func Replace(ref ref: Ref, params: Obj) -> Expr{
    return Expr(fn(Obj(("replace",ref),("params",params))))
}

/**
 * Replaces the resource ref using the provided params. Values not specified are removed.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: new instance data.
 
 - returns: A Replace expression.
 */
public func Replace(ref ref: Ref, params: Expr) -> Expr{
    return Expr(fn(Obj(("replace",ref),("params",params.value))))
}

/**
 * Replaces the resource ref using the provided params. Values not specified are removed.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: new instance data.
 
 - returns: A Replace expression.
 */
public func Replace(ref: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("replace",ref.value),("params",params.value))))
}

/**
 * Removes a resource.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref: Indicates the resource to remove.
 
 - returns: A Delete expression.
 */
public func Delete(ref ref: Ref) -> Expr{
    return Expr(fn(Obj(("delete",ref))))
}

/**
 * Removes a resource.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref: Indicates the resource to remove.
 
 - returns: A Delete expression.
 */
public func Delete(ref: Expr) -> Expr{
    return Expr(fn(Obj(("delete",ref.value))))
}

/**
 * Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the resource.
 - parameter ts:     Event timestamp.
 - parameter action: .Create or .Delete
 - parameter params: Resource data.
 
 - returns: An Insert expression.
 */
public func Insert(ref ref: Ref, ts: Timestamp, action: Action, params: Obj) -> Expr{
    return Expr(fn(["insert": ref, "ts": ts, "action": action.value, "params":params]))
}

/**
 * Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.
 * [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the resource.
 - parameter ts:     Event timestamp.
 - parameter action: .Create or .Delete
 - parameter params: Resource data.
 
 - returns: An Insert expression.
 */
public func Insert(ref: Expr, ts: Expr, action: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("insert",ref.value),("ts", ts.value),("action", action.value),("params",params.value))))
}

/**
 Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.
 [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance resource.
 - parameter ts:     Event timestamp.
 - parameter action: .Create or .Delete
 
 - returns: A Remove expression.
 */
public func Remove(ref ref: Ref, ts: Timestamp, action: Action) -> Expr{
    return Expr(fn(["remove": ref, "ts": ts, "action": action.value]))
}

/**
 Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.
 [Reference](https://faunadb.com/documentation/queries#write_functions)
 
 - parameter ref:    Indicates the instance resource.
 - parameter ts:     Event timestamp.
 - parameter action: .Create or .Delete
 
 - returns: A Remove expression.
 */
public func Remove(ref: Expr, ts: Expr, action: Expr) -> Expr{
    return Expr(fn(["remove": ref.value, "ts": ts.value, "action": action.value]))
}
