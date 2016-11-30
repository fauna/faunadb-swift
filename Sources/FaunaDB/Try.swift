internal enum Try<Value> {
    case success(Value)
    case failure(Error)
}

extension Try {

    static func eval<T>(_ fn: () throws -> T) -> Try<T> {
        do {
            return .success(try fn())
        } catch let error {
            return .failure(error)
        }
    }

    func unwrap() throws -> Value {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }

    func map<A>(_ fn: (Value) throws -> A) -> Try<A> {
        switch self {
        case .success(let value): return Try.eval { try fn(value) }
        case .failure(let error): return .failure(error)
        }
    }

    func mapErr(_ fn: @escaping (Error) throws -> Value) -> Try {
        guard case .failure(let error) = self else { return self }
        return Try.eval { try fn(error) }
    }

}
