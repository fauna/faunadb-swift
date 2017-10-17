import XCTest

@testable import FaunaDB

class DescriptionTests: XCTestCase {

    func testRefV() {
        XCTAssertEqual(RefV("123").description, "RefV(id=123)")
        XCTAssertEqual(RefV("cls", class: Native.CLASSES).description, "RefV(id=cls, class=RefV(id=classes))")
        XCTAssertEqual(RefV("123", class: RefV("cls", class: Native.CLASSES, database: RefV("db", class: Native.DATABASES))).description,
                       "RefV(id=123, class=RefV(id=cls, class=RefV(id=classes), database=RefV(id=db, class=RefV(id=databases))))")
    }
}
