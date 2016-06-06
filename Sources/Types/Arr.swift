//
//  ArrayExpr.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/2/16.
//
//

import Foundation
import Gloss

public struct Arr: ValueType, ArrayLiteralConvertible {
    
    private var array = [ExprType]()
    
    public init(){}
    
    public init(arrayLiteral elements: ExprType...){
        var array = [ExprType]()
        elements.forEach { array.append($0) }
        self.array = array
    }
    
    init(rawArray: [AnyObject]) {
        
    }
}

extension Arr: FaunaEncodable {
    
    public func toAnyObjectJSON() -> AnyObject? {
        return array.map { $0.toAnyObjectJSON()  ?? NSNull() }
    }
}

extension Arr: MutableCollectionType {
    
    // MARK: MutableCollectionType
    
    public var startIndex: Int { return array.startIndex }
    public var endIndex: Int { return array.endIndex }
    public subscript (position: Int) -> ExprType {
        get { return array[position] }
        set { array[position] = newValue }
    }
}

extension Arr: RangeReplaceableCollectionType {
    
    // MARK: RangeReplaceableCollectionType
    
    public mutating func append(exp: ExprType){
        array.append(exp)
    }
    
    public mutating func appendContentsOf<S : SequenceType where S.Generator.Element == ExprType>(newExprs: S) {
        array.appendContentsOf(newExprs)
    }
    
    public mutating func reserveCapacity(n: Int){ array.reserveCapacity(n) }
    
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == ExprType>(subRange: Range<Int>, with newExprs: C) {
        array.replaceRange(subRange, with: newExprs)
    }
    
    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        array.removeAll(keepCapacity: keepCapacity)
    }
}

extension Arr: CustomStringConvertible, CustomDebugStringConvertible {
    
    
    public var description: String{
        return "Arr(\(array.map { String($0) }.joinWithSeparator(", ")))"
    }
    
    public var debugDescription: String {
        return description
    }
}

