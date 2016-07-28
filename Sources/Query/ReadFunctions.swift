//
//  ReadFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Get: Expr{

    public var value: Value

    /**
     Retrieves the instance identified by ref. If the instance does not exist, an “instance not found” error will be returned. Use the exists predicate to avoid “instance not found” errors.
     [Reference](https://faunadb.com/documentation/queries#read_functions-get_ref)

     - parameter ref: reference to the intance to retrive.
     - parameter ts:  if ts is passed `Get` retrieves the instance specified by ref parameter at specific time determined by ts parameter. Optional.

     - returns: a Get expression.
     */
    public init(ref: Ref, ts: Timestamp? = nil){
        self.init(ref: ref as Expr, ts: ts as? Expr)
    }

    /**
     Retrieves the instance identified by ref. If the instance does not exist, an “instance not found” error will be returned. Use the exists predicate to avoid “instance not found” errors.
     [Reference](https://faunadb.com/documentation/queries#read_functions-get_ref)

     - parameter ref: reference to the intance to retrive.
     - parameter ts:  if ts is passed `Get` retrieves the instance specified by ref parameter at specific time determined by ts parameter. Optional.

     - returns: a Get expression.
     */
    public init(ref: Expr, ts: Expr? = nil){

        value = {
            var obj = Obj(fnCall: ["get":ref])
            obj["ts"] = ts
            return obj
        }()
    }
}

public struct Exists: Expr {

    public var value: Value


    /**
     `Exists` returns boolean true if the provided ref exists (in the case of an instance), or is non-empty (in the case of a set), and false otherwise.

     [Reference](https://faunadb.com/documentation/queries#read_functions)

     - parameter ref: Ref value to check if exists.
     - parameter ts:  Existence of the ref is checked at given time.

     - returns: A Exists expression.
     */
    public init(ref: Ref, ts: Timestamp? = nil){
        self.init(ref: ref as Expr, ts: ts as? Expr)
    }


    /**
     `Exists` returns boolean true if the provided ref exists (in the case of an instance), or is non-empty (in the case of a set), and false otherwise.

     [Reference](https://faunadb.com/documentation/queries#read_functions)

     - parameter ref: Ref value to check if exists.
     - parameter ts:  Existence of the ref is checked at given time.

     - returns: A Exists expression.
     */
    public init(ref: Expr, ts: Expr? = nil){
        value = {
            var obj = Obj(fnCall: ["exists": ref])
            obj["ts"] = ts
            return obj
        }()
    }
}


public struct Count: Expr {

    public var value: Value

    /**
     `Count` returns the approximate count of instances or events in the set identified by set. `set` must be a concrete set represented by a match expression. `Count` returns null for any other set. If the set does not exist, an “invalid expression” error will be returned.

     [Reference](https://faunadb.com/documentation/queries#read_functions)

     - parameter set:         set to perform count expression.
     - parameter countEvents: If true, return the counts of events in the history of the set.

     - returns: A Count expression.
     */
    public init(set: Expr, countEvents: Bool = false){
        self.init(set: set as Expr, countEvents: countEvents as Expr)
    }

    /**
     `Count` returns the approximate count of instances or events in the set identified by set. `set` must be a concrete set represented by a match expression. `Count` returns null for any other set. If the set does not exist, an “invalid expression” error will be returned.

     [Reference](https://faunadb.com/documentation/queries#read_functions)

     - parameter set:         set to perform count expression.
     - parameter countEvents: If true, return the counts of events in the history of the set.

     - returns: A Count expression.
     */
    public init(set: Expr, countEvents: Expr){
        if let bool = countEvents.value as? Bool where bool == false{
            value = Obj(fnCall:["count": set])
        }
        else{
            value = Obj(fnCall:["count": set, "events": countEvents])
        }
    }
}

/**
 Curors are used for retrieving pages before or after the current page. Indicates from where or up to where the page should be retrieved.
 */
public enum Cursor {
    case Before(expr: Expr)
    case After(expr:Expr)
}


public struct Paginate: Expr {

    public var value: Value

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
    public init(resource: Expr, cursor: Cursor? = nil, ts: Timestamp? = nil, size: Int? = nil, events: Bool = false, sources: Bool = false){
        self.init(resource, cursor: cursor, ts: ts as? Expr, size: size as? Expr, events: events == true ? true: nil, sources: sources == true ? true: nil)
    }

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
    public init(_ resource: Expr, cursor: Cursor? = nil, ts: Expr? = nil, size: Expr? = nil, events: Expr? = nil, sources: Expr? = nil){
        value = {
            var obj = Obj(fnCall: ["paginate": resource])
            if let cursor = cursor {
                switch cursor {
                case .Before(let expr):
                    obj["before"] = expr
                case .After(let expr):
                    obj["after"] = expr
                }
            }
            obj["ts"] = ts
            obj["size"] = size
            let _ = events.map {  obj["events"] = $0 }
            let _ = sources.map { obj["sources"] = $0 }
            return obj
        }()
    }

}
