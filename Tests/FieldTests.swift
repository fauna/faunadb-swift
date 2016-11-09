import XCTest

@testable import FaunaDB

struct Pet {
    let name: String
    let age: Int?
}

extension Pet {
    init?(value: Value) throws {
        self.name = try value.get("name")!
        self.age = try value.get("age")
    }
}

extension Pet: Equatable {
    static func == (left: Pet, right: Pet) -> Bool {
        return left.name == right.name && left.age == right.age
    }
}

class FieldTests: XCTestCase {

    let data: Value = ObjectV([
        "int": LongV(10),
        "arr": ArrayV([
            LongV(42),
            ObjectV([
                "int": LongV(25)
            ])
        ]),
        "nested": ObjectV(["key": StringV("value")])
    ])

    func testStringField() {
        XCTAssertEqual(try! StringV("test").get(), "test")
    }

    func testIntField() {
        XCTAssertEqual(try! LongV(10).get(), 10)
    }

    func testDoubleField() {
        XCTAssertEqual(try! DoubleV(10.2).get(), 10.2)
    }

    func testBooleanField() {
        XCTAssertEqual(try! BooleanV(true).get(), true)
    }

    func testTimeField() {
        let time = Date()
        XCTAssertEqual(try! TimeV(time).get(), time)
    }

    func testDateField() {
        let time = Date()
        XCTAssertEqual(try! DateV(time).get(), time)
    }

    func testRefField() {
        XCTAssertEqual(try! RefV("classes/users").get()!, RefV("classes/users"))
    }

    func testSetRefField() {
        let value = SetRefV([
            "match": RefV("indexes/all_spells")
        ])

        let set: SetRefV = try! value.get()!
        XCTAssertEqual(try! set.value["match"]!.get()!, RefV("indexes/all_spells"))
    }

    func testNullField() {
        let str: String? = try! NullV().get()
        XCTAssertEqual(str, nil)
    }

    func testObjectField() {
        let int = Field<Int>("int")
        XCTAssertEqual(try! data.get(field: int), 10)
    }

    func testArrayField() {
        let zero = Field<Int>("arr", 0)
        XCTAssertEqual(try! data.get(field: zero), 42)
    }

    func testNestedFields() {
        let int = Field<Int>("arr", 1, "int")
        XCTAssertEqual(try! data.get(field: int), 25)
        XCTAssertEqual(try! data.get("nested"), ["key": "value"])
    }

    func testFieldComposition() {
        let field1 = Field<Int>("arr", 1, "int")
        let field2 = Field<Int>("arr").at(field: Field<Int>(1, "int"))
        let field3 = Field<Int>("arr").at(1).at("int")

        XCTAssertEqual(try! data.get(field: field1) as Int?, try! data.get(field: field2) as Int?)
        XCTAssertEqual(try! data.get(field: field1) as Int?, try! data.get(field: field3) as Int?)
    }

    func testValueField() {
        let value: Value = try! data.get("arr", 1, "int")!
        XCTAssertEqual(try! value.get(), 25)
    }

    func testCollectFields() {
        let arr = ArrayV([
            LongV(1),
            LongV(2),
            LongV(3)
        ])

        XCTAssertEqual(try! arr.collect(), [1, 2, 3])
        XCTAssertEqual(try! arr.get(field: Field<Int>.collect(arrayOf: Field<Int>())), [1, 2, 3])
    }

    func testCollectFieldsAtNullValue() {
        let arr = NullV()
        XCTAssertEqual(try! arr.collect(), [Int]())
    }

    func testDictionaryFields() {
        let obj = ObjectV([
            "k1": LongV(1),
            "k2": LongV(2),
            "k3": LongV(3)
        ])

        XCTAssertEqual(try! obj.collect(), ["k1": 1, "k2": 2, "k3": 3])
        XCTAssertEqual(try! obj.get(field: Field<Int>.collect(dictionaryOf: Field<Int>())), ["k1": 1, "k2": 2, "k3": 3])
    }

    func testDictionaryFieldsAtNullValue() {
        XCTAssertEqual(try! NullV().collect(), [String: Int]())
    }

    func testMapField() {
        let obj = ObjectV([
            "name": StringV("Bob the cat"),
            "age": LongV(5)
        ])

        XCTAssertEqual(try! obj.map(Pet.init)!, Pet(name: "Bob the cat", age: 5))
    }

    func testMapToNilIfNoValueToMap() {
        let obj = ObjectV([
            "name": NullV()
        ])

        let name: String? = try! obj.get(field: Field<String>("name").map { "Hi \($0)" })
        XCTAssertNil(name)
    }

    func testTransverseToAValue() {
        XCTAssertEqual(try! data.at("int").get()!, 10)
        XCTAssertNil(try! data.at("non-existing-field").get(field: Field<Int>()))
    }

    func testFailOnInvalidField() {
        let value = StringV("a string")

        XCTAssertThrowsError(try (value.get() as Int?)) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at <root>: Can not decode value of type \"String\" to desired type \"Int\""
            )
        }
    }

    func testFailOnInvalidSegment() {
        let value = ObjectV([
            "not-object": StringV("a string"),
            "not-array": StringV("a string")
        ])

        XCTAssertThrowsError(try (value.get("not-object", "key") as String?)) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at \"not-object\" / \"key\": " +
                "Can not extract key \"key\" from non object value \"StringV\""
            )
        }

        XCTAssertThrowsError(try (value.get("not-array", 1) as String?)) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at \"not-array\" / 1: " +
                "Can not extract index 1 from non array value \"StringV\""
            )
        }
    }

    func testFailCollectingOnNonArrayValue() {
        let value = StringV("a string")

        XCTAssertThrowsError(try value.collect(arrayOf: Field<Value>())) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at <root>: " +
                "Can not collect fields from non array type \"StringV\""
            )
        }
    }

    func testFailCollectingOnNonObjectValue() {
        let value = StringV("a string")

        XCTAssertThrowsError(try value.collect(dictionaryOf: Field<Value>())) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at <root>: " +
                "Can not collect fields from non object type \"StringV\""
            )
        }
    }

    func testFailCollectingOnWrongType() {
        let value = ArrayV([
            StringV("aString"),
            LongV(1)
        ])

        XCTAssertThrowsError(try value.collect(arrayOf: Field<String>())) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at <root>: " +
                "Error at field 1: Can not decode value of type \"Int\" to desired type \"String\""
            )
        }
    }

    func testFailCollectingDictionaryOnWrongType() {
        let value = ObjectV([
            "key": StringV("value"),
            "key2": LongV(2)
        ])

        XCTAssertThrowsError(try value.collect(dictionaryOf: Field<String>())) { error in
            XCTAssertEqual(
                "\(error)",
                "Error while extracting field at <root>: " +
                "Error at field \"key2\": Can not decode value of type \"Int\" to desired type \"String\""
            )
        }
    }

}
