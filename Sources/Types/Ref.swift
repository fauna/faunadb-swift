//
//  Ref.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss

public struct Ref: ExprType {
    
    public static let databases: Ref = "databases"
    public static let indexes: Ref = "indexes"
    public static let classes: Ref = "classes"
    public static let keys: Ref = "keys"
    
    var ref: String
    
    public init(_ ref: String){
        self.ref = ref
    }
}

extension Ref: StringLiteralConvertible {
    
    public init(stringLiteral value: String){
        ref = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        ref = value
    }
    
    public init(unicodeScalarLiteral value: String){
        ref = value
    }
}


extension Ref: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String{
        return ref
    }
    
    public var debugDescription: String {
        return description
    }
}

extension Ref: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        return "@ref" ~~> ref
    }
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
    }
}

