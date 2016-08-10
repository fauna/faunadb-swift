//
//  SyntacticSugars.swift
//  Example
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import FaunaDB
import Foundation

extension SequenceType where Self.Generator.Element: ValueConvertible {

    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Map {
        return Map(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Foreach {
        return Foreach(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Filter {
        return Filter(collection: Arr(map { $0 }), lambda: lambda)
    }
}

extension SequenceType where Self.Generator.Element == Value {

    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Map {
        return Map(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Foreach {
        return Foreach(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Filter {
        return Filter(collection: Arr(map { $0 }), lambda: lambda)
    }
}

extension SequenceType where Self.Generator.Element == ValueConvertible {

    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Map {
        return Map(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Foreach {
        return Foreach(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Filter {
        return Filter(collection: Arr(map { $0 }), lambda: lambda)
    }
}

extension SequenceType where Self.Generator.Element == Expr {

    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Map {
        return Map(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Foreach {
        return Foreach(collection: Arr(map { $0 }), lambda: lambda)
    }

    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Filter {
        return Filter(collection: Arr(map { $0 }), lambda: lambda)
    }
}
