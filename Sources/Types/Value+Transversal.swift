import Foundation

extension Value {

    public func get<T>(_ path: Segment...) throws -> T? {
        return try get(path: path)
    }

    public func get<T>(path: [Segment]) throws -> T? {
        return try get(field: Field(path: path))
    }

    public func get<T>(field: Field<T>) throws -> T? {
        return try field.get(from: self)
    }

}

extension Value {

    public func at(_ path: Segment...) throws -> Value {
        return try at(path: path)
    }

    public func at(path: [Segment]) throws -> Value {
        return try at(field: Field(path: path))
    }

    public func at(field: Field<Value>) throws -> Value {
        return try get(field: field) ?? NullV()
    }

}

extension Value {

    public func get<T>(_ path: Segment...) throws -> [T] {
        return try get(path: path)
    }

    public func get<T>(path: [Segment]) throws -> [T] {
        return try at(path: path).collect(arrayOf: Field())
    }

    public func get<T>(field: Field<[T]>) throws -> [T] {
        return try field.get(from: self) ?? [T]()
    }

    public func collect<T>(arrayOf field: Field<T>) throws -> [T] {
        return try get(field: rootField.collect(arrayOf: field))
    }

}

extension Value {

    public func get<T>(_ path: Segment...) throws -> [String: T] {
        return try get(path: path)
    }

    public func get<T>(path: [Segment]) throws -> [String: T] {
        return try at(path: path).collect(dictionaryOf: Field())
    }

    public func get<T>(field: Field<[String: T]>) throws -> [String: T] {
        return try field.get(from: self) ?? [String: T]()
    }

    public func collect<T>(dictionaryOf field: Field<T>) throws -> [String: T] {
        return try get(field: rootField.collect(dictionaryOf: field))
    }

}

extension Value {

    public func map<T>(_ f: @escaping (Value) throws -> T) throws -> T? {
        return try get(field: rootField.map(f))
    }

    public func flatMap<T>(_ f: @escaping (Value) throws -> T?) throws -> T? {
        return try get(field: rootField.flatMap(f))
    }

}
