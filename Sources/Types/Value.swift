import Foundation

public protocol Value: Expr, CustomStringConvertible {}

public protocol ScalarValue: Value, Equatable {
    associatedtype Wrapped
    var value: Wrapped { get }
}

public func ==<S: ScalarValue>(left: S, right: S) -> Bool where S.Wrapped: Equatable {
    return left.value == right.value
}

extension CustomStringConvertible where Self: ScalarValue, Self.Wrapped: CustomStringConvertible {
    public var description: String {
        return value.description
    }
}

public struct StringV: ScalarValue, AsJson {

    public var value: String

    public init(_ value: String) {
        self.value = value
    }

    func escape() -> JsonType {
        return .string(value)
    }
}

public struct LongV: ScalarValue, AsJson {

    public var value: Int

    public init(_ value: Int) {
        self.value = value
    }

    func escape() -> JsonType {
        return .number(value)
    }
}

public struct DoubleV: ScalarValue, AsJson {

    public var value: Double

    public init(_ value: Double) {
        self.value = value
    }

    func escape() -> JsonType {
        return .double(value)
    }
}

public struct BooleanV: ScalarValue, AsJson {

    public var value: Bool

    public init(_ value: Bool) {
        self.value = value
    }

    func escape() -> JsonType {
        return .boolean(value)
    }
}

public struct TimeV: ScalarValue, AsJson {

    public var value: Date

    public init(_ value: Date) {
        self.value = value
    }

    func escape() -> JsonType {
        return .object([
            "@ts": .string(ISO8601.stringify(time: value))
        ])
    }
}

public struct DateV: ScalarValue, AsJson {

    public var value: Date

    public init(_ value: Date) {
        self.value = value
    }

    func escape() -> JsonType {
        return .object([
            "@date": .string(ISO8601.stringify(date: value))
        ])
    }
}

public struct RefV: ScalarValue, AsJson {

    public var value: String

    public init(_ value: String) {
        self.value = value
    }

    func escape() -> JsonType {
        return .object(["@ref": .string(value)])
    }
}

public struct SetRefV: ScalarValue, AsJson {

    public var value: [String: Value]

    public init(_ value: [String: Value]) {
        self.value = value
    }

    func escape() -> JsonType {
        return escapeObject(with: "@set", object: value)
    }
}

extension SetRefV: Equatable {
    public static func == (left: SetRefV, right: SetRefV) -> Bool {
        return left.value == right.value
    }
}

public struct NullV: Value, AsJson {

    public let description: String = "null"

    public init() {}

    func escape() -> JsonType {
        return .null
    }
}

extension NullV: Equatable {
    public static func == (left: NullV, right: NullV) -> Bool {
        return true
    }
}

public struct ArrayV: Value, AsJson {

    public let value: [Value]

    public var description: String {
        return value.description
    }

    public init(_ elements: [Value]) {
        self.value = elements
    }

    func escape() -> JsonType {
        return .array(value.map(JSON.escape))
    }
}

extension ArrayV: Equatable {
    public static func == (left: ArrayV, right: ArrayV) -> Bool {
        return left.value == right.value
    }
}

public struct ObjectV: Value, AsJson {

    public let value: [String: Value]

    public var description: String {
        return value.description
    }

    public init(_ pairs: [String: Value]) {
        self.value = pairs
    }

    func escape() -> JsonType {
        return escapeObject(with: "object", object: value)
    }
}

extension ObjectV: Equatable {
    public static func == (left: ObjectV, right: ObjectV) -> Bool {
        return left.value == right.value
    }
}

fileprivate func escapeObject(with: String, object: [String: Value]) -> JsonType {
    return .object([
        with: .object(object.mapValuesT(JSON.escape))
    ])
}

// swiftlint:disable cyclomatic_complexity
fileprivate func == (left: Value, right: Value) -> Bool {
    switch (left, right) {
    case (let left, let right) as (ObjectV, ObjectV):   return left == right
    case (let left, let right) as (ArrayV, ArrayV):     return left == right
    case (let left, let right) as (StringV, StringV):   return left == right
    case (let left, let right) as (LongV, LongV):       return left == right
    case (let left, let right) as (DoubleV, DoubleV):   return left == right
    case (let left, let right) as (BooleanV, BooleanV): return left == right
    case (let left, let right) as (RefV, RefV):         return left == right
    case (let left, let right) as (SetRefV, SetRefV):   return left == right
    case (let left, let right) as (DateV, TimeV):       return left == right
    case is (NullV, NullV):                             return true
    default:                                            return false
    }
}

fileprivate func != (left: Value, right: Value) -> Bool {
    return !(left == right)
}

fileprivate func == (left: [String: Value], right: [String: Value]) -> Bool {
    guard left.count == right.count else { return false }
    if left.count == 0 { return true }

    return left.contains(where: { leftKey, leftValue in
        guard let rightValue = right[leftKey] else { return true }
        return leftValue != rightValue
    })
}

fileprivate func == (left: [Value], right: [Value]) -> Bool {
    guard left.count == right.count else { return false }
    if left.count == 0 { return true }

    return left.contains(where: { leftElement in
        right.contains(where: { rightElement in
            leftElement != rightElement
        })
    })
}
