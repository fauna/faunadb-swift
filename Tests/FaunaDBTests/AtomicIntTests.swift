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
    
    func testUpdateMaxTo() {
        let atomic = AtomicInt(label: "testing-max", initial: 0)
        
        atomic.update(maxTo: 1)
        XCTAssertEqual(atomic.get(), 1)
        
        atomic.update(maxTo: 2)
        XCTAssertEqual(atomic.get(), 2)
        
        atomic.update(maxTo: 1)
        XCTAssertEqual(atomic.get(), 2)
    }

}
