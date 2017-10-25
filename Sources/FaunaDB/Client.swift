import Foundation

/**
    `Client` represents a HTTP client for a FaunaDB server. It provides
    methods, such as `query` and `query(batch:)` that you can use to execute
    queries in your server.

    - Note: This class is meant to be reused as much as possible. If you
    need to connect to the same server but using a different key's secret, use
    `newSessionClient` method instead of creating a new `Client` instance.
*/
public final class Client {

    private static let defaultEndpoint: URL! = URL(string: "https://db.fauna.com")
    private static let resourcesField = Field<Value>("resource")

    private let session: URLSession
    private let endpoint: URL
    private let auth: String

    /**
        - Parameters:
            - secret:   The key's secret to be used to authenticate requests.
            - endpoint: The URL address of your FaunaDB server. Default: https://db.fauna.com.
            - session:  The `URLSession` object to be used while performing HTTP requests to FaunaDB.
                        Default: `URLSession(configuration: URLSessionConfiguration.default)`.
    */
    public init(secret: String, endpoint: URL = defaultEndpoint, session: URLSession? = nil) {
        self.auth = "Basic \((secret.data(using: .ascii) ?? Data()).base64EncodedString()):"
        self.endpoint = endpoint

        if let session = session {
            self.session = session
        } else {
            self.session = URLSession(configuration: URLSessionConfiguration.default)
        }
    }

    /**
        Returns a new `Client` instance for the same FaunaDB server but using a
        different key's secret to authenticate HTTP requests. The new client shares its
        parent's resources, such as its URLSession.

        - Parameter secret: The key's secret to be used to authenticate HTTP requests.
    */
    public func newSessionClient(secret: String) -> Client {
        return Client(
            secret: secret,
            endpoint: endpoint,
            session: session
        )
    }

    /**
        Sends a query to the FaunaDB server. All queries are executed asynchronously.
        `QueryResult` will be fulfilled once the query finishes to run, or fail.

        - Parameter expr: The query expression to be sent. Check `FaunaDB.Expr` for more information.
    */
    public func query(_ expr: Expr) -> QueryResult<Value> {
        let res = QueryResult<Value>()

        do {
            try send(
                request: httpRequestFor(expr),
                ifSuccess: { res.value = .success($0) },
                ifFailure: { res.value = .failure($0) }
            )
        } catch let e {
            res.value = .failure(e)
        }

        return res
    }

    /**
        Sends a batch of queries to the FaunaDB server. All queries are executed asynchronously.
        `QueryResult` will be fulfilled once all queries finishes to run, or fail. The result array
        will be in the same order as the request array.

        - Parameter batch: A sequence of query expressions to be sent to FaunaDB.
    */
    public func query(batch: [Expr]) -> QueryResult<[Value]> {
        return query(Arr(wrap: batch)).map { value in
            try value.get()
        }
    }

    private func httpRequestFor(_ expr: Expr) throws -> URLRequest {
        let request = NSMutableURLRequest(url: endpoint)

        request.httpMethod = "POST"
        request.httpBody = try JSON.data(value: expr)
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(auth, forHTTPHeaderField: "Authorization")
        request.addValue("2.1", forHTTPHeaderField: "X-FaunaDB-API-Version")

        return request as URLRequest
    }

    private func send(request: URLRequest,
                      ifSuccess successCallback: @escaping (Value) -> Void,
                      ifFailure failureCallback: @escaping (Error) -> Void) {

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let this = self else { return }

            guard this.handle(error: error, with: failureCallback) else {
                this.handle(response: response,
                            data: data,
                            ifSuccess: successCallback,
                            ifFailure: failureCallback)
                return
            }
        }

        task.resume()
    }

    private func handle(error: Error?, with callback: @escaping (Error) -> Void) -> Bool {
        guard let error = error else { return false }

        if let urlError = error as? URLError, urlError.code == .timedOut {
            callback(TimeoutError(message: "Request timed out."))
        } else {
            callback(UnknownError(cause: error))
        }

        return true
    }

    private func handle(response: URLResponse?, data: Data?,
                        ifSuccess successCallback: @escaping (Value) -> Void,
                        ifFailure failureCallback: @escaping (Error) -> Void) {

        guard let response = response as? HTTPURLResponse, let data = data else {
            failureCallback(UnknownError(message: "Invalid server response."))
            return
        }

        if let error = Errors.errorFor(response: response, json: data) {
            failureCallback(error)
            return
        }

        do {
            let parsed = try JSON.parse(data: data)

            guard let resources = try parsed.get(field: Client.resourcesField) else {
                failureCallback(UnknownError(message: "Invalid server response: \"resource\" key not found."))
                return
            }

            successCallback(resources)
        } catch let error {
            failureCallback(error)
        }
    }

}
