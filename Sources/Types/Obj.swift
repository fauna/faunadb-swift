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
            case _ as NSNull:
                dictionary[key] = Null()
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
            result[keyValue.0] = keyValue.1.toAnyObjectJSON()
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
        get{ return dictionary[key] }
        set(newValue) { dictionary[key] = newValue }
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
}