//
//  Arr.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Arr: Value {

    fileprivate var array = [ValueConvertible]()

    public init(){}

    init?(json: [AnyObject]) {
        guard let arr = try? json.map({ return try Mapper.fromData($0) as ValueConvertible }) else { return nil }
        array = arr
    }

    public init<C: Sequence>(_ sequence: C) where C.Iterator.Element: ValueConvertible{
        self.init()
        array.append(contentsOf: sequence.map { $0 as ValueConvertible})
    }

    public init(_ elements: ValueConvertible...){
        self.init(elements)
    }
}

extension Arr: Encodable {

    //MARK: Encodable

    func toJSON() -> AnyObject {
        return array.map { $0.toJSON() }
    }
}

extension Arr: MutableCollection {

    // MARK: MutableCollectionType

    public var startIndex: Int { return array.startIndex }
    public var endIndex: Int { return array.endIndex }
    public subscript (position: Int) -> ValueConvertible {
        get { return array[position] }
        set { array[position] = newValue }
    }
}

extension Arr: RangeReplaceableCollection {

    // MARK: RangeReplaceableCollectionType

    public mutating func append(_ exp: Value){
        array.append(exp)
    }

    public mutating func append<S : Sequence>(contentsOf newExprs: S) where S.Iterator.Element == ValueConvertible {
        array.append(contentsOf: newExprs)
    }

    public mutating func reserveCapacity(_ n: Int){ array.reserveCapacity(n) }

    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newExprs: C) where C.Iterator.Element == ValueConvertible {
        array.replaceSubrange(subRange, with: newExprs)
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        array.removeAll(keepingCapacity: keepCapacity)
    }
}

extension Arr: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String{
        return "Arr(\(array.map { String(describing: $0) }.joined(separator: ", ")))"
    }

    public var debugDescription: String {
        return description
    }
}

extension Arr: DecodableValue {}

extension Arr: Equatable {}

public func ==(lhs: Arr, rhs: Arr) -> Bool {
    guard lhs.count == rhs.count else { return false }
    var i1 = lhs.makeIterator()
    var i2 = rhs.makeIterator()
    while let e1 = i1.next(), let e2 = i2.next() {
        guard e1.value.isEquals(e2.value) else { return false }
    }
    return true
}
