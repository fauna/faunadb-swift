//
//  Value.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

internal protocol Encodable {
    func toJSON() -> AnyObject
}

public protocol Value: Expr {}
public protocol ScalarValue: Value, DecodableValue {}

extension Value {
    
    public var value: Value { return self }
    
    public func isEquals(other: Value) -> Bool {
        
        switch (self, other) {
        case (let exp1 as Arr, let exp2 as Arr):
            return exp1 == exp2
        case (let exp1 as Obj, let exp2 as Obj):
            return exp1 == exp2
        case (let exp1 as Ref, let exp2 as Ref):
            return exp1 == exp2
        case (let exp1 as Int, let exp2 as Int):
            return exp1 == exp2
        case (let exp1 as Double, let exp2 as Double):
            return exp1 == exp2
        case (let exp1 as Float, let exp2 as Float):
            return exp1 == exp2
        case (let exp1 as String, let exp2 as String):
            return exp1 == exp2
        case (let exp1 as Timestamp, let exp2 as Timestamp):
            return exp1 == exp2
        case (let exp1 as Date, let exp2 as Date):
            return exp1 == exp2
        case  (let exp1 as Bool, let exp2 as Bool):
            return exp1 == exp2
        case ( _ as Null, _ as Null):
            return true
        default:
            return false
        }
    }
}

















