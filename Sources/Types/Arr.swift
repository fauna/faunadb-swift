//
//  ArrayExpr.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/2/16.
//
//

import Foundation

public struct Arr: Value, ArrayLiteralConvertible {
    
    private var array = [Value]()
    
    public init(){}
    
    
    public init(_ elements: Value...){
        array = elements
    }
    
    public init(arrayLiteral elements: Value...){
        self.init(_: elements)
    }
    
    public init?(json: [AnyObject]) {
        guard let arr = try? json.map({ return try Mapper.fromData($0) }) else { return nil }
        array = arr
    }
}

extension Arr: Encodable {
    
    public func toJSON() -> AnyObject {
        return array.map { $0.toJSON() }
    }
}

extension Arr: MutableCollectionType {
    
    // MARK: MutableCollectionType
    
    public var startIndex: Int { return array.startIndex }
    public var endIndex: Int { return array.endIndex }
    public subscript (position: Int) -> Value {
        get { return array[position] }
        set { array[position] = newValue }
    }
}

extension Arr: RangeReplaceableCollectionType {
    
    // MARK: RangeReplaceableCollectionType
    
    public mutating func append(exp: Value){
        array.append(exp)
    }
    
    public mutating func appendContentsOf<S : SequenceType where S.Generator.Element == Value>(newExprs: S) {
        array.appendContentsOf(newExprs)
    }
    
    public mutating func reserveCapacity(n: Int){ array.reserveCapacity(n) }
    
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Value>(subRange: Range<Int>, with newExprs: C) {
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

extension Arr: Equatable {}

public func ==(lhs: Arr, rhs: Arr) -> Bool {
    guard lhs.count == rhs.count else { return false }
    var i1 = lhs.generate()
    var i2 = rhs.generate()
    while let e1 = i1.next(), e2 = i2.next() {
        guard e1.isEquals(e2) else { return false }
    }
    return true
}

