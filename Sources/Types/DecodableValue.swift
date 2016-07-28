//
//  DecodableValue.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//
import Foundation

public protocol DecodableValue {
    associatedtype DecodedType = Self
    static func decode(value: Value) -> DecodedType?
}

extension DecodableValue where Self: Value {
    public static func decode(value: Value) -> Self? {
        return value as? Self
    }
}
