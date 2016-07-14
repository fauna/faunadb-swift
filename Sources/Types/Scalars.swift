//
//  Scalars.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

extension Int: ScalarValue{}
extension Int: Encodable {
    
    func toJSON() -> AnyObject {
        return self
    }
}

extension Float: ScalarValue{}
extension Float: Encodable {
    
    func toJSON() -> AnyObject {
        return self
    }
}

extension Double: ScalarValue{}
extension Double: Encodable {
    
    func toJSON() -> AnyObject {
        return self
    }
}

extension String: ScalarValue{}
extension String: Encodable {
    
    func toJSON() -> AnyObject {
        return self
    }
}

extension Bool: ScalarValue{}
extension Bool: Encodable {
    
    func toJSON() -> AnyObject {
        return self
    }
}

public struct Null: ScalarValue {
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
    
    //MARK: Encodable
    
    func toJSON() -> AnyObject {
        return NSNull()
    }
}

