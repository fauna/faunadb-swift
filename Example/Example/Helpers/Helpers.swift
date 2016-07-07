//
//  Helpers.swift
//  Example
//
//  Created by Martin Barreto on 7/4/16.
//
//

import FaunaDB
import RxSwift

import Foundation

extension FaunaModel {
    
    func fCreate() -> Expr {
        return Create(ref: Self.classRef, params: ["data": value])
    }
    
    func fUpdate() -> Expr? {
        guard let refId = refId else {
            return nil
        }
        return Update(ref: refId, params: ["data": value])
    }
    
    func fDelete() -> Expr? {
        guard let refId = refId else {
            return nil
        }
        return Delete(ref: refId)
    }
    
    func fReplace() -> Expr {
        guard let refId = refId else { return nil }
        return Replace(ref: refId, params: ["data": value])
    }
    
    var refId: Ref? {
        return fId.map { Ref(ref: Self.classRef, id: $0) }
    }
}

public protocol FaunaModel: ValueConvertible {
    var client: Client { get }
    static var classRef: Ref { get }
    var fId: String? { get set }
    
    init(data: Obj)
}

extension ValueConvertible {
    var client: Client {
        return faunaClient
    }
}

extension ValueConvertible {
    
    public func rx_query() -> Observable<Value> {
        return self.client.rx_query(self)
    }
}


