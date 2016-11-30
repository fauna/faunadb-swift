import XCTest

@testable import FaunaDB

class DeserializationTests: XCTestCase {

    func testStringV() {
        assert(parse: "\"a string\"", to: StringV("a string"))
    }

    func testLongV() {
        assert(parse: "10", to: LongV(10))
    }

    func testDoubleV() {
        assert(parse: "2.142", to: DoubleV(2.142))
    }

    func testBooleanV() {
        assert(parse: "true", to: BooleanV(true))
        assert(parse: "false", to: BooleanV(false))
    }

    func testNullV() {
        assert(parse: "null", to: NullV())
    }

    func testArrayV() {
        assert(
            parse: "[1,2,\"a string\"]",
            to: ArrayV([
                LongV(1),
                LongV(2),
                StringV("a string")
            ])
        )
    }

    func testEmptyArray() {
        assert(parse: "[]", to: ArrayV([]))
    }

    func testObjectV() {
        assert(
            parse: "{\"key1\":42,\"key2\":{\"inner\":\"value\"}}",
            to: ObjectV([
                "key1": LongV(42),
                "key2": ObjectV([
                    "inner": StringV("value")
                ])
            ])
        )
    }

    func testLiteralObjectV() {
        assert(
            parse: "{\"@obj\":{\"@name\":\"Hen Wen\"}}",
            to: ObjectV([
                "@name": StringV("Hen Wen")
            ])
        )
    }

    func testEmptyObjectV() {
        assert(parse: "{}", to: ObjectV([:]))
    }

    func testTimeV() {
        assert(parse: "{\"@ts\":\"1970-01-01T00:05:00Z\"}", to: TimeV(date: Date(timeIntervalSince1970: 5 * 60)))
        assert(parse: "{\"@ts\":\"1970-01-01T00:00:01Z\"}", to: TimeV(date: Date(timeIntervalSince1970: 1)))
        assert(parse: "{\"@ts\":\"1970-01-01T00:00:00.001Z\"}", to: TimeV(HighPrecisionTime(secondsSince1970: 0, millisecondsOffset: 1)))
        assert(parse: "{\"@ts\":\"1970-01-01T00:00:00.000001Z\"}", to: TimeV(HighPrecisionTime(secondsSince1970: 0, microsecondsOffset: 1)))
        assert(parse: "{\"@ts\":\"1970-01-01T00:00:00.000000001Z\"}", to: TimeV(HighPrecisionTime(secondsSince1970: 0, nanosecondsOffset: 1)))
    }

    func testInvalidTime() {
        XCTAssertThrowsError(try JSON.parse(string: "{\"@ts\":\"abc\"}")) { error in
            XCTAssertEqual("\(error)", "Invalid date \"abc\"")
        }
    }

    func testDateV() {
        assert(parse: "{\"@date\":\"1970-01-01\"}",
                to: DateV(Date(timeIntervalSince1970: 0)))
    }

    func testInvalidDate() {
        XCTAssertThrowsError(try JSON.parse(string: "{\"@date\":\"abc\"}")) { error in
            XCTAssertEqual("\(error)", "Invalid date \"abc\"")
        }
    }

    func testRefV() {
        assert(parse: "{\"@ref\":\"classes\\/spells\\/42\"}",
                to: RefV("classes/spells/42"))
    }

    func testSetRefV() {
        assert(
            parse: "{\"@set\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}",
            to: SetRefV([
                "match": RefV("indexes/spells_by_element"),
                "terms": StringV("fire")
            ])
        )
    }

    private func assert<T: Value & Equatable>(parse json: String, to expected: T) {
        let parsed = try! JSON.parse(string: json)

        guard let actual = parsed as? T else {
            XCTFail("assertd JSON value type is different than expected type. Actual: \(parsed). Expected: \(expected)")
            return
        }

        XCTAssertEqual(actual, expected)
    }

}
