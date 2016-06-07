//
//  ObjectValue.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation
import Gloss

public struct Obj: ValueType, DictionaryLiteralConvertible {
    private var dictionary = [String: ValueType]()
    
    public init(dictionaryLiteral elements: (String, ValueType)...){
        var dictionary = [String:ValueType]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }
    
    public init(_ elements: (String, ValueType)...){
        var dictionary = [String:ValueType]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }
    
    public init?(json: JSON){
        var dictionary = [String:ValueType]()
        json.forEach({ (key, value) in
            switch value {
            case let dicValue as [String: AnyObject]:
                if dicValue.count == 1 && key == "@ref" {
                    let ref: Ref = (key <~~ dicValue)!
                    dictionary[key] = ref
                }
                break
            case let strValue as String:
                dictionary[key] = strValue
            case let doubleValue as Double:
                dictionary[key] = doubleValue
            case let intValue as Int:
                dictionary[key] = intValue
            case let boolValue as Bool:
                dictionary[key] = boolValue
            case let arrayValue as [AnyObject]:
                dictionary[key] = Arr(rawArray: arrayValue)
            default:
                break
            }
        })
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
        return ["object": result]
    }
    
    public func toAnyObjectJSON() -> AnyObject? {
        return toJSON()
    }
}

extension Obj: Decodable {}

extension Obj: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String{
        return "Obj(\(dictionary.map { "\($0.0): \($0.1)" }.joinWithSeparator(", ")))"
    }
    
    public var debugDescription: String{
        return description
    }
}

extension Obj: CollectionType {
    public typealias Element = (String, ValueType)
    public typealias Index = DictionaryIndex<String, ValueType>
    
    /// Create an empty dictionary.
    public init(){}

    public var startIndex: DictionaryIndex<String, ValueType> { return dictionary.startIndex }
    public var endIndex: DictionaryIndex<String, ValueType> { return dictionary.endIndex }
    public func indexForKey(key: String) -> DictionaryIndex<String, ValueType>? {
        return dictionary.indexForKey(key)
    }
    public subscript (position: DictionaryIndex<String, ValueType>) -> (String, ValueType) {
        return dictionary[position]
    }
    public subscript (key: String) -> ValueType? {
        return dictionary[key]
    }
    
    public mutating func updateValue(value: ValueType, forKey key: String) -> ValueType?{
        return dictionary.updateValue(value, forKey: key)
    }
    public mutating func removeAtIndex(index: DictionaryIndex<String, ValueType>) -> (String, ValueType) {
        return dictionary.removeAtIndex(index)
    }
    public mutating func removeValueForKey(key: String) -> ValueType?{
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