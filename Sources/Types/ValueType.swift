//
//  ValueType.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/3/16.
//
//

import Foundation

public protocol ValueType: ExprType {}

extension ValueType {
    
    func isEquals(other: ValueType) -> Bool{
        return false
    }
}