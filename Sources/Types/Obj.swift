//
//  ObjectValue.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/1/16.
//
//

import Foundation

public struct Obj: Value, DictionaryLiteralConvertible {
    
    private var dictionary = [String: Value]()
    
    
    public init(_ elements: [(String, Value)]){
        var dictionary = [String:Value]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }

    
    public init(dictionaryLiteral elements: (String, Value)...){
        var dictionary = [String: Value]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }
    
    public init(_ elements: (String, Value)...){
        var dictionary = [String:Value]()
        elements.forEach { dictionary[$0.0] = $0.1 }
        self.dictionary = dictionary
    }
    
    init?(json: [String: AnyObject]){
        var dictionary = [String:Value]()
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
    
    public func toJSON() -> AnyObject {
        var result = [String : AnyObject]()
        for keyValue in dictionary{
            result[keyValue.0] = keyValue.1.toJSON()
        }
        return ["object": result]
    }
}

extension Obj: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String{
        return "Obj(\(dictionary.map { "\($0.0): \($0.1)" }.joinWithSeparator(", ")))"
    }
    
    public var debugDescription: String{
        return description
    }
}

extension Obj: CollectionType {
    public typealias Element = (String, Value)
    public typealias Index = DictionaryIndex<String, Value>
    
    /// Create an empty dictionary.
    public init(){}

    public var startIndex: DictionaryIndex<String, Value> { return dictionary.startIndex }
    public var endIndex: DictionaryIndex<String, Value> { return dictionary.endIndex }
    public func indexForKey(key: String) -> DictionaryIndex<String, Value>? {
        return dictionary.indexForKey(key)
    }
    public subscript (position: DictionaryIndex<String, Value>) -> (String, Value) {
        return dictionary[position]
    }
    public subscript (key: String) -> Value? {
        get{ return dictionary[key] }
        set(newValue) { dictionary[key] = newValue }
    }
    
    public mutating func updateValue(value: Value, forKey key: String) -> Value?{
        return dictionary.updateValue(value, forKey: key)
    }
    public mutating func removeAtIndex(index: DictionaryIndex<String, Value>) -> (String, Value) {
        return dictionary.removeAtIndex(index)
    }
    public mutating func removeValueForKey(key: String) -> Value?{
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

extension Dictionary: ValueConvertible {
    
    public var value: FaunaDB.Value {
        let content: [(String, FaunaDB.Value)] =
                    self
                    .map { k, v in
                        let key = k as! String
                        let value = (v as? FaunaDB.Value) ?? (v as? ValueConvertible)?.value ?? (v as! NSObject).value()
                        return (key, value)
                    }
        
        return Obj(content)
    }
}
