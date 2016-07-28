//
//  ClientConfigurationTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
@testable import FaunaDB

class DeserializationTests: FaunaDBTests {

    func testQueryResponse() {
        let toDeserialize =
            "{" +
                "\"class\":{\"@ref\":\"classes/derp\"}," +
                "\"data\":{\"test\":1}," +
                "\"ref\":{\"@ref\":\"classes/derp/101192216816386048\"}," +
                "\"ts\":1432763268186882" +
        "}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        let value =  Obj([  "ref": Ref("classes/derp/101192216816386048"),
                          "class": Ref("classes/derp"),
                             "ts": Double(1432763268186882),
                           "data": Obj(["test": 1.0])])
        XCTAssertTrue(deseralizedValue.isEquals(value))
    }


    func testQueryResponseWithRef() {
        let toDeserialize =
            "{" +
                "\"ref\":{\"@ref\":\"classes/spells/93044099947429888\"}," +
                "\"class\":{\"@ref\":\"classes/spells\"}," +
                "\"ts\":1424992618413105," +
                "\"data\":{\"refField\":{\"@ref\":\"classes/spells/93044099909681152\"}}" +
            "}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        let value = Obj( [ "ref": Ref("classes/spells/93044099947429888"),
                         "class": Ref("classes/spells"),
                            "ts": Double(1424992618413105),
                          "data": Obj(["refField": Ref("classes/spells/93044099909681152")])])
        XCTAssert(deseralizedValue.isEquals(value))
    }


    func testQueryResponseWithLiteralObject(){
        let toDeserialize =
        "{" +
            "\"class\":{\"@ref\":\"classes/derp\"}," +
            "\"data\":{\"test\":{\"field1\":{\"@obj\":{\"@name\":\"Test\"}}}}," +
            "\"ref\":{\"@ref\":\"classes/derp/101727203651223552\"}," +
            "\"ts\":1433273471399755" +
        "}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        let value = Obj( [  "ref": Ref("classes/derp/101727203651223552"),
                          "class": Ref("classes/derp"),
                             "ts": Double(1433273471399755),
                           "data": Obj(["test": Obj(["field1": Obj(["@name": "Test"])])])])
        XCTAssert(deseralizedValue.isEquals(value))
    }

    func testEmptyObject(){
        let toDeserialize = "{}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        XCTAssert(deseralizedValue.isEquals(Obj()))
    }


    func testTs(){
        let toDeserialize =  "{\"@ts\":\"1970-01-01T00:05:00Z\"}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        XCTAssert(deseralizedValue.isEquals(Timestamp(timeIntervalSince1970: 5.MIN)))
    }

    func testDate(){
        let toDeserialize = "{\"@date\":\"1970-01-03\"}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        let date = Date(iso8601: "1970-01-03")
        XCTAssertNotNil(date)
        XCTAssert(deseralizedValue.isEquals(date!))
    }

    func testBool(){
        let toDeserialize = "{\"bool\": true}"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
         XCTAssert(deseralizedValue.isEquals(Obj(["bool": true])))
    }

    func testArr(){
        let toDeserialize = "[0, true, 1, false, \"Hi\", {\"@date\":\"1970-01-03\"}, {\"@ts\":\"1970-01-01T00:05:00Z\"}]"
        let deseralizedValue = try! Mapper.fromString(toDeserialize)
        let date = Date(iso8601: "1970-01-03")
        XCTAssertNotNil(date)
        let arr = Arr(Double(0), true, Double(1), false, "Hi", date!,  Timestamp(timeIntervalSince1970: 5.MIN))
        XCTAssert(deseralizedValue.isEquals(arr))
    }
}
