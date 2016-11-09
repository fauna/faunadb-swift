import Foundation

public protocol Expr {}

precedencegroup ExprTuplePrecedence {
    assignment: true
    associativity: left
    lowerThan: CastingPrecedence
}

infix operator => : ExprTuplePrecedence
public func => (key: String, value: Expr?) -> (String, Expr?) {
    return (key, value)
}

protocol Fn: Expr, AsJson, CustomStringConvertible {
    typealias Call = [String: Expr]
    var call: Call { get }
}

internal extension Fn {
    func escape() -> JsonType {
        return .object(call.mapValuesT(JSON.escape))
    }
}

extension Fn {
    public var description: String {
        return call.description
    }
}

internal func fn(_ pairs: (String, Expr?)...) -> Fn.Call {
    return Dictionary(pairs:
        pairs.flatMap { (key, value) in
            guard let value = value else { return nil }
            return (key, value)
        }
    )
}

internal func varargs(_ args: [Expr]) -> Expr {
    if args.count == 1 {
        return args.first!
    }

    return Arr(wrap: args)
}
