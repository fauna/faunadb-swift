//
//  File.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/9/16.
//
//

import Foundation
import RxSwift
import FaunaDB
import Result

extension FaunaDB.Client {

    public func rx_query(expr: ExprType) -> Observable<ValueType> {
        return Observable.create { [weak self] subscriber in
            let task = self?.query(expr) { result in
                switch result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let value):
                    subscriber.onNext(value)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                task?.cancel()
            }
        }
    }
    
}


extension ObservableType where Self.E == ValueType {
    
    public func mapWithField<T: ValueType>(field: Field<T>) -> Observable<T> {
        return self.map {
            return try field.get($0)
        }
    }
}