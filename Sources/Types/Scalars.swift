//
//  Value.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation

extension Int: ScalarType{}

extension Int: Encodable {
    
    public func toJSON() -> AnyObject {
        return self
    }
}

extension Double: ScalarType{}

extension Double: Encodable {
    
    public func toJSON() -> AnyObject {
        return self
    }
}

extension String: ScalarType{}

extension String: Encodable {
    
    public func toJSON() -> AnyObject {
        return self
    }
}

extension Bool: ScalarType{}

extension Bool: Encodable {
    
    public func toJSON() -> AnyObject {
        return self
    }
}

public struct Null: ScalarType {
    
    public init(){}
}

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

extension Null: Encodable {
    
    public func toJSON() -> AnyObject {
        return NSNull()
    }
}
