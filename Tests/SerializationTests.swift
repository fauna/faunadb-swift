//
//  SerializationTests.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/8/16.
//
//

import XCTest
@testable import FaunaDB


class SerializationTests: FaunaDBTests {

    func testRef() {
        let ref = Ref("some/ref")
        XCTAssertEqual(ref.jsonString, "{\"@ref\":\"some\\/ref\"}")
    }
    
    func testArr(){
        let arr: Arr = [3, "test", Null()]
        XCTAssertEqual(arr.jsonString, "[3,\"test\",null]")
    }
    
    func testObj() {
        let obj: Obj = ["test": 1, "test2": Ref("some/ref")]
        XCTAssertEqual(obj.jsonString, "{\"object\":{\"test2\":{\"@ref\":\"some\\/ref\"},\"test\":1}}")
    }
    
    func testArrWithObj() {
        let arr: Arr = [Arr(Obj(("test", "value")), 2323, true), "hi", Obj(("test", "yo"), ("test2", Null()))]
        XCTAssertEqual(arr.jsonString, "[[{\"object\":{\"test\":\"value\"}},2323,true],\"hi\",{\"object\":{\"test2\":null,\"test\":\"yo\"}}]")
    }
    
    func testLiteralValues() {
        XCTAssertEqual(true.toAnyObjectJSON() as? Bool, true)
        XCTAssertEqual(false.toAnyObjectJSON() as? Bool, false)
        XCTAssertEqual("test".toAnyObjectJSON() as? String, "test")
        XCTAssertEqual(Int.max.toAnyObjectJSON() as? Int, Int.max)
        XCTAssertEqual(Float(3.14).toAnyObjectJSON() as? Float, Float(3.14))
        XCTAssertEqual(3.14.toAnyObjectJSON() as? Double, Double(3.14))
        XCTAssertEqual(Null().toAnyObjectJSON() as? NSNull, NSNull())
    }
    
    func testResourceModifications(){
        
        //Create
        let spell: Obj = ["name": "Mountainous Thunder", "element": "air", "cost":15]
        let create = Create("classes/spells", ["data": spell])
        XCTAssertEqual(create.jsonString, "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}")

        //Replace
        var replaceSpell = spell
        replaceSpell["name"] = "Mountain's Thunder"
        replaceSpell["element"] = Arr("air", "earth")
        replaceSpell["cost"] = 10
        let replace = Replace("classes/spells/123456", ["data": replaceSpell])
        XCTAssertEqual(replace.jsonString, "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}")
        
        //Delete
        let delete = Delete("classes/spells/123456")
        XCTAssertEqual(delete.jsonString, "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}")
        
        //Insert
        let insert = Insert(ref: "classes/spells/123456", ts: Timestamp(timeIntervalSince1970: 0), action: .Create, params: ["data": replaceSpell])
        XCTAssertEqual(insert.jsonString, "{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
        

        //Remove
        let remove = Remove(ref: "classes/spells/123456", ts: Timestamp(timeIntervalSince1970: 0), action: .Create)
        XCTAssertEqual(remove.jsonString, "{\"action\":\"create\",\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
    }
    
    
    func testDateAndTimestamp() {
        let ts: Timestamp = Timestamp(timeIntervalSince1970: 0)
        XCTAssertEqual(ts.jsonString, "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}")
        
        let ts2 = Timestamp(timeInterval: 5.MIN, sinceDate: ts)
        XCTAssertEqual(ts2.jsonString, "{\"@ts\":\"1970-01-01T00:05:00.000Z\"}")
        
        
        let ts3 = Timestamp(iso8601: "1970-01-01T00:00:00.123Z")
        XCTAssertEqual(ts3?.jsonString, "{\"@ts\":\"1970-01-01T00:00:00.123Z\"}")
        
        let ts4 = Timestamp(iso8601: "1970-01-01T00:00:00Z")
        XCTAssertEqual(ts4?.jsonString, "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}")
        
        
        let date = Date(day: 18, month: 7, year: 1984)
        XCTAssertEqual(date.jsonString, "{\"@date\":\"1984-07-18\"}")
        
        let date2 = Date(iso8601:"1984-07-18")
        XCTAssertNotNil(date2)
        XCTAssertEqual(date2?.jsonString, "{\"@date\":\"1984-07-18\"}")
    }
}
