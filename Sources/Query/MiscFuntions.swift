//
//  MiscFuntions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/13/16.
//
//

import Foundation
import Gloss

public struct Equals: Expr {
    let terms: [Value]
    
    init(terms: Value...){
        self.terms = terms
    }
}

extension Equals: Encodable {
    
    public func toJSON() -> JSON? {
        return ["equals": terms.map { $0.toAnyObjectJSON()} ]
    }
}
