//
//  SetRef.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct SetRef: ScalarValue {

    public let parameters: Value

    public init(_ value: Value){
        self.parameters = value
    }

    init?(json: [String: AnyObject]){
        guard let jsonData = json["@set"] where json.count == 1 else { return nil }
        guard let param = try? Mapper.fromData(jsonData) else { return nil }
        self.init(param)
    }
}

extension SetRef: Encodable {

    //MARK: Encodable

    func toJSON() -> AnyObject {
        return value.toJSON()
    }
}
