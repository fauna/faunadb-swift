import Foundation

public struct Time: Fn {

    var call: Fn.Call

    /**
     `Time` constructs a time special type from an ISO 8601 offset date/time string. The special string “now” may be used to construct a time from the current request’s transaction time. Multiple references to “now” within the same query will be equal.

     [Reference](https://faunadb.com/documentation/queries#time_functions)

     - parameter expr: ISO8601 offset date/time string, "now" can be used to create current request evaluation time.

     - returns: A time expression.
     */
    public init(fromString string: Expr) {
        self.call = fn("time" => string)
    }

}

public enum TimeUnit: String {
    case second = "second"
    case millisecond = "millisecond"
}

extension TimeUnit: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self.rawValue)
    }
}

public struct Epoch: Fn {

    var call: Fn.Call

    /**
     `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”.

     [Reference](https://faunadb.com/documentation/queries#time_functions)

     - parameter offset: number relative to the epoch.
     - parameter unit:   offset unit.

     - returns: A Epoch expression.
     */
    public init(_ offset: Expr, _ unit: Expr) {
        self.call = fn("epoch" => offset, "unit" => unit)
    }

    /**
     `Epoch` constructs a time special type relative to the epoch (1970-01-01T00:00:00Z). num must be an integer type. unit may be one of the following: “second”, “millisecond”.

     [Reference](https://faunadb.com/documentation/queries#time_functions)

     - parameter offset: number relative to the epoch.
     - parameter unit:   offset unit.

     - returns: A Epoch expression.
     */
    public init(offset: Expr, unit: TimeUnit) {
        self.init(offset, unit)
    }

}

public struct DateFn: Fn {

    var call: Fn.Call

    /**
     `Date` constructs a date special type from an ISO 8601 date string.

     [Reference](https://faunadb.com/documentation/queries#time_functions)
     */
    public init(string: String) {
        self.call = fn("date" => string)
    }

}
