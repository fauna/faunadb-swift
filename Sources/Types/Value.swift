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

    internal func isEquals(other: Value) -> Bool {

        switch (self, other) {
        case let (exp1 as Arr, exp2 as Arr):
            return exp1 == exp2
        case let (exp1 as Obj, exp2 as Obj):
            return exp1 == exp2
        case let (exp1 as Ref, exp2 as Ref):
            return exp1 == exp2
        case let (exp1 as Int, exp2 as Int):
            return exp1 == exp2
        case let (exp1 as Double, exp2 as Double):
            return exp1 == exp2
        case let (exp1 as String, exp2 as String):
            return exp1 == exp2
        case let (exp1 as Timestamp, exp2 as Timestamp):
            return exp1 == exp2
        case let (exp1 as Date, exp2 as Date):
            return exp1 == exp2
        case let (exp1 as Bool, exp2 as Bool):
            return exp1 == exp2
        case (_ as Null, _ as Null):
            return true
        default:
            return false
        }
    }
}
