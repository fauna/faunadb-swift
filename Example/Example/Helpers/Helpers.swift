//
//  Helpers.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//


import FaunaDB
import RxSwift

import Foundation

var faunaClient: Client = {
    return Client(secret: "kqnPAd6R_jhAAA20RPVgavy9e9kaW8bz-wWGX6DPNWI", observers: [Logger()])
}()

extension FaunaModel {
    
    func fCreate() -> Create {
        return Create(ref: Self.classRef, params: ["data": value])
    }
    
    func fUpdate() -> Update? {
        guard let refId = refId else {
            return nil
        }
        return Update(ref: refId, params: ["data": value])
    }
    
    func fDelete() -> Delete? {
        guard let refId = refId else {
            return nil
        }
        return Delete(ref: refId)
    }
    
    func fReplace() -> Replace? {
        guard let refId = refId else { return nil }
        return Replace(ref: refId, params: ["data": value])
    }
    
}

public protocol FaunaModel: ValueConvertible {
    var client: Client { get }
    static var classRef: Ref { get }
    var refId: Ref? { get }
}

extension ValueConvertible {
    var client: Client {
        return faunaClient
    }
}

extension Expr {
    
    public func rx_query() -> Observable<Value> {
        return self.client.rx_query(self)
    }
}




extension NSNumber {
    
    private func isBoolNumber() -> Bool{
        return CFGetTypeID(self) == CFBooleanGetTypeID()
    }
    
    private func isDoubleNumber() -> Bool{
        return CFNumberGetType(self) == CFNumberType.DoubleType || CFNumberGetType(self) == CFNumberType.Float64Type
    }
    
}

// Helpers to make Array and Dictionary types conforms to ArrayLiteralConvertible and DictionaryLiteralConvertible respectively.

extension Arr: ArrayLiteralConvertible {
        
    public init(arrayLiteral elements: ValueConvertible...){
        self.init(elements)
    }
}

extension Obj: DictionaryLiteralConvertible {
    
    public init(dictionaryLiteral elements: (String, ValueConvertible)...){
        self.init(elements)
    }
}

