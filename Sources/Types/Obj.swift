//
//  Obj.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct Obj: Value {

    var fn = false
    var dictionary = [String: ValueConvertible]()

    public init(_ elements: [(String, ValueConvertible)]){
        var dictionary = [String:ValueConvertible]()
        elements.forEach { key, value in dictionary[key] = value }
        self.dictionary = dictionary
    }

    public init(_ elements: (String, ValueConvertible)...){
        var dictionary = [String: ValueConvertible]()
        elements.forEach { key, value in dictionary[key] = value }
        self.dictionary = dictionary
    }

    public init<V: ValueConvertible>(_ dictionary: [String: V]){
        var res = [String: ValueConvertible]()
        dictionary.forEach { k, v in res[k] = v }
        self.dictionary = res
    }

    public init(_ dictionary: [String: ValueConvertible]){
        self.dictionary = dictionary
    }

    init?(json: [String: AnyObject]){
        var dictionary = [String: ValueConvertible]()
        var json = json
        if let objData = json["@obj"] as? [String: AnyObject], json.count == 1 {
            json = objData
        }
        do {
            try json.forEach {  (key, value) throws in
                dictionary[key] = try Mapper.fromData(value) as ValueConvertible
            }
        }
        catch { return nil }
        self.dictionary = dictionary
    }

    init(fnCall: [String: ValueConvertible]){
        self.init(fnCall)
        fn = true
    }
}

extension Obj: Encodable {

    //MARK: Encodable

    func toJSON() -> AnyObject {
        var result = [String : AnyObject]()
        for keyValue in dictionary {
            result[keyValue.0] = keyValue.1.toJSON()
        }
        if !fn {
            result = ["object": result as AnyObject]
        }
        return result as AnyObject
    }
}

extension Obj: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String{
        return "Obj(\(dictionary.map { "\($0.0): \($0.1)" }.joined(separator: ", ")))"
    }

    public var debugDescription: String{
        return description
    }
}

extension Obj: Collection {
    public typealias Element = (String, ValueConvertible)
    public typealias Index = DictionaryIndex<String, ValueConvertible>

    /// Create an empty dictionary.
    public init(){}

    public var startIndex: Index { return dictionary.startIndex }
    public var endIndex: Index { return dictionary.endIndex }
    public func indexForKey(_ key: String) -> Index? {
        return dictionary.index(forKey: key)
    }
    public subscript (position: Index) -> Element {
        return dictionary[position]
    }
    public subscript (key: String) -> ValueConvertible? {
        get{ return dictionary[key] }
        set(newValue) { dictionary[key] = newValue }
    }

    public mutating func updateValue(_ value: ValueConvertible, forKey key: String) -> ValueConvertible?{
        return dictionary.updateValue(value, forKey: key)
    }
    public mutating func removeAtIndex(_ index: Index) -> Element {
        return dictionary.remove(at: index)
    }
    public mutating func removeValueForKey(_ key: String) -> ValueConvertible?{
        return dictionary.removeValue(forKey: key)
    }
}

extension Obj: DecodableValue {}

extension Obj: Equatable {}

public func ==(lhs: Obj, rhs: Obj) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (key, value) in lhs {
        guard let rValue = rhs[key], value.value.isEquals(rValue.value) else { return false }
    }
    return true
}
