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
    
    var refId: Ref? {
        return fId.map { Ref(ref: Self.classRef, id: $0) }
    }
}

public protocol FaunaModel: ExprConvertible {
    var client: Client { get }
    static var classRef: Ref { get }
    var fId: String? { get set }
    
    init(data: Obj)
}

extension ExprConvertible {
    var client: Client {
        return faunaClient
    }
}

extension ExprConvertible {
    
    public func rx_query() -> Observable<Value> {
        return self.client.rx_query(self)
    }
}


