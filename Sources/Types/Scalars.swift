//
//  Value.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss

extension Int: ScalarType{}

extension Int: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return self
    }
}

extension Float: ScalarType{}

extension Float: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return self
    }
}

extension Double: ScalarType{}

extension Double: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return self
    }
}

extension String: ScalarType{}

extension String: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return self
    }
}

extension Bool: ScalarType{}

extension Bool: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return self
    }
}

public struct Null: ScalarType {}

extension Null: NilLiteralConvertible{
    public init(nilLiteral: ()){}
}

extension Null: CustomDebugStringConvertible, CustomStringConvertible {
    
    public var description: String {
        return "null"
    }
    
    public var debugDescription: String {
        return description
    }
}

extension Null: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return NSNull()
    }
}
