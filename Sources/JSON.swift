import Foundation

public enum JsonError: Error {
    case unsupportedType(Any)
    case invalidObjectKeyType(Any)
    case invalidLiteral(Any)
    case invalidDate(String)
}

extension JsonError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unsupportedType(let type):     return "Can not parse JSON type \"\(type)\""
        case .invalidObjectKeyType(let key): return "Invalid JSON object key \"\(key)\""
        case .invalidLiteral(let literal):   return "Invalid JSON literal \"\(literal)\""
        case .invalidDate(let string):       return "Invalid date \"\(string)\""
        }
    }
}

internal protocol AsJson {
    func escape() -> JsonType
}

internal enum JsonType {
    case object([String: JsonType])
    case array([JsonType])
    case string(String)
    case number(Int)
    case double(Double)
    case boolean(Bool)
    case null
}

internal struct JSON {

    static func data(value: Any) throws -> Data {
        return try escape(value: value).toData()
    }

    static func escape(value: Any) -> JsonType {
        guard let asJson = value as? AsJson else {
            fatalError(
                "Can not convert value <\(type(of: value)):\(value)> to JSON. " +
                "Custom implementations of Expr and Value protocols are supported."
            )
        }

        return asJson.escape()
    }

    static func parse(data: Data) throws -> Value {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return try JsonType.parse(json: json).toValue()
    }

}

fileprivate extension JsonType {

    static func parse(json: Any) throws -> JsonType {
        switch json {
        case let obj as NSDictionary: return try parse(object: obj)
        case let arr as NSArray:      return try .array(arr.map(parse))
        case let num as NSNumber:     return parse(number: num)
        case let string as String:    return .string(string)
        case is NSNull:               return .null
        default:                      throw JsonError.unsupportedType(json)
        }
    }

    private static func parse(object: NSDictionary) throws -> JsonType {
        let res: [String: JsonType] = Dictionary(pairs:
            try object.map {
                guard let key = $0.key as? String else { throw JsonError.invalidObjectKeyType($0.key) }
                return try (key, parse(json: $0.value))
            }
        )

        return .object(res)
    }

    private static func parse(number: NSNumber) -> JsonType {
        if number.isDoubleNumber() { return .double(number.doubleValue) }
        if number.isBoolNumber() { return .boolean(number.boolValue)  }
        return .number(number.intValue)
    }

}

fileprivate extension JsonType {

    func toData() throws -> Data {
        switch self {
        case .object, .array:  return try toData(json: unwrap())
        default:               return try toData(literal: unwrap())
        }
    }

    private func toData(json: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }

    private func toData(literal: Any) throws -> Data {
        let asString: String

        switch literal {
        case is String: asString = "\"\(literal)\""
        case is NSNull: asString = "null"
        default:        asString = "\(literal)"
        }

        guard let data = asString.data(using: .utf8) else {
            throw JsonError.invalidLiteral(literal)
        }

        return data
    }

    private func unwrap() -> Any {
        switch self {
        case .object(let obj):   return obj.mapValuesT { $0.unwrap() }
        case .array(let arr):    return arr.map { $0.unwrap() }
        case .string(let str):   return str
        case .number(let num):   return num
        case .double(let num):   return num
        case .boolean(let bool): return bool
        case .null:              return NSNull()
        }
    }

}

fileprivate extension JsonType {

    func toValue() throws -> Value {
        switch self {
        case .object(let obj):   return try toValue(special: obj)
        case .array(let arr):    return try ArrayV(arr.map { try $0.toValue() })
        case .string(let str):   return StringV(str)
        case .number(let num):   return LongV(num)
        case .double(let num):   return DoubleV(num)
        case .boolean(let bool): return BooleanV(bool)
        case .null:              return NullV()
        }
    }

    private func toValue(special: [String: JsonType]) throws -> Value {
        guard
            let key = special.first?.key,
            let value = special.first?.value
        else {
            return ObjectV([:])
        }

        switch (key, value) {
        case ("@ref", .string(let str)):  return RefV(str)
        case ("@set", .object(let obj)):  return try convert(to: SetRefV.init, object: obj)
        case ("@obj", .object(let obj)):  return try convert(to: ObjectV.init, object: obj)
        case ("@ts", .string(let str)):   return try convert(to: TimeV.init, time: str, as: ISO8601.time)
        case ("@date", .string(let str)): return try convert(to: DateV.init, time: str, as: ISO8601.date)
        default:                          return try convert(to: ObjectV.init, object: special)
        }
    }

    private func convert(to type: ([String: Value]) -> Value, object: [String: JsonType]) throws -> Value {
        return try type(
            object.mapValuesT { json in
                try json.toValue()
            }
        )
    }

    private func convert(to type: (Date) -> Value, time: String, as fn: (String) -> Date?) throws -> Value {
        guard let parsed = fn(time) else { throw JsonError.invalidDate(time) }
        return type(parsed)
    }

}
