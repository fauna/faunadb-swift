//
//  WriteFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
    Enumeration for event action types.

    [Reference](https://faunadb.com/documentation/queries#write_functions)
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

public struct Create: Expr {

    public var value: Value

    /**
     Creates an instance of the class referred to by ref, using params.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref: Indicates the class where the instance should be created.
     - parameter params: Data to create the instance.

     - returns: A Create expression.
     */
    public init(ref: Ref, params: Obj){
        self.init(ref: ref as Expr, params: params as Expr)
    }

    /**
     Creates an instance of the class referred to by ref, using params.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref: Indicates the class where the instance should be created.
     - parameter params: Data to create the instance.

     - returns: A Create expression.
     */
    public init(ref: Ref, params: Expr){
        self.init(ref: ref as Expr, params: params as Expr)
    }

    /**
     Creates an instance of the class referred to by ref, using params.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref: Indicates the class where the instance should be created.
     - parameter params: Data to create the instance.

     - returns: A Create expression.
     */
    public init(ref: Expr, params: Expr){
        value = Obj(fnCall:["create": ref, "params": params])
    }

}

public struct Update: Expr {

    public var value: Value

    /**
     Updates a resource ref. Updates are partial, and only modify values that are specified. Scalar values and arrays are replaced by newer versions, objects are merged, and null removes a value.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance to be updated.
     - parameter params: data to update the instance. Notice that Obj are merged, and Null removes a value.

     - returns: An Update expression.
     */
    public init(ref: Expr, params: Expr){
        value = Obj(fnCall:["update": ref, "params": params])
    }
}


public struct Replace: Expr{

    public var value: Value

    /**
     Replaces the resource ref using the provided params. Values not specified are removed.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance to be updated.
     - parameter params: new instance data.

     - returns: A Replace expression.
     */
    public init(ref: Expr, params: Expr){
        value = Obj(fnCall:["replace": ref, "params": params])
    }

}


public struct Delete: Expr {

    public var value: Value

    /**
     Removes a resource.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref: Indicates the resource to remove.

     - returns: A Delete expression.
     */
    public init(ref: Expr){
        value = Obj(fnCall:["delete": ref])
    }

}


public struct Insert: Expr {

    public var value: Value

    /**
     Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the resource.
     - parameter ts:     Event timestamp.
     - parameter action: .Create or .Delete
     - parameter params: Resource data.

     - returns: An Insert expression.
     */
    public init(ref: Ref, ts: Timestamp, action: Action, params: Obj){
        self.init(ref: ref as Expr, ts: ts as Expr, action: action.rawValue, params: params as Expr)
    }

    /**
     Adds an event to an instance’s history. The ref must refer to an instance of a user-defined class or a key - all other refs result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the resource.
     - parameter ts:     Event timestamp.
     - parameter action: .Create or .Delete
     - parameter params: Resource data.

     - returns: An Insert expression.
     */
    public init(ref: Expr, ts: Expr, action: Expr, params: Expr){
        value = Obj(fnCall:["insert": ref, "ts": ts, "action": action, "params": params])
    }
}

public struct Remove: Expr {

    public var value: Value


    /**
     Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance resource.
     - parameter ts:     Event timestamp.
     - parameter action: .Create or .Delete

     - returns: A Remove expression.
     */
    public init(ref: Ref, ts: Timestamp, action: Action){
        self.init(ref: ref as Expr, ts: ts as Expr, action: action.rawValue)
    }

    /**
     Deletes an event from an instance’s history. The ref must refer to an instance of a user-defined class - all other refs result in an “invalid argument” error.

     [Reference](https://faunadb.com/documentation/queries#write_functions)

     - parameter ref:    Indicates the instance resource.
     - parameter ts:     Event timestamp.
     - parameter action: .Create or .Delete

     - returns: A Remove expression.
     */
    public init(ref: Expr, ts: Expr, action: Expr){
        value = Obj(fnCall:["remove": ref, "ts": ts, "action": action])
    }

}
