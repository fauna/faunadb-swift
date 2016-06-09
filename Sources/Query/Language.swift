//
//  Language.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss

public enum Action {
    case Create
    case Delete
}

extension Action {
    public func toAnyObjectJSON() -> AnyObject? {
        switch self {
        case .Create:
            return "create"
        case .Delete:
            return "delete"
        }
    }
}

protocol SimpleFunctionType: FunctionType {
    init(_ ref: Ref, _ params: Obj)
}

public struct Create: SimpleFunctionType {
    var ref: Ref
    var params: Obj
    
    public init(_ ref: Ref, _ params: Obj){
        self.ref = ref
        self.params = params
    }
}

extension Create: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["create" ~~> ref,
                        "params" ~~> params])
    }
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
    }
}

public struct Update: SimpleFunctionType {
    var ref: Ref
    var params: Obj
    
    public init(_ ref: Ref, _ params: Obj){
        self.ref = ref
        self.params = params
    }
}

extension Update: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["update" ~~> ref,
            "object" ~~> params])
    }
}

public struct Replace: SimpleFunctionType {
    var ref: Ref
    var params: Obj
    
    public init(_ ref: Ref, _ params: Obj){
        self.ref = ref
        self.params = params
    }
}

extension Replace: Encodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["replace" ~~> ref,
                        "params" ~~> params])
    }
}


public struct Delete: FunctionType {
    
    var ref: Ref
    
    init(_ ref: Ref){
        self.ref = ref
    }
}

extension Delete: Encodable {
    
    public func toJSON() -> JSON? {
        return "delete" ~~> ref
    }
}

public struct Insert: FunctionType {
    let ref: Ref
    let ts: Timestamp
    let action: Action
    let params: Obj
}

extension Insert: Encodable, FaunaEncodable {
 
    public func toJSON() -> JSON? {
        return jsonify(["insert" ~~> ref,
                        "ts" ~~> ts,
                        "action" ~~> action.toAnyObjectJSON(),
                        "params" ~~> params
            ])
    }
}

public struct Remove: FunctionType {
    let ref: Ref
    let ts: Timestamp
    let action: Action
}


extension Remove: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        return jsonify(["remove" ~~> ref,
                        "ts" ~~> ts,
                        "action" ~~> action.toAnyObjectJSON()
            ])
    }
}
