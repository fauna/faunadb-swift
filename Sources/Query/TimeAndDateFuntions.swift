//
//  TimeAndDateFuntions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 7/8/16.
//
//

import Foundation

/**
 * `Time` constructs a time special type from an ISO 8601 offset date/time string. The special string “now” may be used to construct a time from the current request’s transaction time. Multiple references to “now” within the same query will be equal.
 
 - parameter expr: ISO8601 offset date/time string, "now" can be used to create current request evaluation time.
 
 - returns: A time exoression.
 */
public func Time(expr: Expr) -> Expr{
    return Expr(fn(Obj(("time", expr.value))))
}


public enum TimeUnit: String {
    case second = "second"
    case millisecond = "millisecond"
    case microsecond = "microsecond"
    case nanosecond = "nanosecond"
}


/**
 `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”, “microsecond”, “nanosecond”.
 
 - parameter offset: number relative to the epoch.
 - parameter unit:   offset unit.
 
 - returns: A Epoch expression.
 */
public func Epoch(offset offset: Expr, unit: TimeUnit) -> Expr {
    return Epoch(offset: offset, unit: Expr(unit.rawValue));
}


/**
 `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”, “microsecond”, “nanosecond”.
 
 - parameter offset: number relative to the epoch.
 - parameter unit:   offset unit.
 
 - returns: A Epoch expression.
 */

public func Epoch(offset offset: Expr, unit: Expr) -> Expr {
     return Expr(fn(["epoch": offset.value, "unit": unit.value]));
}

/**
 * `Date` constructs a date special type from an ISO 8601 date string.
 */
public func DateFn(iso8601 iso8601: String) -> Expr {
    return Expr(fn(["date": iso8601]));
}
