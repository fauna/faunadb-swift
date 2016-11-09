import Foundation

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

public struct Ref: Fn {

    var call: Fn.Call

    public init(_ id: String) {
        self.call = fn("@ref" => id)
    }

    public init(class: Expr, id: Expr) {
        self.call = fn("ref" => `class`, "id" => id)
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
        return TimeV(self).escape()
    }
}
