internal struct Path {

    static let root = Path([])

    fileprivate let segments: [Segment]

    init(_ segments: [Segment]) {
        self.segments = segments
    }

    func subpath(_ other: Path) -> Path {
        return Path(self.segments + other.segments)
    }

    func extract(value: Value) throws -> Value? {
        return try segments.reduce(.some(value)) { value, segment in
            try value.flatMap(segment.extract)
        }
    }

}

extension Path: CustomStringConvertible {
    var description: String {
        guard !segments.isEmpty else { return "<root>" }
        return segments.map { String(reflecting: $0) }.joined(separator: " / ")
    }
}

/// Represents a path segment to a field value.
/// See `FaunaDB.Field` for more information.
public protocol Segment {}

extension String: Segment {}
extension Int: Segment {}

private extension Segment {

    func extract(value: Value) throws -> Value? {
        switch self {
        case let key as String: return try extract(value: value, key: key)
        case let index as Int:  return try extract(value: value, index: index)
        default:
            fatalError(
                "Unsupported segment type \(type(of: value)) " +
                "Custom implementation of Segment protocol are not supported."
            )
        }
    }

    private func extract(value: Value, key: String) throws -> Value? {
        guard let obj = value as? ObjectV else { throw InvalidSegment.key(key, value) }
        return obj.value[key]
    }

    private func extract(value: Value, index: Int) throws -> Value? {
        guard let arr = value as? ArrayV else { throw InvalidSegment.index(index, value) }
        return arr.value[index]
    }

}

private enum InvalidSegment: Error {
    case key(String, Value)
    case index(Int, Value)
}

extension InvalidSegment: CustomStringConvertible {

    var description: String {
        switch self {
        case .key(let key, let value):
            return "Can not extract key \"\(key)\" from non object value \"\(type(of: value))\""

        case .index(let index, let value):
            return "Can not extract index \(index) from non array value \"\(type(of: value))\""
        }
    }

}
