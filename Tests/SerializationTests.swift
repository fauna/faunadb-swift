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
        XCTAssertEqual(true.toJSON() as? Bool, true)
        XCTAssertEqual(false.toJSON() as? Bool, false)
        XCTAssertEqual("test".toJSON() as? String, "test")
        XCTAssertEqual(Int.max.toJSON() as? Int, Int.max)
        XCTAssertEqual(3.14.toJSON() as? Double, Double(3.14))
        XCTAssertEqual(Null().toJSON() as? NSNull, NSNull())
    }
    
    func testBasicForms() {
        
        
        
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
    
    
    func testCollections() {
        
        let map = Map(arr: [1,2,3], lambda: Lambda(vars: "munchings", expr: Var("munchings")))
        XCTAssertEqual(map.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"munchings\"},\"lambda\":\"munchings\"}}")
        
        let map1 = Map(arr: [1,2,3], lambda: { x in x })
        XCTAssertEqual(map1.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"x\"},\"lambda\":\"x\"}}")
        
        let map2 = Map(arr: [1,2,3]) { $0 }
        XCTAssertEqual(map2.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"x\"},\"lambda\":\"x\"}}")
        
        let map3 = [1,2,3].mapFauna { (value: Value) -> Expr in
            value
        }
        XCTAssertEqual(map3.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"x\"},\"lambda\":\"x\"}}")
        
        let foreach = Foreach(arr: [Ref("another/ref/1"), Ref("another/ref/2")], lambda: Lambda(vars: "refData", expr: Create("some/ref", ["data": Obj(("some", Var("refData")))])))
        XCTAssertEqual(foreach.jsonString, "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"refData\"}}}}}},\"lambda\":\"refData\"}}")
        
        let foreach2 = Foreach(arr: [Ref("another/ref/1"), Ref("another/ref/2")]) { ref in
                            Create("some/ref", ["data": Obj(("some", ref))])
                        }
        XCTAssertEqual(foreach2.jsonString, "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"x\"}}}}}},\"lambda\":\"x\"}}")
        
        let foreach3 = [Ref("another/ref/1"), Ref("another/ref/2")].forEachFauna {
                            Create("some/ref", ["data": Obj(("some", $0))])
                        }
        XCTAssertEqual(foreach3.jsonString, "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"x\"}}}}}},\"lambda\":\"x\"}}")
        
        let filter = Filter(arr: [1,2,3] as Arr, lambda: Lambda(lambda: { i in  Equals(terms: 1, i) }))
        XCTAssertEqual(filter.jsonString, "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"x\"}]},\"lambda\":\"x\"}}")
        
        let filter2 = Filter(arr: [1,2,3] as [Int], lambda: Lambda(lambda: { i in  Equals(terms: 1, i) }))
        XCTAssertEqual(filter2.jsonString, "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"x\"}]},\"lambda\":\"x\"}}")
        
        let filter3 = Filter(arr: [1,"Hi",3], lambda: Lambda(lambda: { i in  Equals(terms: 1, i) }))
        XCTAssertEqual(filter3.jsonString, "{\"collection\":[1,\"Hi\",3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"x\"}]},\"lambda\":\"x\"}}")
        
        let take = Take(2, arr: Arr(1, 2, 3))
        XCTAssertEqual(take.jsonString, "{\"collection\":[1,2,3],\"take\":2}")
        
        let take2 = Take(2, arr: [1, 2, 3] as [Int])
        XCTAssertEqual(take2.jsonString, "{\"collection\":[1,2,3],\"take\":2}")
        
        let take3 = Take(2, arr: [1, "Hi", 3])
        XCTAssertEqual(take3.jsonString, "{\"collection\":[1,\"Hi\",3],\"take\":2}")
        
        let drop = Drop(2, arr: Arr(1,2,3))
        XCTAssertEqual(drop.jsonString, "{\"collection\":[1,2,3],\"drop\":2}")
        
        let drop2 = Drop(2, arr: [1, 2, 3] as [Int])
        XCTAssertEqual(drop2.jsonString, "{\"collection\":[1,2,3],\"drop\":2}")
        
        let drop3 = Drop(2, arr: [1, "Hi", 3])
        XCTAssertEqual(drop3.jsonString, "{\"collection\":[1,\"Hi\",3],\"drop\":2}")
        
        let prepend = Prepend(Arr(1,2,3), toCollection:  Arr(4,5,6))
        XCTAssertEqual(prepend.jsonString, "{\"collection\":[1,2,3],\"prepend\":[4,5,6]}")
    
        let append = Append(Arr(4,5,6), toCollection:Arr(1,2,3))
        XCTAssertEqual(append.jsonString, "{\"collection\":[4,5,6],\"append\":[1,2,3]}")
    }
    
    func testResourceRetrievals(){
        
        let ref = Ref("some/ref/1")
        let get = Get(ref: ref)
        XCTAssertEqual(get.jsonString, "{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        let paginate = Paginate(resource: Union(sets: Match(indexRef: "indexes/some_index", terms: "term"), Match(indexRef: "indexes/some_index", terms: "term2")))
        XCTAssertEqual(paginate.jsonString, "{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")
        
        let paginate2 = Paginate(resource: Union(sets: Match(indexRef: "indexes/some_index", terms: "term"), Match(indexRef: "indexes/some_index", terms: "term2")), sources: true)
        XCTAssertEqual(paginate2.jsonString, "{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"sources\":true}")
        
        let paginate3 = Paginate(resource: Union(sets: Match(indexRef: "indexes/some_index", terms: "term"), Match(indexRef: "indexes/some_index", terms: "term2")), events: true)
        XCTAssertEqual(paginate3.jsonString, "{\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")
        
        let paginate4 = Paginate(resource: Union(sets: Match(indexRef: "indexes/some_index", terms: "term"), Match(indexRef: "indexes/some_index", terms: "term2")), size: 4)
        XCTAssertEqual(paginate4.jsonString, "{\"size\":4,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")

        let count = Count(set: Match(indexRef: "indexes/spells_by_element", terms: "fire"))
        XCTAssertEqual(count.jsonString, "{\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
        let count2 = Count(set: Match(indexRef: "indexes/spells_by_element", terms: "fire"), events: true)
        XCTAssertEqual(count2.jsonString, "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
    }
}
