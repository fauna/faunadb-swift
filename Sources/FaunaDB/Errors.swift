import Foundation

internal struct Errors {

    private static let errorField = Fields.at("errors").get(asArrayOf:
        Fields.map(QueryError.init)
        )

    static func errorFor(response: HTTPURLResponse, json: Data) -> FaunaError? {
        guard !(200 ..< 300 ~= response.statusCode) else { return nil }

        guard let errors = try? parseErrors(from: json) else {
            return errorTypeFor(
   status: response.statusCode,
   message: "Unparseable server response"
   )
        }

        return errorTypeFor(
   status: response.statusCode,
   errors: errors
   )
    }

    private static func errorTypeFor(status: Int, errors: [QueryError] = [], message: String? = nil) -> FaunaError {
        switch status {
        case 400: return BadRequest(errors: errors, message: message)
        case 401: return Unauthorized(errors: errors, message: message)
        case 403: return PermissionDenied(errors: errors, message: message)
        case 404: return NotFound(errors: errors, message: message)
        case 500: return InternalError(errors: errors, message: message)
        case 503: return Unavailable(errors: errors, message: message)
        default:  return UnknownError(status: status, errors: errors, message: message)
        }
    }

    private static func parseErrors(from json: Data) throws -> [QueryError] {
        return try JSON
            .parse(data: json)
            .get(field: errorField)
    }
}

/// Represents an error while executing a FaunaDB query.
public class FaunaError: Error {

    /// The error message.
    public let message: String?

    /// The HTTP status code.
    public let status: Int?

    /// The errors found by FaunDB while executing the query.
    public let errors: [QueryError]

    fileprivate init(status: Int? = nil, errors: [QueryError] = [], message: String? = nil) {
        self.message = message
        self.status = status
        self.errors = errors
    }

}

extension FaunaError: Equatable {
    public static func == (left: FaunaError, right: FaunaError) -> Bool {
        return
            left.message == right.message &&
            left.status == right.status &&
            left.errors == right.errors
    }
}

extension FaunaError: CustomStringConvertible {

    public var description: String {
        var res = "Error response "
        res += (status.map { "\($0)" } ?? "<unknow>") + ":"
        res += (message.map { " \($0)." } ?? "")
        res += (queryErrors().map { " Errors: \($0)" } ?? "")

        return res
    }

    private func queryErrors() -> String? {
        guard errors.count > 0 else { return nil }

        return errors.map { error in
            var res = "[" + error.position.joined(separator: "/") + "]"
            res += (error.code.map { "(\($0)):" } ?? ":")
            res += (error.description.map { " \($0)" } ?? "")
            return res
        }
        .joined(separator: ", ")
    }

}

/// Wraps a HTTP 400 error response.
public final class BadRequest: FaunaError {
    public init(errors: [QueryError] = [], message: String? = nil) {
        super.init(status: 400, errors: errors, message: message)
    }
}

/// Wraps a HTTP 401 error response.
public final class Unauthorized: FaunaError {
    public init(errors: [QueryError] = [], message: String? = nil) {
        super.init(status: 401, errors: errors, message: message)
    }
}

/// Wraps a HTTP 403 error response.
public final class PermissionDenied: FaunaError {
    public init(errors: [QueryError] = [], message: String? = nil) {
        super.init(status: 403, errors: errors, message: message)
    }
}

/// Wraps a HTTP 404 error response.
public final class NotFound: FaunaError {
    public init(errors: [QueryError] = [], message: String? = nil) {
        super.init(status: 404, errors: errors, message: message)
    }
}

/// Wraps a HTTP 500 error response.
public final class InternalError: FaunaError {
    public init(errors: [QueryError] = [], message: String? = nil) {
        super.init(status: 500, errors: errors, message: message)
    }
}

/// Wraps a HTTP 503 error response.
public final class Unavailable: FaunaError {
    public init(errors: [QueryError] = [], message: String? = nil) {
        super.init(status: 503, errors: errors, message: message)
    }
}

/// Wraps any unknown error.
public final class UnknownError: FaunaError {
    public override init(status: Int? = nil, errors: [QueryError] = [], message: String? = nil) {
        super.init(status: status, errors: errors, message: message)
    }

    public init(cause: Error) {
        super.init(message: cause.localizedDescription)
    }
}

/// Error returned when a timeout occurs during the query execution.
public final class TimeoutError: FaunaError {
    public init(message: String? = nil) {
        super.init(message: message)
    }
}

/// Represents an error found by FaunaDB while executing a query.
public struct QueryError {

    /// The position of the field containing the error.
    public let position: [String]

    /// The FaunaDB error code.
    public let code: String?

    /// The description of the error found.
    public let description: String?

    /// A list of validation failures that occurred during the query execution.
    public let failures: [ValidationFailure]

    public init(position: [String], code: String?, description: String?, failures: [ValidationFailure]) {
        self.position = position
        self.code = code
        self.description = description
        self.failures = failures
    }
}

extension QueryError {

    private static let positionField = Fields.at("position").get(asArrayOf:
        Fields.map { value in
            "\(value)"
        }
    )

    private static let failuresField = Fields.at("failures").get(asArrayOf:
        Fields.map(ValidationFailure.init)
    )

    fileprivate init(value: Value) throws {
        try self.init(
            position: value.get(field: QueryError.positionField),
            code: value.get("code"),
            description: value.get("description"),
            failures: value.get(field: QueryError.failuresField)
        )
    }

}

extension QueryError: Equatable {
    public static func == (left: QueryError, right: QueryError) -> Bool {
        return left.position == right.position &&
            left.code == right.code &&
            left.description == right.description &&
            left.failures == right.failures
    }
}

/// Represents a validation failure while executing a FaunaDB query.
public struct ValidationFailure {

    /// The position of the field that triggered the validation failure.
    public let field: [String]

    /// The FaunaDB error code.
    public let code: String?

    /// The description of the validation failure.
    public let description: String?

    public init(field: [String], code: String?, description: String?) {
        self.field = field
        self.code = code
        self.description = description
    }
}

extension ValidationFailure {

    private static let fieldAsString = Fields.at("field").get(asArrayOf:
        Fields.map { value in
            "\(value)"
        }
    )

    init(value: Value) throws {
        try self.init(
            field: value.get(field: ValidationFailure.fieldAsString),
            code: value.get("code"),
            description: value.get("description")
        )
    }
}

extension ValidationFailure: Equatable {
    public static func == (left: ValidationFailure, right: ValidationFailure) -> Bool {
        return left.field == right.field &&
            left.code == right.code &&
            left.description == right.description
    }
}
