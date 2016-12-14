import XCTest

@testable import FaunaDB

class ErrorsTests: XCTestCase {

    func testBadRequest() {
        assertFail(httpCode: 400, error: BadRequest())
    }

    func testReturnUnauthorized() {
        assertFail(httpCode: 401, error: Unauthorized())
    }

    func testPermissionDenied() {
        assertFail(httpCode: 403, error: PermissionDenied())
    }

    func testNotFound() {
        assertFail(httpCode: 404, error: NotFound())
    }

    func testInternalServerError() {
        assertFail(httpCode: 500, error: InternalError())
    }

    func testUnavailable() {
        assertFail(httpCode: 503, error: Unavailable())
    }

    func testUnknowError() {
        assertFail(httpCode: 1001, error: UnknowError(status: 1001, errors: []))
    }

    func testParseErrorResponse() {
        let errorData = [
            "errors": [
                [
                    "position": ["data", 1, "token"],
                    "code": "invalid token",
                    "description": "Invalid token.",
                    "failures": [
                        [
                            "field": ["data", "token"],
                            "code": "invalid token",
                            "description": "Ivalid token"
                        ]
                    ]
                ]
            ]
        ]

        let json = try! JSONSerialization.data(withJSONObject: errorData, options: [])

        assertFail(httpCode: 401, json: json, error: Unauthorized(errors: [
            QueryError(
                position: ["data", "1", "token"],
                code: "invalid token",
                description: "Invalid token.",
                failures: [
                    ValidationFailure(
                        field: ["data", "token"],
                        code: "invalid token",
                        description: "Invalid token"
                    )
                ])
        ]))
    }

    func testUnparseableResponse() {
        let json = "Can't parse this as a error response".data(using: .utf8)!
        assertFail(httpCode: 401, json: json, error: Unauthorized(message: "Unparseable server response"))
    }

    func testErrorMessage() {
        let errorData = [
            "errors": [
                [
                    "position": ["data", "name"],
                    "code": "not unique",
                    "description": "Not unique.",
                    "failures": []
                ],
                [
                    "position": ["data", "age"],
                    "code": "not valid",
                    "description": "Not valid.",
                    "failures": []
                ]
            ]
        ]

        let json = try! JSONSerialization.data(withJSONObject: errorData, options: [])

        let res = HTTPURLResponse(
            url: URL(string: "http://localhost:8443")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!

        XCTAssertEqual(
            "\(Errors.errorFor(response: res, json: json)!)",
            "Error response 401: Errors: [data/name](not unique): Not unique., [data/age](not valid): Not valid."
        )
    }

    private func assertFail(httpCode: Int, json: Data = "{ \"errors\": [] }".data(using: .utf8)!, error expected: FaunaError) {
        let res = HTTPURLResponse(
            url: URL(string: "http://localhost:8443")!,
            statusCode: httpCode,
            httpVersion: nil,
            headerFields: nil
        )!

        guard let actual = Errors.errorFor(response: res, json: json) else {
            XCTFail("Expected an error but nil was returned")
            return
        }

        let actualType = type(of: actual)
        let expectedType = type(of: expected)

        XCTAssert(
            actualType == expectedType,
            "Error types are different: Expected \(expectedType), Actual: \(actualType)"
        )

        XCTAssertEqual(actual, expected)
    }

}
