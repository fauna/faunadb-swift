//
//  TimeAndDateFuntions.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation



public struct Time: Expr {

    public var value: Value
    
    /**
     * `Time` constructs a time special type from an ISO 8601 offset date/time string. The special string “now” may be used to construct a time from the current request’s transaction time. Multiple references to “now” within the same query will be equal.
     
     - parameter expr: ISO8601 offset date/time string, "now" can be used to create current request evaluation time.
     
     - returns: A time exoression.
     */
    public init(_ expr: Expr){
        value = Obj(fnCall: ["time": expr.value])
    }
}


public enum TimeUnit: String {
    case second = "second"
    case millisecond = "millisecond"
    case microsecond = "microsecond"
    case nanosecond = "nanosecond"
}


public struct Epoch: Expr {
    
    public var value: Value
    
    /**
     `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”, “microsecond”, “nanosecond”.
     
     - parameter offset: number relative to the epoch.
     - parameter unit:   offset unit.
     
     - returns: A Epoch expression.
     */
    public init(offset: Expr, unit: TimeUnit){
        self.init(offset: offset, unit: unit.rawValue)
    }


    /**
     `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”, “microsecond”, “nanosecond”.
     
     - parameter offset: number relative to the epoch.
     - parameter unit:   offset unit.
     
     - returns: A Epoch expression.
     */

    public init(offset: Expr, unit: Expr) {
        value = Obj(fnCall: ["epoch": offset.value, "unit": unit.value])
    }
}

public struct DateFn: Expr {

    public var value: Value
    
    /**
     * `Date` constructs a date special type from an ISO 8601 date string.
     */
    public init(iso8601: String){
        value = Obj(fnCall:["date": iso8601])
    }
    
}
