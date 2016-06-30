//
//  ReadFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/14/16.
//
//

import Foundation

/**
 * Retrieves the instance identified by ref. If the instance does not exist, an “instance not found” error will be returned. Use the exists predicate to avoid “instance not found” errors.
 *
 * If the client does not have read permission for the instance, a “permission denied” error will be returned.
 *
 * [Get Reference](https://faunadb.com/documentation/queries#read_functions-get_ref)
 */
public struct Get: FunctionType {
    let ref: Expr
    let ts: Timestamp?
    
    /**
     Retrieves the instance specified by ref parameter.
     
     - parameter ref: reference to the intance to be retrived.
     - parameter ts:  if ts is passed `Get` retrieves the instance specified by ref parameter at specific time determined by ts parameter.
     
     - returns: a Get expression.
     */
    public init(ref: Ref, ts: Timestamp? = nil){
        self.ref = ref
        self.ts = ts
    }
    
    public init(_ refExpr: Expr, ts: Timestamp? = nil){
        self.ref = refExpr
        self.ts = ts
    }
}

extension Get: Encodable {
    
    public func toJSON() -> AnyObject {
        let result = ["get": ref.toJSON()]
        return result
    }
}

/**
 *  `Exists` returns boolean true if the provided ref exists (in the case of an instance), or is non-empty (in the case of a set), and false otherwise.
 *
 * [Exists Reference](https://faunadb.com/documentation/queries#read_functions-exists_ref)
 */
public struct Exists: FunctionType {
    
    let ref: Ref
    let ts: Timestamp?
    
    /**
     Creates a Exists expression.
     
     - parameter ref: Ref value to check if exists.
     - parameter ts:  Existence of the ref is checked at given time.
     
     - returns: A Exists expression.
     */
    init(ref: Ref, ts: Timestamp? = nil){
        self.ref = ref
        self.ts = ts
    }
}

extension Exists: Encodable {
    
    public func toJSON() -> AnyObject {
        if let ts = ts {
            return ["exists": ref.toJSON(),
                    "ts": ts.toJSON()]
        }
        return ["exists": ref.toJSON()]
    }
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
public struct Paginate: FunctionType {
    let resource: Expr
    let cursor: Cursor?
    let ts: Timestamp?
    let size: Int?
    let events: Bool
    let sources:Bool
    
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
    public init(resource: Expr, cursor: Cursor? = nil, ts: Timestamp? = nil, size: Int? = nil, events: Bool = false, sources: Bool = false){
        self.resource = resource
        self.cursor = cursor
        self.ts = ts
        self.size = size
        self.events = events
        self.sources = sources
    }
}

extension Paginate: Encodable {
    
    public func toJSON() -> AnyObject {
        var result = ["paginate": resource.toJSON()]
        if let cursor = cursor {
            switch cursor {
            case .Before(let expr):
                result["before"] = expr.toJSON()
            case .After(let expr):
                result["after"] = expr.toJSON()
            }
        }
        _ = ts.map { result["ts"] = $0.toJSON() }
        _ = size.map { result["size"] = $0.toJSON() }
        if events == true { result["events"] = true }
        if sources == true { result["sources"] = true }
        return result
    }
}


/**
 *  `Count` returns the approximate count of instances or events in the set identified by  set. set must be a concrete set represented by a match expression.  count returns null for any other set. If the set does not exist, an “invalid expression” error will be returned.
 *
 * [Count Reference](https://faunadb.com/documentation/queries#read_functions-count_set)
 */
public struct Count: FunctionType {
    let set: Expr
    let events: Bool
    
    public init(set: Match, events:Bool = false){
        self.init(set: set as Expr, events: events)
    }
    
    public init(set: Expr, events:Bool = false){
        self.set = set
        self.events = events
    }
}


extension Count: Encodable {
    
    public func toJSON() -> AnyObject {
        if events == true {
            return ["count": set.toJSON(), "events": true]
        }
        return ["count": set.toJSON()]
    }
}

