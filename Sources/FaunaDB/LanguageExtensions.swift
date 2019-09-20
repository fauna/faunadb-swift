import Foundation

internal extension Dictionary {

    init(pairs: [Element]) {
        self.init(minimumCapacity: pairs.count)
        pairs.forEach { self[$0.key] = $0.value }
    }

    func mapT<K, V>(_ f: (Element) throws -> (K, V)) rethrows -> [K: V] {
        return try [K: V](pairs: self.map(f))
    }

    func mapValuesT<V>(_ f: (Value) throws -> V) rethrows -> [Key: V] {
        return try mapT { ($0, try f($1)) }
    }

}

@nonobjc
internal extension NSNumber {

    func isBoolNumber() -> Bool {
        return CFGetTypeID(self) == CFBooleanGetTypeID()
    }

    func isDoubleNumber() -> Bool {
        return stringValue.contains(".")
    }

}
