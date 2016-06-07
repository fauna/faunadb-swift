//
//  Field.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/7/16.
//
//

import Foundation

protocol FieldType {
    associatedtype T: ValueType
    var path: FieldPathType { get }
    func get(value: ValueType) -> T
}
