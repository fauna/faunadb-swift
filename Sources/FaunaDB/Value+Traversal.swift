extension Value {

    /// Converts the value at the provided path to the desired type `T`.
    public func get<T>(_ path: Segment...) throws -> T? {
        return try get(path: path)
    }

    /// Converts the value at the provided path to the desired type `T`.
    public func get<T>(path: [Segment]) throws -> T? {
        return try get(field: Field(path: path))
    }

    /// Converts the value at the provided field to the desired type `T`.
    public func get<T>(field: Field<T>) throws -> T? {
        return try field.get(from: self)
    }

}

extension Value {

    /// Returns the value at the provided path.
    public func at(_ path: Segment...) throws -> Value {
        return try at(path: path)
    }

    /// Returns the value at the provided path.
    public func at(path: [Segment]) throws -> Value {
        return try at(field: Field(path: path))
    }

    /// Extracts the provided field from this value.
    public func at(field: Field<Value>) throws -> Value {
        return try get(field: field) ?? NullV()
    }

}

extension Value {

    /// Converts the value at the provided path to an array of the desired type `T`.
    public func get<T>(_ path: Segment...) throws -> [T] {
        return try get(path: path)
    }

    /// Converts the value at the provided path to an array of the desired type `T`.
    public func get<T>(path: [Segment]) throws -> [T] {
        return try at(path: path).get(asArrayOf: Field())
    }

    /// Converts the value at the provided field to an array of the desired type `T`.
    public func get<T>(field: Field<[T]>) throws -> [T] {
        return try field.get(from: self) ?? [T]()
    }

    /// Converts each nested array element in this value using the provided field.
    /// Assumes this value is an array.
    public func get<T>(asArrayOf field: Field<T>) throws -> [T] {
        return try get(field: rootField.get(asArrayOf: field))
    }

}

extension Value {

    /// Converts the value at the provided path to an object of `String` to the desired type `T`.
    public func get<T>(_ path: Segment...) throws -> [String: T] {
        return try get(path: path)
    }

    /// Converts the value at the provided path to an object of `String` to the desired type `T`.
    public func get<T>(path: [Segment]) throws -> [String: T] {
        return try at(path: path).get(asDictionaryOf: Field())
    }

    /// Converts the value at the provided field to an object of `String` to the desired type `T`.
    public func get<T>(field: Field<[String: T]>) throws -> [String: T] {
        return try field.get(from: self) ?? [String: T]()
    }

    /// Converts each nested object element in this value using the provided field.
    /// Assumes this value is an object.
    public func get<T>(asDictionaryOf field: Field<T>) throws -> [String: T] {
        return try get(field: rootField.get(asDictionaryOf: field))
    }

}

extension Value {

    /// Maps this value using the provided function.
    public func map<T>(_ transform: @escaping (Value) throws -> T) throws -> T? {
        return try get(field: rootField.map(transform))
    }

    /// Flat maps this value using the provided function.
    public func flatMap<T>(_ transform: @escaping (Value) throws -> T?) throws -> T? {
        return try get(field: rootField.flatMap(transform))
    }

}
