//
//  Expr.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss


public protocol FaunaEncodable {
    func toAnyObjectJSON() -> AnyObject
}

public protocol Expr: FaunaEncodable {
    
    func isEquals(other: Expr) -> Bool
}


extension Expr {
    
    public func isEquals(other: Expr) -> Bool {
        guard self.dynamicType == other.dynamicType else { return false }
        switch (self, other) {
        case (let exp1 as Obj, let exp2 as Obj):
            return exp1 == exp2
        case (let exp1 as Arr, let exp2 as Arr):
            return exp1 == exp2
        case (let exp1 as Ref, let exp2 as Ref):
            return exp1 == exp2
        case (let exp1 as Int, let exp2 as Int):
            return exp1 == exp2
        case (let exp1 as Double, let exp2 as Double):
            return exp1 == exp2
        case (let exp1 as String, let exp2 as String):
            return exp1 == exp2
        case (let exp1 as Timestamp, let exp2 as Timestamp):
            return exp1 == exp2
        case (let exp1 as Date, let exp2 as Date):
            return exp1 == exp2
        case  (let exp1 as Bool, let exp2 as Bool):
            return exp1 == exp2
        default:
            return false
        }
    }
}

extension Expr where Self: Encodable {
    
    public func toAnyObjectJSON() -> AnyObject {
        return toJSON() ?? [String: AnyObject]()
    }
}

