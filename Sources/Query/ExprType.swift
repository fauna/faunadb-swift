//
//  Expr.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation


public protocol ExprConvertible {
    var value: Value { get }
}

public protocol Encodable {
    func toJSON() -> AnyObject
}


public protocol Expr: Encodable {
    func isEquals(other: Expr) -> Bool
}

extension Expr {

    public func isEquals(other: Expr) -> Bool {
        let leftExp: Expr = (self as? ValueConvertible)?.value ?? self
        let rightExp: Expr = (other as? ValueConvertible)?.value ?? self
        switch (leftExp, rightExp) {
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


extension CollectionType where Self.Generator.Element == Expr {
    
    var varArgsToAnyObject: AnyObject {
        switch  self.count {
        case 1:
            return self.first!.toJSON()
        default:
            return map { $0.toJSON() }
        }
    }
}
