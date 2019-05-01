internal let rootField = Field<Value>()

/**
    `Field` represents a field extractor for database entries returned by the
    server.

    For example:

        let nameField = Field<String>("data", "name")

        let user = try! client.query(
            Get(
                Ref("classes/user/42")
            )
        ).await(timeout: .now() + 5)

        let userName = user.get(field: nameField)

    Every field has a path which is composed by a sequence of segments.
    A segment can be:

    - `String`: when the desired field is contained in an object in which the
        segment will be used as  the object key;
    - `Int`: when the desired field is contained in an array in which the
        segment will be used as the array index.

    ## Rules for field extraction and data conversion:

    - If the field is not present, it returns `nil`;
    - If the field can't be converted to the expected type, it throws an
        exception.  E.g.: `Field<String>("data", "name")` expects the "name"
        field to be a `String`. If the end result is not a `String`, it will fail;
    - If the path assumes a type that is not correct, it throws an exception.
        E.g.: `Field<String>("data", "name")` expects the target value to contain
        a nested object at the key "data" in which there should be a `String`
        field at the key "name". If "data" field is not an object, it will fail.

*/
public struct Field<T> {

    fileprivate let path: Path
    fileprivate let codec: Codec

    /// Initializes a new field extractor with a path containing the provided path segments.
    public init(_ segments: Segment...) {
        self.init(path: segments)
    }

    /// Converts an array of path segments into a field extractor.
    public init(path segments: [Segment]) {
        self.init(path: Path(segments))
    }

    fileprivate init(path: Path, codec: Codec = defaultCodec) {
        self.path = path
        self.codec = codec
    }

    internal func get(from value: Value) throws -> T? {
        do {
            return try path.extract(value: value).flatMap(codec.decode)
        } catch let error {
            throw FieldError(path: path, error: error)
        }
    }

}

extension Field {

    /// Creates a new nested field extractor based on its parent's path.
    public func at(_ segments: Segment...) -> Field {
        return at(path: segments)
    }

    /// Creates a new nested field extractor based on its parent's path.
    public func at(path segments: [Segment]) -> Field {
        return at(field: Field(path: Path(segments), codec: codec))
    }

    /// Combine two field extractors to create a nested field.
    public func at<A>(field: Field<A>) -> Field<A> {
        return Field<A>(path: self.path.subpath(field.path), codec: field.codec)
    }

    /// Combine two field extractors to create a nested array field.
    public func get<A>(asArrayOf field: Field<A>) -> Field<[A]> {
        return Field<[A]>(path: path, codec: CollectFields<A>(subpath: field.path, codec: field.codec))
    }

    /// Combine two field extractors to create a nested object field.
    public func get<A>(asDictionaryOf field: Field<A>) -> Field<[String: A]> {
        return Field<[String: A]>(path: path, codec: DictionaryFieds<A>(subpath: field.path, codec: field.codec))
    }

    /// Creates a new field by mapping the result of its parent's extracted value.
    public func map<A>(_ transform: @escaping (T) throws -> A) -> Field<A> {
        return Field<A>(path: path, codec: MapFunction<T, A>(codec: codec, fn: transform))
    }

    /// Creates a new field by flat mapping the result of its parent's extracted value.
    public func flatMap<A>(_ transform: @escaping (T) throws -> A?) -> Field<A> {
        return Field<A>(path: path, codec: FlatMapFunction<T, A>(codec: codec, fn: transform))
    }

}

/**
    `Fields` has static constructors for field extractors that can be used when
    the result value is still undefined. These constructors are useful for complex
    field compositions.

    For example:

        Fields.at("data", "arrayOfArrays").get(
            asArrayOf: Fields.get(asArrayOf: Field<String>())
        )

        // Resulting type: Field<[[String]]>

*/
public struct Fields {

    /// Creates a field extractor with the provided segments.
    public static func at(_ segments: Segment...) -> Field<Value> {
        return at(path: segments)
    }

    /// Creates a field extractor with the provided path.
    public static func at(path segments: [Segment]) -> Field<Value> {
        return Field(path: segments)
    }

    /// Uses the field extractor provided to create new array field.
    public static func get<A>(asArrayOf field: Field<A>) -> Field<[A]> {
        return Field(path: Path.root, codec: CollectFields<A>(subpath: field.path, codec: field.codec))
    }

    /// Uses the field extractor provided to create new object field.
    public static func get<A>(asDictionaryOf field: Field<A>) -> Field<[String: A]> {
        return Field(path: Path.root, codec: DictionaryFieds<A>(subpath: field.path, codec: field.codec))
    }

    /// Creates a field extractor by mapping its result to the function provided.
    public static func map<A>(_ transform: @escaping (Value) throws -> A) -> Field<A> {
        return Field(path: Path.root, codec: MapFunction<Value, A>(codec: defaultCodec, fn: transform))
    }

    /// Creates a field extractor by flat mapping its result to the function provided.
    public static func flatMap<A>(_ transform: @escaping (Value) throws -> A?) -> Field<A> {
        return Field<A>(path: Path.root, codec: FlatMapFunction<Value, A>(codec: defaultCodec, fn: transform))
    }

}

private protocol Collect: Codec {
    associatedtype SegmentType: Segment
    associatedtype Element
    associatedtype Result

    var subpath: Path { get }
    var codec: Codec { get }

    func decompose(value: Value) throws -> [(SegmentType, Value)]
    func convert(collected: [(SegmentType, Element)]) -> Result
}

extension Collect {
    func decode<T>(value: Value) throws -> T? {
        if value is NullV {
            return try cast(convert(collected: []))
        }

        return try cast(
            convert(collected:
                try decompose(value: value).compactMap {
                    try collectField(segment: $0.0, value: $0.1)
                }
            )
        )
    }

    private func collectField(segment: SegmentType, value: Value) throws -> (SegmentType, Element)? {
        do {
            guard
                let extracted = try subpath.extract(value: value),
                let decoded: Element = try codec.decode(value: extracted)
                else { return nil }

            return (segment, decoded)

        } catch let error {
            let currentPath = Path([segment]).subpath(subpath)
            throw CollectError.failToCollect(currentPath, error)
        }
    }
}

private struct CollectFields<E>: Collect {
    typealias SegmentType = Int
    typealias Element = E
    typealias Result = [Element]

    let subpath: Path
    let codec: Codec

    func decompose(value: Value) throws -> [(Int, Value)] {
        guard let arr = value as? ArrayV else {
            throw CollectError.notCollectable("array", value)
        }

        return arr.value.enumerated().map { ($0.offset, $0.element) }
    }

    func convert(collected: [(Int, E)]) -> [E] {
        return collected.map { $0.1 }
    }
}

private struct DictionaryFieds<E>: Collect {
    typealias SegmentType = String
    typealias Element = E
    typealias Result = [String: E]

    let subpath: Path
    let codec: Codec

    func decompose(value: Value) throws -> [(String, Value)] {
        guard let obj = value as? ObjectV else {
            throw CollectError.notCollectable("object", value)
        }

        return obj.value.map { ($0.key, $0.value) }
    }

    func convert(collected: [(String, E)]) -> [String: E] {
        return Dictionary(pairs: collected)
    }
}

private struct MapFunction<IN, OUT>: Codec {
    let codec: Codec
    let fn: (IN) throws -> OUT

    func decode<T>(value: Value) throws -> T? {
        guard let input: IN = try codec.decode(value: value) else { return nil }
        return try cast(fn(input))
    }
}

private struct FlatMapFunction<IN, OUT>: Codec {
    let codec: Codec
    let fn: (IN) throws -> OUT?

    func decode<T>(value: Value) throws -> T? {
        guard
            let input: IN = try codec.decode(value: value),
            let output = try fn(input)
            else { return nil }

        return try cast(output)
    }
}

private struct FieldError: Error {
    let path: Path
    let error: Error
}

extension FieldError: CustomStringConvertible {
    var description: String {
        return "Error while extracting field at \(path): \(error)"
    }
}

private enum CollectError: Error {
    case notCollectable(String, Value)
    case failToCollect(Path, Error)
}

extension CollectError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notCollectable(let desired, let actual):
            return "Can not collect fields from non \(desired) type \"\(type(of: actual))\""

        case .failToCollect(let subpath, let error):
            return "Error at field \(subpath): \(error)"
        }
    }
}
