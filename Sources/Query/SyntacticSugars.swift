//
//  SyntacticSugars.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation


extension SequenceType where Self.Generator.Element: ValueConvertible {
    
    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Map(collection: Expr(self.map { $0 }), lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Foreach(collection: Expr(self.map { $0 }), lambda: lambda)
    }
    
    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Filter(collection: Expr(self.map { $0 }), lambda: lambda)
    }
}

extension SequenceType where Self.Generator.Element == Value {
    
    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Map(collection: Expr(self.map { $0 }), lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Foreach(collection: Expr(self.map { $0 }), lambda: lambda)
    }
    
    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Filter(collection: Expr(self.map { $0 }), lambda: lambda)
    }
}

extension SequenceType where Self.Generator.Element == ValueConvertible {
    
    public func mapFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Map(collection: Expr(self.map { $0 }), lambda: lambda)
    }
    
    public func forEachFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Foreach(collection: Expr(self.map { $0 }), lambda: lambda)
    }
    
    public func filterFauna(@noescape lambda: ((Expr) -> Expr)) -> Expr {
        return Filter(collection: Expr(self.map { $0 }), lambda: lambda)
    }
}


