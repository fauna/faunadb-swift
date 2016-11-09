import XCTest

@testable import FaunaDB

class QueryResultTests: XCTestCase {

    private let queue = DispatchQueue.global(qos: .utility)

    func testMap() {
        XCTAssertEqual(
            try! successfulQueryResult(value: 1)
                .map { $0 * 2 }
                .await(),
            2
        )

        XCTAssertEqual(
            try! successfulQueryResult(value: 1)
                .map(at: queue) { $0 * 2 }
                .await(),
            2
        )
    }

    func testFlatMap() {
        XCTAssertEqual(
            try! successfulQueryResult(value: 1)
                .flatMap { _ in self.successfulQueryResult(value: "abc") }
                .await(),
            "abc"
        )

        XCTAssertEqual(
            try! successfulQueryResult(value: 1)
                .map(at: queue) { $0 * 2 }
                .await(),
            2
        )

    }

    func testDoNotExecuteCallbacksIfNilValue() {
        let res = QueryResult<Int>()
        _ = res.map { _ in XCTFail("Should not map nil value") }
        res.value = nil
    }

    func testDoNotMapOnError() {
        _ = failedQueryResult().map { _ in XCTFail("Should not map on error") }
    }

    func testDoNotFlatMapOnError() {
        _ = failedQueryResult().flatMap { _ -> QueryResult<Void> in
            XCTFail("Should not map on error")
            return QueryResult()
        }
    }

    func testMapErr() {
        XCTAssertEqual(try! failedQueryResult().mapErr { _ in 42 }.await(), 42)
        XCTAssertEqual(try! failedQueryResult().mapErr(at: queue) { _ in 42 }.await(), 42)
    }

    func testFlatMapErr() {
        XCTAssertEqual(
            try! failedQueryResult().flatMapErr { _ in
                self.successfulQueryResult(value: 42)
            }.await(),
            42
        )

        XCTAssertEqual(
            try! failedQueryResult().flatMapErr(at: queue) { _ in
                self.successfulQueryResult(value: 42)
            }.await(),
            42
        )
    }

    func testDoNotMapErrOnSuccess() {
        XCTAssertEqual(
            try! successfulQueryResult(value: 1)
                .mapErr { _ in
                    XCTFail("Should not call mapErr when success")
                    return 0
                }.await(),
            1
        )
    }

    func testDoNotFlatMapErrOnSuccess() {
        XCTAssertEqual(
            try! successfulQueryResult(value: 1)
                .flatMapErr { _ in
                    XCTFail("Should not call mapErr when success")
                    return self.successfulQueryResult(value: 0)
                }.await(),
            1
        )
    }

    func testTimesOutOnLongOperations() {
        let res = QueryResult<Int>()

        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 3) {
            res.value = .success(1)
        }

        XCTAssertThrowsError(try res.await(timeout: DispatchTime.now() + 1)) { error in
            XCTAssert(error is TimeoutError)
        }
    }

    private func successfulQueryResult<A>(value: A) -> QueryResult<A> {
        let res = QueryResult<A>()
        res.value = .success(value)
        return res
    }

    private func failedQueryResult() -> QueryResult<Int> {
        let res = QueryResult<Int>()
        res.value = .failure(TestError())
        return res
    }

}

fileprivate struct TestError: Error {}
