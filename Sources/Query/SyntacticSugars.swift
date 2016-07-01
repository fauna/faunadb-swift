//
//  SyntacticSugars.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation


extension CollectionType where Self.Generator.Element == Value {
    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Foreach(arr: arr, lambda: lambda)
    }
}

extension CollectionType where Self.Generator.Element: Value {
    
    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        var arr: Arr  = []
        forEach { arr.append($0) }
        return Foreach(arr: arr, lambda: lambda)
    }
}

extension CollectionType where Self.Generator.Element: ValueConvertible {
    
    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        var arr: Arr  = []
        forEach { arr.append($0.value) }
        return Map(arr: arr, lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        var arr: Arr  = []
        forEach { arr.append($0.value) }
        return Foreach(arr: arr, lambda: lambda)
    }
}