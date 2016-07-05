//
//  WriteFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public enum Action: String, ValueConvertible {
    case Create = "create"
    case Delete = "delete"
}

extension Action {
    public var value: Value {
        return self.rawValue
    }
}


/**
 * Creates an instance of the class referred to by ref, using params.
 
 - parameter ref: Indicates the calss where the instance should be created.
 - parameter params: data to create the instance.
 
 - returns: A Create expression.
 */
public func Create(ref ref: Ref, params: Obj) -> Expr{
    return Expr(fn(Obj(("create", ref),("params", params))))
}

    
public func Create(ref: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("create", ref.value),("params", params.value))))
}

    
/**
 Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.
 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.
 
 - returns: An Update expression.
 */
public func Update(ref ref: Ref, params: Obj) -> Expr{
    return Expr(fn(Obj(("update", ref),("params", params))))
}

public func Update(ref: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("update", ref.value),("params", params.value))))
}



    
/**
 Replaces the resource ref using the provided params. Values not specified are removed.

 
 - parameter ref:    Indicates the instance to be updated.
 - parameter params: new instance data.
 
 - returns: A Replace expression.
 */
public func Replace(ref ref: Ref, params: Obj) -> Expr{
    return Expr(fn(Obj(("replace",ref),("params",params))))
}
    
public func Replace(ref: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("replace",ref.value),("params",params.value))))
}



/**
 Removes a resource.
 
 - parameter ref: Indicates the resource to remmove.
 
 - returns: A Delete expression.
 */
public func Delete(ref ref: Ref) -> Expr{
    return Expr(fn(Obj(("delete",ref))))
}

public func Delete(ref: Expr) -> Expr{
    return Expr(fn(Obj(("delete",ref.value))))
}


/**
 *  Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.
 *
 *  [Insert Reference](https://faunadb.com/documentation/queries#write_functions-insert_ref_ts_timestamp_action_create_delete_params_object)
 */
public func Insert(ref ref: Ref, ts: Timestamp, action: Action, params: Obj) -> Expr{
    return Expr(fn(Obj(("insert",ref),("ts", ts),("action", action.value),("params",params))))
}
    
public func Insert(ref: Expr, ts: Expr, action: Expr, params: Expr) -> Expr{
    return Expr(fn(Obj(("insert",ref.value),("ts", ts.value),("action", action.value),("params",params.value))))
}

/**
 *  Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.
 *
 *  [Remove Reference](https://faunadb.com/documentation/queries#write_functions-remove_ref_ts_timestamp_action_create_delete)
 */
public func Remove(ref ref: Ref, ts: Timestamp, action: Action) -> Expr{
    return Expr(fn(Obj(("remove",ref),("ts", ts),("action", action.value))))
}
    
public func Remove(ref: Expr, ts: Expr, action: Expr) -> Expr{
    return Expr(fn(Obj(("remove",ref.value),("ts", ts.value),("action", action.value))))
}
