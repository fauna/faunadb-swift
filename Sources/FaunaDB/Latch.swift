import Foundation

internal struct LatchTimeout: Error {}

internal class Latch<T> {

    private let lock = DispatchSemaphore(value: 0)

    var value: Try<T>? {
        willSet { assert(value == nil) }
        didSet { lock.signal() }
    }

    func await(timeout: DispatchTime) throws -> T {
        if case .timedOut = lock.wait(timeout: timeout) { throw LatchTimeout() }
        guard let value = value else { fatalError("Latch released with no value set") }
        return try value.unwrap()
    }
}

extension Latch {

    static func await(timeout: DispatchTime, _ fn: (@escaping (Try<T>) -> Void) -> Void) throws -> T {
        let latch = Latch<T>()
        fn() { value in latch.value = value }
        return try latch.await(timeout: timeout)
    }

}
