//
//  CollectionFunctions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/14/16.
//
//

import Foundation

protocol CollectionFunctionType: FunctionType {}

public struct Drop: CollectionFunctionType {
    let drop: Int
    let collection: Expr
    
    init(_ drop: Int, collection: Expr){
        self.drop = drop
        self.collection = collection
    }
    
    init<C: CollectionType where C.Generator.Element == Value>(_ take: Int, arr: C){
        let expr = Arr(arr)
        self.init(take, collection: expr)
    }
    
    init<C: CollectionType where C.Generator.Element: Value>(_ take: Int, arr: C){
        var expr: Arr = Arr()
        arr.forEach { expr.append($0) }
        self.init(take, collection: expr)
    }
}

extension Drop: Encodable {
    public func toJSON() -> AnyObject {
        return ["drop": drop.toJSON(), "collection": collection.toJSON()]
    }
}

public struct Take: CollectionFunctionType{
    
    let take: Int
    let collection: Expr
    
    init(_ take: Int, collection: Expr){
        self.take = take
        self.collection = collection
    }
    
    init<C: CollectionType where C.Generator.Element == Value>(_ take: Int, arr: C){
        let expr = Arr(arr)
        self.init(take, collection: expr)
    }
    
    init<C: CollectionType where C.Generator.Element: Value>(_ take: Int, arr: C){
        var expr: Arr = Arr()
        arr.forEach { expr.append($0) }
        self.init(take, collection: expr)
    }
}

extension Take: Encodable {
    public func toJSON() -> AnyObject {
        return ["take": take.toJSON(), "collection": collection.toJSON()]
    }
}


public struct Prepend: CollectionFunctionType{
    
    let elements: Expr
    let collection: Expr
    
    init(_ elements: Expr, toCollection collection: Expr){
        self.elements = elements
        self.collection = collection
    }
}

extension Prepend: Encodable {
    public func toJSON() -> AnyObject {
        return ["collection": elements.toJSON(), "prepend": collection.toJSON()]
    }
}

public struct Append: CollectionFunctionType{
    
    let elements: Expr
    let collection: Expr
    
    init(_ elements: Expr, toCollection collection: Expr){
        self.elements = elements
        self.collection = collection
    }
}

extension Append: Encodable {
    public func toJSON() -> AnyObject {
        return ["collection": elements.toJSON(), "append": collection.toJSON()]
    }
}
