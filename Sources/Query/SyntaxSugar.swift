//
//  SyntaxSugar.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/14/16.
//
//

import Foundation


extension CollectionType where Self.Generator.Element == Value {
    public func mapFauna(@noescape lambda: ((Value) -> Expr)) -> Map {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Value) -> Expr)) -> Foreach {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Foreach(arr: arr, lambda: lambda)
    }
}

extension CollectionType where Self.Generator.Element: Value {
    
    public func mapFauna(@noescape lambda: ((Value) -> Expr)) -> Map {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Value) -> Expr)) -> Foreach {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Foreach(arr: arr, lambda: lambda)
    }
}