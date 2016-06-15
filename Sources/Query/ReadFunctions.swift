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
 * If the client does not have read permission for the instance, a “permission denied” error will be returned.
 */
public struct Get: FunctionType {
    let ref: Ref
    let ts: Timestamp?
    
    /**
     Retrieves the instance specified by ref parameter.
     
     - parameter ref: reference to the intance to be retrived.
     
     - returns: a Get expression.
     */
    public init(ref: Ref){
        self.ref = ref
        self.ts = nil
    }
    
    /**
    Retrieves the instance specified by ref parameter at specific time determined by ts parameter.
     
     - parameter ref: reference to the intance to be retrived.
     - parameter ts:  retrieved instance state time.
     
     - returns: a Get expression.
     */
    public init(ref: Ref, ts: Timestamp){
        self.ref = ref
        self.ts = ts
    }
}

extension Get: Encodable {
    
    public func toJSON() -> AnyObject {
        let result = ["get": ref.toJSON()]
        return result
    }
}


public enum Cursor {
    case Before(expr: Expr)
    case After(expr:Expr)
}

/**
 *  Paginate retrieves a page from the set identified by set. A valid set is any set identifier or instance ref. Instance refs represent singleton sets of themselves.
 */
public struct Paginate: FunctionType {
    let resource: Expr
    let cursor: Cursor?
    let ts: Timestamp?
    let size: Int?
    let events: Bool
    let sources:Bool
    
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
 *  Count returns the approximate count of instances or events in the set identified by  set. set must be a concrete set represented by a match expression.  count returns null for any other set. If the set does not exist, an “invalid expression” error will be returned.
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

