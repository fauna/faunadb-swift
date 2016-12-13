import Foundation

/**
    Represent the result of an asynchronous query executed in a FaunaDB server.

    - Note: All methods available to handle `QueryResult` success or failure.
    will optionally receive a `DispatchQueue`. The only `DispatchQueue` allowed
    to update the UI is `DispatchQueue.main`.
*/
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

    /**
        Maps the result returned by the server using the function informed.

        - Parameters:
            - queue:     The dispatch queue in which the transformation will be performed.
            - transform: The transformation to be applied on the result value.

        - Returns: A `QueryResult` containing the transformed value.
    */
    public func map<A>(at queue: DispatchQueue? = nil, _ transform: @escaping (T) throws -> A) -> QueryResult<A> {
        let res = QueryResult<A>()

        onComplete(at: queue) { result in
            res.value = result.map(transform)
        }

        return res
    }

    /**
        Flat maps the result returned by the server using the function informed.

        - Parameters:
            - queue:     The dispatch queue in which the transformation will be performed.
            - transform: The transformation to be applied on the result value.

        - Returns: A `QueryResult` containing the transformed value.
    */
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

    /**
        Apply a transformation if an error has occurred during the query execution.

        If `mapErr` returns a value, the resulting `QueryResult` will be considered a success.
        If you wish to handle an error but still return a failing `QueryResult`, you must rethrow
        the original exception.

        For example:

            // Revover form an error
            client.query(/* some query */)
                .map { value in
                    try value.get() as Int?
                }
                .mapErr { error in
                    debugPrint(error)
                    return nil
                }

            // Handle but don't recover from an error
            client.query(/* some query */)
                .map { value in
                    try value.get() as Int?
                }
                .mapErr { error in
                    debugPrint(error)
                    throw error
                }

        - Parameters:
            - queue:     The dispatch queue in which the transformation will be performed.
            - transform: The transformation to be applied on the resulting error.

        - Returns: A `QueryResult` containing the transformed value.
    */
    public func mapErr(at queue: DispatchQueue? = nil, _ transform: @escaping (Error) throws -> T) -> QueryResult {
        let res = QueryResult()

        onComplete(at: queue) { result in
            res.value = result.mapErr(transform)
        }

        return res
    }

    /**
        Apply a transformation if an error has occurred during the query execution.

        If `flatMapErr` returns a value, the resulting `QueryResult` will be considered a success.
        If you wish to handle an error but still return a failing `QueryResult`, you must rethrow
        the original exception.

        For example:

            // Revover form an error
            client.query(/* some query */)
                .map { value in
                    try value.get() as Int?
                }
                .flatMapErr { error in
                    debugPrint(error)
                    return client.query(/* other query */)
                        .map { value in
                            try value.get() as Int?
                        }
                }

            // Handle but don't recover from an error
            client.query(/* some query */)
                .map { value in
                    try value.get() as Int?
                }
                .flatMapErr { error in
                    debugPrint(error)
                    throw error
                }

        - Parameters:
            - queue:     The dispatch queue in which the transformation will be performed.
            - transform: The transformation to be applied on the resulting error.

        - Returns: A `QueryResult` containing the transformed value.
    */
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

    /**
        Execute a callback when the resulting value is available.

        - Parameters:
            - queue:    The dispatch queue in which the callback will be called.
            - callback: The callback to be called when the resulting value is available.
    */
    @discardableResult
    public func onSuccess(at queue: DispatchQueue? = nil, _ callback: @escaping (T) throws -> Void) -> QueryResult {
        return map(at: queue) { res in
            try callback(res)
            return res
        }
    }

    /**
        Execute a callback when an error occurred during the query execution.

        - Parameters:
            - queue:    The dispatch queue in which the callback will be called.
            - callback: The callback to be called when an error occurs.
    */
    @discardableResult
    public func onFailure(at queue: DispatchQueue? = nil, _ callback: @escaping (Error) throws -> Void) -> QueryResult {
        return mapErr(at: queue) { error in
            try callback(error)
            throw error
        }
    }

}

extension QueryResult {

    /**
        Blocks the current thread waiting for the query to be executed.

        - Note: This method is discouraged due to its blocking nature.
        Prefer `map`, `onSuccess`, and their variations to prevent your code from
        blocking your application.

        - Parameter timeout: How long it should wait for the result to come back.
        - Returns: The resulting query value.
        - Throws: Any exception that might have happened during the query execution.
    */
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
