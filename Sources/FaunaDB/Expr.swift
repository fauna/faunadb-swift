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

public struct Obj: Expr, AsJson, CustomStringConvertible {

    private let wrapped: [String: Expr?]

    public var description: String {
        return wrapped.description
    }

    public init(wrap: [String: Expr?]) {
        self.wrapped = wrap
    }

    public init(_ pairs: (String, Expr?)...) {
        self.wrapped = Dictionary(pairs: pairs)
    }

    func escape() -> JsonType {
        return .object([
            "object": .object(wrapped.mapValuesT(JSON.escape))
        ])
    }

}

public struct Arr: Expr, AsJson, CustomStringConvertible {

    private let wrapped: [Expr?]

    public var description: String {
        return wrapped.description
    }

    public init(_ elements: Expr?...) {
        self.wrapped = elements
    }

    public init(wrap: [Expr?]) {
        self.wrapped = wrap
    }

    func escape() -> JsonType {
        return .array(wrapped.map(JSON.escape))
    }

}

extension String: Expr, AsJson {
    func escape() -> JsonType {
        return .string(self)
    }
}

extension Int: Expr, AsJson {
    func escape() -> JsonType {
        return .number(self)
    }
}

extension Double: Expr, AsJson {
    func escape() -> JsonType {
        return .double(self)
    }
}

extension Bool: Expr, AsJson {
    func escape() -> JsonType {
        return .boolean(self)
    }
}

extension Optional: Expr, AsJson {
    func escape() -> JsonType {
        switch self {
        case .some(let value): return JSON.escape(value: value)
        case .none           : return .null
        }
    }
}

extension Date: Expr, AsJson {
    func escape() -> JsonType {
        return TimeV(date: self).escape()
    }
}

extension HighPrecisionTime: Expr, AsJson {
    func escape() -> JsonType {
        return TimeV(self).escape()
    }
}
