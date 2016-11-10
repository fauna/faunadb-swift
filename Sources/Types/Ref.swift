//
//  Ref.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Ref: ScalarValue {

    let ref: String

    public init(_ ref: String){
        self.ref = ref
    }

    public init(ref: Ref, id: String){
        self.init("\(ref.ref)/\(id)")
    }

    init?(json: [String: AnyObject]){
        guard let ref = json["@ref"] as? String, json.count == 1 else { return nil }
        self.init(ref)
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

    //MARK: Encodable

    func toJSON() -> AnyObject {
        return ["@ref": ref.toJSON()] as AnyObject
    }
}

extension Ref: Equatable {}

public func ==(lhs: Ref, rhs: Ref) -> Bool {
    return lhs.ref == rhs.ref
}
