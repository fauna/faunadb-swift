//
//  Obj.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Obj: Value {
    
    var fn = false
    var dictionary = [String: Value]()
    
    public init(_ elements: [(String, Value)]){
        var dictionary = [String:Value]()
        elements.forEach { key, value in dictionary[key] = value }
        self.dictionary = dictionary
    }
    
    public init(_ elements: (String, Value)...){
        var dictionary = [String: Value]()
        elements.forEach { key, value in dictionary[key] = value }
        self.dictionary = dictionary
    }
    
    public init<V: Value>(_ dictionary: [String: V]){
        var res = [String: Value]()
        dictionary.forEach { k, v in res[k] = v }
        self.dictionary = res
    }
    
    public init(_ dictionary: [String: Value]){
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
    
    init(fnCall: [String: Value]){
        self.init(fnCall)
        fn = true
    }
}

extension Obj: Encodable {
    
    //MARK: Encodable
    
    func toJSON() -> AnyObject {
        var result = [String : AnyObject]()
        for keyValue in dictionary{
            result[keyValue.0] = keyValue.1.toJSON()
        }
        if !fn {
            result = ["object": result]
        }
        return result
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

extension Obj: DecodableValue {}

extension Obj: Equatable {}

public func ==(lhs: Obj, rhs: Obj) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (key, value) in lhs {
        guard let rValue = rhs[key] where value.isEquals(rValue) else { return false }
    }
    return true
}