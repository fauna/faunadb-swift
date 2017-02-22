import Foundation

/**
    `Decodable` protocol is used to specify how a FaunaDB value returned
    by the server is converted to other Swift data structures.

    For example:

        struct Point { let x, y: Int }

        extension Point: Decodable {
            init?(value: Value) throws {
                try self.init(
                    x: value.get("data", "position", "x") ?? 0
                    y: value.get("data", "position", "y") ?? 0
            }
        }

        //...

        let point: Point? = databaseValue.get()

    Documentation describing data conversion can be found in the
    `FaunaDB.Field` struct.
*/
public protocol Decodable {
    init?(value: Value) throws
}

internal let defaultCodec: Codec = SupportedTypesCodec()

internal protocol Codec {
    func decode<T>(value: Value) throws -> T?
}

extension Codec {
    func cast<Expected, Actual>(_ current: Actual) throws -> Expected? {
        guard let res = current as? Expected else {
            throw DecodeError(expected: Expected.self, actual: Actual.self)
        }

        return res
    }
}

fileprivate struct DecodeError<Expected, Actual>: Error {
    let expected: Expected.Type
    let actual: Actual.Type
}

extension DecodeError: CustomStringConvertible {
    var description: String {
        return
            "Can not decode value of type \"\(actual)\" to desired type \"\(expected)\". " +
            "You can implement the Decodable protocol if you want to create custom data convertions."
    }
}

fileprivate struct SupportedTypesCodec: Codec {

    func decode<T>(value: Value) throws -> T? {
        guard !(value is NullV) else { return nil }

        if let decodable = T.self as? Decodable.Type {
            guard let decoded = try decodable.init(value: value) else { return nil }
            return try cast(decoded)
        }

        return try decodeValue(value)
    }

    private func decodeValue<T>(_ value: Value) throws -> T? {
        if let coerced = value as? T {
            return coerced
        }

        switch value {
        case let str as StringV:   return try cast(str.value)
        case let num as LongV:     return try cast(num.value)
        case let num as DoubleV:   return try cast(num.value)
        case let bool as BooleanV: return try cast(bool.value)
        case let date as DateV:    return try cast(date.value)
        case let ts as TimeV:      return try castHighPrecisionTime(ts.value)
        case let bytes as BytesV:  return try cast(bytes.value)
        default:                   return try cast(value)
        }
    }

    private func castHighPrecisionTime<T>(_ ts: HighPrecisionTime) throws -> T? {
        if T.self == Date.self {
            return try cast(ts.toDate())
        }

        return try cast(ts)
    }

}
