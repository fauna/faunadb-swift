//
//  Helpers.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import FaunaDB
import RxSwift

import Foundation

let secret = "your_admin_key"

#if DEBUG
var faunaClient: Client = {
    return Client(secret: secret, observers: [Logger()])
}()
#else
var faunaClient: Client = {
    return Client(secret: secret)
}()
#endif


extension FaunaModel {

    func fCreate() -> Create {
        return Create(ref: Self.classRef, params: Obj(["data": value]))
    }

    func fUpdate() -> Update? {
        return refId.map { Update(ref: $0, params: Obj(["data": value])) }
    }

    func fDelete() -> Delete? {
        return refId.map {  Delete(ref: $0) }
    }

    func fReplace() -> Replace? {
        return refId.map { Replace(ref: $0, params: Obj(["data": value])) }
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
        return client.rx_query(self)
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
