//
//  Ref.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation

public struct Ref: Value{
    
    public static let databases: Ref = "databases"
    public static let indexes: Ref = "indexes"
    public static let classes: Ref = "classes"
    public static let keys: Ref = "keys"
    
    let ref: String
    
    public init(_ ref: String){
        self.ref = ref
    }
    
    init?(json: [String: AnyObject]){
        guard let ref = json["@ref"] as? String where json.count == 1 else { return nil }
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
        return "Ref(\(ref))"
    }
    
    public var debugDescription: String {
        return description
    }
}


extension Ref: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["@ref": ref.toJSON()]
    }
}

extension Ref: Equatable {}

public func ==(lhs: Ref, rhs: Ref) -> Bool {
    return lhs.ref == rhs.ref
}
