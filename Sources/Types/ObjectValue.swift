//
//  ObjectValue.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss

public struct Obj: ExprType, DictionaryLiteralConvertible {
    private var dictionary = [String: ExprType]()
    
    public init(dictionaryLiteral elements: (String, ExprType)...){
        var dictionary = [String:ExprType]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }
    
    public init(_ elements: (String, ExprType)...){
        var dictionary = [String:ExprType]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }
}

extension Obj: Encodable, FaunaEncodable {
    
    public func toJSON() -> JSON? {
        var result = [String : AnyObject]()
        for keyValue in dictionary{
            if let encodableItem = keyValue.1 as? Encodable {
                result[keyValue.0] = encodableItem.toJSON()
            }
            else if let anyObject = keyValue.1 as? AnyObject {
                result[keyValue.0] = anyObject
            }
        }
        return ["data": result]
    }
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
    }
}

extension Obj: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String{
        return "ObjectV(\(dictionary.map { "\($0.0): \($0.1)" }.joinWithSeparator(", ")))"
    }
    
    public var debugDescription: String{
        return description
    }
}

extension Obj: CollectionType {
    public typealias Element = (String, ExprType)
    public typealias Index = DictionaryIndex<String, ExprType>
    
    /// Create an empty dictionary.
    public init(){}

    public var startIndex: DictionaryIndex<String, ExprType> { return dictionary.startIndex }
    public var endIndex: DictionaryIndex<String, ExprType> { return dictionary.endIndex }
    public func indexForKey(key: String) -> DictionaryIndex<String, ExprType>? {
        return dictionary.indexForKey(key)
    }
    public subscript (position: DictionaryIndex<String, ExprType>) -> (String, ExprType) {
        return dictionary[position]
    }
    public subscript (key: String) -> ExprType? {
        return dictionary[key]
    }
    
    public mutating func updateValue(value: ExprType, forKey key: String) -> ExprType?{
        return dictionary.updateValue(value, forKey: key)
    }
    public mutating func removeAtIndex(index: DictionaryIndex<String, ExprType>) -> (String, ExprType) {
        return dictionary.removeAtIndex(index)
    }
    public mutating func removeValueForKey(key: String) -> ExprType?{
        return dictionary.removeValueForKey(key)
    }
    
    //    /// Create a dictionary with at least the given number of
    //    /// elements worth of storage.  The actual capacity will be the
    //    /// smallest power of 2 that's >= `minimumCapacity`.
    //    public init(minimumCapacity: Int)
    
    /// Removes all elements.
    ///
    /// - Postcondition: `capacity == 0` if `keepCapacity` is `false`, otherwise
    ///   the capacity will not be decreased.
    ///
    /// Invalidates all indices with respect to `self`.
    ///
    /// - parameter keepCapacity: If `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// Complexity: O(`self.count`).
//    public mutating func removeAll(keepCapacity keepCapacity: Bool = default)
    /// The number of entries in the dictionary.
    ///
    /// - Complexity: O(1).
//    public var count: Int { return }
    /// Returns a generator over the (key, value) pairs.
    ///
    /// - Complexity: O(1).
//    public func generate() -> DictionaryGenerator<Key, Value>
    /// Create an instance initialized with `elements`.
//    public init(dictionaryLiteral elements: (Key, Value)...)
    /// A collection containing just the keys of `self`.
    ///
    /// Keys appear in the same order as they occur as the `.0` member
    /// of key-value pairs in `self`.  Each key in the result has a
    /// unique value.
//    public var keys: LazyMapCollection<[Key : Value], Key> { get }
    /// A collection containing just the values of `self`.
    ///
    /// Values appear in the same order as they occur as the `.1` member
    /// of key-value pairs in `self`.
//    public var values: LazyMapCollection<[Key : Value], Value> { get }
    /// `true` iff `count == 0`.
//    public var isEmpty: Bool { get }
    
    
    
}