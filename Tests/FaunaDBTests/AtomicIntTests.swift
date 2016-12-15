import XCTest

@testable import FaunaDB

class AtomicIntTests: XCTestCase {

    func testIncrementAndGetg() {
        let atomic = AtomicInt(label: "testing-atomic-integer")
        XCTAssertEqual(atomic.incrementAndGet(), 1)
        XCTAssertEqual(atomic.incrementAndGet(), 2)
    }

    func testOverflow() {
        let atomic = AtomicInt(label: "testing-atomic-integer", initial: Int.max - 1)
        XCTAssertEqual(atomic.incrementAndGet(), Int.max)
        XCTAssertEqual(atomic.incrementAndGet(), 0)
    }

}
