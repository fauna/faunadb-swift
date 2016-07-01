//
//  ReadFunctions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

/**
 * Retrieves the instance identified by ref. If the instance does not exist, an “instance not found” error will be returned. Use the exists predicate to avoid “instance not found” errors.
 *
 * If the client does not have read permission for the instance, a “permission denied” error will be returned.
 *
 * [Get Reference](https://faunadb.com/documentation/queries#read_functions-get_ref)
 */
/**
 Retrieves the instance specified by ref parameter.
 
 - parameter ref: reference to the intance to be retrived.
 - parameter ts:  if ts is passed `Get` retrieves the instance specified by ref parameter at specific time determined by ts parameter.
 
 - returns: a Get expression.
 */
public func Get(ref ref: Ref, ts: Timestamp? = nil) -> Expr{
    var obj: Obj = ["get":ref]
    obj["ts"] = ts
    return Expr(fn(obj))
}
    
public func Get(ref: Expr, ts: Timestamp? = nil) -> Expr{
    var obj: Obj = ["get":ref.value]
    obj["ts"] = ts
    return Expr(fn(obj))
}

/**
 *  `Exists` returns boolean true if the provided ref exists (in the case of an instance), or is non-empty (in the case of a set), and false otherwise.
 *
 * [Exists Reference](https://faunadb.com/documentation/queries#read_functions-exists_ref)
 */
/**
 Creates a Exists expression.
 
 - parameter ref: Ref value to check if exists.
 - parameter ts:  Existence of the ref is checked at given time.
 
 - returns: A Exists expression.
 */
public func Exists(ref ref: Ref, ts: Timestamp? = nil) -> Expr{
    var obj = ["exists": ref] as Obj
    obj["ts"] = ts
    return Expr(fn(obj))
}
    
public func Exists(ref: Expr, ts: Timestamp? = nil) -> Expr{
    var obj = ["exists": ref.value] as Obj
    obj["ts"] = ts
    return Expr(fn(obj))
}

/**
 Indicates from where or up to where the page should be retrieved.
 
 - Before: <#Before description#>
 - After:  <#After description#>
 */
public enum Cursor {
    case Before(expr: Expr)
    case After(expr:Expr)
}

/**
 *  `Paginate` retrieves a page from the set identified by set. A valid set is any set identifier or instance ref. Instance refs represent singleton sets of themselves.
 *
 *  [Paginate Reference](https://faunadb.com/documentation/queries#read_functions-paginate_set)
 */
/**
 Creates a Paginate expression.
 
 - parameter resource: Resource that contains the set to be paginated.
 - parameter cursor:   Indicates from where the page should be retrieved.
 - parameter ts:       If passed, it returns the set at the specified point in time.
 - parameter size:     Maximum number of results to return. Default `16`.
 - parameter events:   If true, return a page from the event history of the set. Default `false`.
 - parameter sources:  If true, include the source sets along with each element. Default `false`.
 
 - returns: A Paginate expression.
 */
public func Paginate(resource resource: Expr, cursor: Cursor? = nil, ts: Timestamp? = nil, size: Int? = nil, events: Bool = false, sources: Bool = false) -> Expr{
    var obj = ["paginate": resource.value] as Obj
    if let cursor = cursor {
        switch cursor {
        case .Before(let expr):
            obj["before"] = expr.value
        case .After(let expr):
            obj["after"] = expr.value
        }
    }
    obj["ts"] = ts?.value
    obj["size"] = size?.value
    if events == true { obj["events"] = true }
    if sources == true { obj["sources"] = true }
    return Expr(fn(obj))
}


public func Paginate(resource: Expr, cursor: Cursor? = nil, ts: Expr? = nil, size: Expr? = nil, events: Expr? = nil, sources: Expr? = nil) -> Expr{
    var obj = ["paginate": resource.value] as Obj
    if let cursor = cursor {
        switch cursor {
        case .Before(let expr):
            obj["before"] = expr.value
        case .After(let expr):
            obj["after"] = expr.value
        }
    }
    obj["ts"] = ts?.value
    obj["size"] = size?.value
    let _ = events.map { obj["events"] = $0.value }
    let _ = sources.map { obj["sources"] = $0.value }
    return Expr(fn(obj))
}




/**
 *  `Count` returns the approximate count of instances or events in the set identified by  set. set must be a concrete set represented by a match expression.  count returns null for any other set. If the set does not exist, an “invalid expression” error will be returned.
 *
 * [Count Reference](https://faunadb.com/documentation/queries#read_functions-count_set)
 */
public func Count(set set: Expr, events: Bool = false) -> Expr{
    var obj: Obj = ["count": set.value]
    obj["events"] = events == true ? true : nil
    return Expr(fn(obj))
}


