import Foundation

public class QueryResult<T> {

    typealias Callback = (Try<T>) -> Void

    private let lock = DispatchQueue(label: "FaunaDB.QueryResult<\(T.self)>-" + UUID().uuidString)
    private var callbacks = [Callback]()

    var value: Try<T>? {
        willSet { assert(value == nil) }
        didSet { notify() }
    }

    func onComplete(at queue: DispatchQueue? = nil, callback: @escaping Callback) {
        let runCallback: Callback = { result in
            guard let queue = queue else { return callback(result) }
            queue.async { callback(result) }
        }

        lock.sync {
            if let value = value {
                runCallback(value)
            } else {
                callbacks.append(runCallback)
            }
        }
    }

    private func notify() {
        guard let value = value else { return }

        lock.sync {
            callbacks.forEach { callback in callback(value) }
            callbacks.removeAll()
        }
    }

}

extension QueryResult {

    @discardableResult
    public func map<A>(at queue: DispatchQueue? = nil, _ fn: @escaping (T) throws -> A) -> QueryResult<A> {
        let res = QueryResult<A>()

        onComplete(at: queue) { result in
            res.value = result.map(fn)
        }

        return res
    }

    @discardableResult
    public func flatMap<A>(at queue: DispatchQueue? = nil, _ fn: @escaping (T) throws -> QueryResult<A>) -> QueryResult<A> {
        let res = QueryResult<A>()

        onComplete(at: queue) { result in
            _ = result.map { value in
                try fn(value).onComplete { nested in
                    res.value = nested
                }
            }.mapErr { error in
                res.value = .failure(error)
            }
        }

        return res
    }

}

extension QueryResult {

    @discardableResult
    public func mapErr(at queue: DispatchQueue? = nil, _ fn: @escaping (Error) throws -> T) -> QueryResult {
        let res = QueryResult()

        onComplete(at: queue) { result in
            res.value = result.mapErr(fn)
        }

        return res
    }

    @discardableResult
    public func flatMapErr(at queue: DispatchQueue? = nil, _ fn: @escaping (Error) throws -> QueryResult) -> QueryResult {
        let res = QueryResult()

        onComplete(at: queue) { result in
            _ = result.map { value in res.value = result }.mapErr { error in
                try fn(error).onComplete { nested in
                    res.value = nested
                }
            }
        }

        return res
    }

}

extension QueryResult {

    public func await(timeout: DispatchTime) throws -> T {
        do {
            return try Latch.await(timeout: timeout) { done in
                self.onComplete(callback: done)
            }
        } catch is LatchTimeout {
            throw TimeoutError(message: "Timed out while waiting for resource.")
        }
    }

}
