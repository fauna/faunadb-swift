//
//  WriteFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/15/16.
//
//

import Foundation

public enum Action {
    case Create
    case Delete
}

extension Action: Encodable {
    
    public func toJSON() -> AnyObject {
        switch self {
        case .Create:
            return "create"
        case .Delete:
            return "delete"
        }
    }
}

/**
 *  Creates an instance of a class.
 *
 *  [Create Reference](https://faunadb.com/documentation/queries#write_functions-create_class_ref_params_params_object)
 */
public struct Create: FunctionType {
    let ref: Expr
    let params: Expr
    
    /**
     * Creates an instance of the class referred to by ref, using params.
     
     - parameter ref: Indicates the calss where the instance should be created.
     - parameter params: data to create the instance.
     
     - returns: A Create expression.
     */
    public init(ref: Ref, params: Obj){
        self.init(refExpr: ref, params: params)
    }
    
    public init(refExpr: Expr, params: Expr){
        self.ref = refExpr
        self.params = params
    }
}

extension Create: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["create": ref.toJSON(),
                "params": params.toJSON()]
    }
}

/**
 *  Updates a resource.
 *
 *  [Update Reference](https://faunadb.com/documentation/queries#write_functions-update_ref_params_object)
 */
public struct Update: FunctionType {
    let ref: Expr
    let params: Expr
    
    /**
     Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.
     
     - parameter ref:    Indicates the instance to be updated.
     - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.
     
     - returns: An Update expression.
     */
    public init(ref: Ref, params: Obj){
        self.ref = ref
        self.params = params
    }
    
    public init(refExpr: Expr, params: Expr){
        self.ref = refExpr
        self.params = params
    }
}

extension Update: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["update": ref.toJSON(),
                "params": params.toJSON()]
    }
}

/**
 *  Replaces the resource ref using the provided params. Values not specified are removed.
 *
 *  [Replace Reference](https://faunadb.com/documentation/queries#write_functions-replace_ref_params_params_object)
 */
public struct Replace: FunctionType {
    let ref: Expr
    let params: Expr
    
    /**
     Replaces the resource ref using the provided params. Values not specified are removed.

     
     - parameter ref:    Indicates the instance to be updated.
     - parameter params: new instance data.
     
     - returns: A Replace expression.
     */
    public init(ref: Ref, params: Obj){
        self.init(refExpr: ref, params: params)
    }
    
    public init(refExpr: Expr, params: Expr){
        self.ref = refExpr
        self.params = params
    }
}

extension Replace: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["replace": ref.toJSON(),
                "params": params.toJSON()]
    }
}

/**
 *  Removes a resource.
 *
 *  [Delete Reference](https://faunadb.com/documentation/queries#write_functions-delete_ref)
 */
public struct Delete: FunctionType {
    
    let ref: Expr
    
    /**
     Removes a resource.
     
     - parameter ref: Indicates the resource to remmove.
     
     - returns: A Delete expression.
     */
    public init(ref: Ref){
        self.init(refExpr: ref)
    }
    
    public init(refExpr: Ref){
        self.ref = refExpr
    }
}

extension Delete: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["delete": ref.toJSON()]
    }
}

/**
 *  Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.
 *
 *  [Insert Reference](https://faunadb.com/documentation/queries#write_functions-insert_ref_ts_timestamp_action_create_delete_params_object)
 */
public struct Insert: FunctionType {
    let ref: Expr
    let ts: Timestamp
    let action: Action
    let params: Expr
    
    public init(ref: Ref, ts: Timestamp, action: Action, params: Obj){
        self.init(refExpr: ref, ts: ts, action: action, paramsExpr: params)
    }
    
    public init(refExpr: Expr, ts: Timestamp, action: Action, paramsExpr: Expr){
        self.ref = refExpr
        self.ts = ts
        self.action = action
        self.params = paramsExpr
    }
}


extension Insert: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["insert": ref.toJSON(),
                "ts": ts.toJSON(),
                "action": action.toJSON(),
                "params": params.toJSON()
        ]
    }
}

/**
 *  Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.
 *
 *  [Remove Reference](https://faunadb.com/documentation/queries#write_functions-remove_ref_ts_timestamp_action_create_delete)
 */
public struct Remove: FunctionType {
    let ref: Expr
    let ts: Timestamp
    let action: Action
    
    public init(ref: Ref, ts: Timestamp, action: Action){
        self.init(refExpr: ref, ts: ts, action: action)
    }
    
    public init(refExpr: Expr, ts: Timestamp, action: Action){
        self.ref = refExpr
        self.ts = ts
        self.action = action
    }
}


extension Remove: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["remove": ref.toJSON(),
                "ts": ts.toJSON(),
                "action": action.toJSON()]
    }
}
