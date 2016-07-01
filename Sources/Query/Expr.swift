//
//  Expr.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Expr: ValueConvertible, Encodable {
    
    public var value: FaunaDB.Value
    
    public init(_ value: FaunaDB.ValueConvertible) {
        self.value = value.value
    }
}

extension Expr: StringLiteralConvertible {
    public init(stringLiteral value: String){
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Expr: BooleanLiteralConvertible {
    
    public init(booleanLiteral value: Bool){
        self.init(value)
    }
}

extension Expr: IntegerLiteralConvertible {
    
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Expr: NilLiteralConvertible {
    
    public init(nilLiteral: ()) {
        self.init(nil as Null)
    }
}

extension Expr: FloatLiteralConvertible {

    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension Expr: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Expr...) {
        self.init(Arr(elements.map { $0.value }))
    }
}

extension Expr: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, Expr)...) {
        let inner = Obj(elements.map { k, v in (k, v.value) })
        self.init(inner)
    }
}

