//
//  Expr.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss


public protocol FaunaEncodable {
    func toAnyObjectJSON() -> AnyObject?
}

public protocol ExprType: FaunaEncodable {}
