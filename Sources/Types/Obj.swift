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
        var json = json
        if let objData = json["@obj"] as? [String: AnyObject] where json.count == 1 {
            json = objData
        }
        do {
            try json.forEach {  (key, value) throws in
                dictionary[key] = try Mapper.fromData(value)
            }
        }
        catch { return nil }
        self.dictionary = dictionary
    }
    
}

extension Obj: Encodable {
    
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

extension Obj: Equatable {}

public func ==(lhs: Obj, rhs: Obj) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (key, value) in lhs {
        guard let rValue = rhs[key] where value.isEquals(rValue) else {
            return false
        }
    }
    return true
}