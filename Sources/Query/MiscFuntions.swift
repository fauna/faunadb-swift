//
//  MiscFuntions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/13/16.
//
//

import Foundation

public struct Equals: Expr {
    let terms: [Value]
    
    init(terms: Value...){
        self.terms = terms
    }
}

extension Equals: Encodable {
    
    public func toJSON() -> AnyObject {
        return ["equals": terms.map { $0.toJSON()} ]
    }
}
