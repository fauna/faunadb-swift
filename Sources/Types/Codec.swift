import Foundation

internal let defaultCodec: Codec = NativeTypesCodec()

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
        return "Can not decode value of type \"\(actual)\" to desired type \"\(expected)\""
    }
}

fileprivate struct NativeTypesCodec: Codec {

    func decode<T>(value: Value) throws -> T? {
        if let coerced = value as? T {
            return coerced
        }

        switch value {
        case is NullV:             return nil
        case let str as StringV:   return try cast(str.value)
        case let num as LongV:     return try cast(num.value)
        case let num as DoubleV:   return try cast(num.value)
        case let bool as BooleanV: return try cast(bool.value)
        case let ts as TimeV:      return try cast(ts.value)
        case let date as DateV:    return try cast(date.value)
        default:                   return try cast(value)
        }
    }

}
