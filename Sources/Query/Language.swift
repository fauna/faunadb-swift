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
                        "object" ~~> params])
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
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
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
            "object" ~~> params])
    }
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
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
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
    }
}

//struct Insert {
//    let ref: Ref
//    let ts: NSTimeInterval
//    let action: Action
//    let params: Obj
//}
//
//
//struct Remove {
//    let ref: Ref
//    let ts: NSTimeInterval
//    let action: Action
//    let params: Obj
//}
//
