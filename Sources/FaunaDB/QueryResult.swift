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

    public func map<A>(at queue: DispatchQueue? = nil, _ transform: @escaping (T) throws -> A) -> QueryResult<A> {
        let res = QueryResult<A>()

        onComplete(at: queue) { result in
            res.value = result.map(transform)
        }

        return res
    }

    public func flatMap<A>(at queue: DispatchQueue? = nil, _ transform: @escaping (T) throws -> QueryResult<A>) -> QueryResult<A> {
        let res = QueryResult<A>()

        onComplete(at: queue) { result in
            _ = result.map { value in
                try transform(value).onComplete { nested in
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

    public func mapErr(at queue: DispatchQueue? = nil, _ transform: @escaping (Error) throws -> T) -> QueryResult {
        let res = QueryResult()

        onComplete(at: queue) { result in
            res.value = result.mapErr(transform)
        }

        return res
    }

    public func flatMapErr(at queue: DispatchQueue? = nil, _ transform: @escaping (Error) throws -> QueryResult) -> QueryResult {
        let res = QueryResult()

        onComplete(at: queue) { result in
            _ = result.map { value in res.value = result }.mapErr { error in
                try transform(error).onComplete { nested in
                    res.value = nested
                }
            }
        }

        return res
    }

}

extension QueryResult {

    @discardableResult
    public func onSuccess(at queue: DispatchQueue? = nil, _ callback: @escaping (T) throws -> Void) -> QueryResult {
        return map(at: queue) { res in
            try callback(res)
            return res
        }
    }

    @discardableResult
    public func onFailure(at queue: DispatchQueue? = nil, _ callback: @escaping (Error) throws -> Void) -> QueryResult {
        return mapErr(at: queue) { error in
            try callback(error)
            throw error
        }
    }

}

extension QueryResult {

    public func await(timeout: DispatchTime) throws -> T {
        do {
            return try Latch.await(timeout: timeout) { done in
                self.onComplete(callback: done)
            }
        } catch let timeout as LatchTimeout {
            throw TimeoutError(message: "Operation timed out after \(timeout.uptimeNanoseconds) nanoseconds.")
        }
    }

}
