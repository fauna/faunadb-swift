//
//  ClientConfigurationTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
import Nimble
@testable import FaunaDB

class SerializationTests: FaunaDBTests {

    func testRef() {
        
        // MARK: Ref
        expectToJson(Ref("some/ref")) == "{\"@ref\":\"some\\/ref\"}"
        
        let classRef = Ref("classes/technology")
        expectToJson(Ref(ref: classRef, id: "1234")) == "{\"@ref\":\"classes\\/technology\\/1234\"}"
        
        expect(classRef.description) == classRef.debugDescription
    }
    
    func testArr(){
        
        // MARK: Arr
        var arr2: Arr = [3, "test", Null(), 2.4]
        let arr2Copy =  arr2
        expect(arr2 == arr2Copy).to(beTrue())
        expectToJson(arr2) == "[3,\"test\",null,2.4]"
        arr2.replaceRange(1..<3, with: ["FaunaDB"])
        expectToJson(arr2) == "[3,\"FaunaDB\",2.4]"
        arr2[0] = 33
        expectToJson(arr2) == "[33,\"FaunaDB\",2.4]"
        arr2.removeAll()
        expectToJson(arr2) == "[]"
        arr2.reserveCapacity(100)
        expect(arr2.description) == arr2.debugDescription
        expect(arr2.description).to(beginWith("Arr("))
        expect(arr2.description).to(endWith(")"))
        expect(arr2 == arr2Copy).to(beFalse())

        let intArr = [1, 2, 3]
        expectToJson(Arr(sequence: intArr)) == "[1,2,3]"
        
        let strArray = ["Hi", "Hi2", "Hi3"]
        expectToJson(Arr(sequence: strArray)) == "[\"Hi\",\"Hi2\",\"Hi3\"]"
        
        let timestampArray = [Timestamp(timeIntervalSince1970: 0)]
        expectToJson(Arr(sequence: timestampArray)) == "[{\"@ts\":\"1970-01-01T00:00:00.000Z\"}]"
        
        let refArray = [Ref("some/ref")]
        expectToJson(Arr(sequence: refArray)) == "[{\"@ref\":\"some\\/ref\"}]"
        
        let valueArr: [Value] = [3, "test", Timestamp(timeIntervalSince1970: 0), Double(3.5)]
        expectToJson(Arr(sequence: valueArr)) == "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5]"
        
        let complexValue = [3, "test", Timestamp(timeIntervalSince1970: 0), 3.5, [3, "test", Timestamp(timeIntervalSince1970: 0), 3.5] as Arr] as Arr
        
        expectToJson(complexValue) == "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5,[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5]]"
        
        expectToJson([3, 4, 5, 6, [3, 5, 6, 7] as Arr] as Arr) == "[3,4,5,6,[3,5,6,7]]"
    }
    
    func testObj() {
        
        // MARK: Obj
        let obj: Obj = ["test": 1, "test2": Ref("some/ref")]
        expectToJson(obj) == "{\"object\":{\"test2\":{\"@ref\":\"some\\/ref\"},\"test\":1}}"
        
        var obj2: Obj = [:]
        obj2["test"] = 1
        obj2["test2"] =  Ref("some/ref")
        expect(obj2) == obj
        
        let obj3: Obj = ["key": 3, "key2": "test", "key3": Timestamp(timeIntervalSince1970: 0)]
        expectToJson(obj3) == "{\"object\":{\"key2\":\"test\",\"key\":3,\"key3\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}}"
    }
    
    func testArrWithObj() {
        let arr: Arr = [[["test":"value"] as Obj, 2323, true] as Arr, "hi", ["test": "yo","test2": Null()] as Obj]
        expectToJson(arr) == "[[{\"object\":{\"test\":\"value\"}},2323,true],\"hi\",{\"object\":{\"test2\":null,\"test\":\"yo\"}}]"
    }
    
    func testLiteralValues() {
        
        // MARK: Literal Values
        
        expect(true.toJSON() as? Bool) == true
        expect(false.toJSON() as? Bool) ==  false
        expect("test".toJSON() as? String) == "test"
        expect(Int.max.toJSON() as? Int) == Int.max
        expect(3.14.toJSON() as? Double) == Double(3.14)
        expect(Null().toJSON() as? NSNull) == NSNull()
    }
    
    func testDateAndTimestamp() {
        
        //MARK: Timestamp
        
        let ts = Timestamp(timeIntervalSince1970: 0)
        expectToJson(ts) == "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}"
        
        let ts2 = Timestamp(timeInterval: 5.MIN, sinceDate: ts)
        expectToJson(ts2) == "{\"@ts\":\"1970-01-01T00:05:00.000Z\"}"
        
        let ts3 = Timestamp(iso8601: "1970-01-01T00:00:00.123Z")
        expectToJson(ts3) == "{\"@ts\":\"1970-01-01T00:00:00.123Z\"}"
        
        let ts4 = Timestamp(iso8601: "1970-01-01T00:00:00Z")
        expectToJson(ts4) == "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}"
        
        //MARK: Date
        
        let date = Date(day: 18, month: 7, year: 1984)
        expectToJson(date) == "{\"@date\":\"1984-07-18\"}"
        
        let date2 = Date(iso8601:"1984-07-18")
        XCTAssertNotNil(date2)
        expectToJson(date2) == "{\"@date\":\"1984-07-18\"}"
    }
    
    func testStringFunctions() {
        
        //MARK: Concat
        
        expectToJson(Concat(strList: ["Hen", "Wen"] as Arr)) == "{\"concat\":[\"Hen\",\"Wen\"]}"
        expectToJson(Concat(strList: ["Hen", "Wen"] as Arr, separator: " ")) == "{\"concat\":[\"Hen\",\"Wen\"],\"separator\":\" \"}"
        
        //MARK: Casefold
        
        expectToJson(Casefold(str: "Hen Wen")) == "{\"casefold\":\"Hen Wen\"}"
    }
    
    func testTimeAndDateFunctions() {
        
        expectToJson(Time("1970-01-01T00:00:00+00:00")) == "{\"time\":\"1970-01-01T00:00:00+00:00\"}"
        
        expectToJson(Epoch(offset: 10, unit: TimeUnit.second)) == "{\"unit\":\"second\",\"epoch\":10}"
        
        expectToJson(Epoch(offset: 10, unit: "millisecond")) == "{\"unit\":\"millisecond\",\"epoch\":10}"
        
        expectToJson(DateFn(iso8601: "1970-01-02")) == "{\"date\":\"1970-01-02\"}"
        
    }
    
    func testResourceModifications(){
        
        //MARK: Create
        
        let spell: Obj = ["name": "Mountainous Thunder", "element": "air", "cost": 15]
        var create = Create(ref: Ref("classes/spells"),
                            params: ["data": spell])
        expectToJson(create) == "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}"
        
        create = Create(ref: Ref("classes/spells"),
                        params: ["data": ["name": "Mountainous Thunder", "element": "air", "cost": 15] as Obj] as Obj)
        expectToJson(create) == "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}"
        
        create = Create(ref: Ref("classes/spells"),
                        params: ["data": ["name": "Mountainous Thunder", "element": "air", "cost": 15] as Obj] as Obj)
        expectToJson(create) == "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}"
        
        
        //MARK: Update
        
        var update = Update(ref: Ref("classes/spells/123456"),
                            params: ["data": ["name": "Mountain's Thunder", "cost": Null()] as Obj])
        expectToJson(update) == "{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}"
        
        update = Update(ref: Ref("classes/spells/123456") as Expr,
                        params: ["data": ["name": "Mountain's Thunder", "cost": Null()] as Obj] as Obj)
        expectToJson(update) == "{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}"
        
        update = Update(ref: Ref("classes/spells/123456"),
                        params: ["data": ["name": "Mountain's Thunder", "cost": Null()] as Obj])
        expectToJson(update) == "{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}"
        
        //MARK: Replace
        
        var replaceSpell = spell
        replaceSpell["name"] = "Mountain's Thunder"
        replaceSpell["element"] = ["air", "earth"] as Arr
        replaceSpell["cost"] = 10
        var replace = Replace(ref: Ref("classes/spells/123456"),
                              params: ["data": replaceSpell])
        expectToJson(replace) == "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}"
        
        
        replace = Replace(ref: Ref("classes/spells/123456"),
                          params: ["data": ["name": "Mountain's Thunder", "element": ["air", "earth"] as Arr, "cost": 10] as Obj])
        expectToJson(replace) == "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}"
        
        replace = Replace(ref: Ref("classes/spells/123456"),
                          params: ["data": ["name": "Mountain's Thunder", "element": ["air", "earth"] as Arr, "cost": 10] as Obj])
        expectToJson(replace) == "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}"
        
        //MARK: Delete
        
        var delete = Delete(ref: Ref("classes/spells/123456"))
        
        expectToJson(delete) == "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}"
        
        delete = Delete(ref: Ref("classes/spells/123456"))
        
        expectToJson(delete) == "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}"
        
        //MARK: Insert
        
        var insert = Insert(ref: Ref("classes/spells/123456"),
                            ts: Timestamp(timeIntervalSince1970: 0),
                            action: .Create,
                            params: ["data": replaceSpell])
        
        expectToJson(insert) == "{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"
        
        
        insert = Insert(ref: Ref("classes/spells/123456"),
                        ts: Timestamp(timeIntervalSince1970: 0),
                        action: Action.Create,
                        params: ["data": ["name": "Mountain's Thunder", "element": ["air", "earth"] as Arr, "cost": 10] as Obj] as Obj)
        
        expectToJson(insert) == "{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"
        
        
        //MARK: Remove
        
        var remove = Remove(ref: Ref("classes/spells/123456"),
                            ts: Timestamp(timeIntervalSince1970: 0),
                            action: .Create)
        expectToJson(remove) == "{\"action\":\"create\",\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"
        
        remove = Remove(ref: Ref("classes/spells/123456"),
                        ts: Timestamp(timeIntervalSince1970: 0),
                        action: Action.Create)
        expectToJson(remove) == "{\"action\":\"create\",\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"
    }
    
    func testCollections() {
        
        //MARK: Map
        
        Var.resetIndex()
        var map = Map(collection: [1,2,3] as Arr,
                      lambda: Lambda(vars: Var("munchings"), expr: Var("munchings")))
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"munchings\"},\"lambda\":\"munchings\"}}"
        
        Var.resetIndex()
        map = [1,2,3].mapFauna { x in
            x
        }
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        map = ([1,2,3] as Arr).mapFauna { $0 }
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        map = ([1,2,3] as [Expr]).mapFauna { (value: Expr) -> Expr in
            value
        }
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        map = ([1,2,3] as [ValueConvertible]).mapFauna { (value: Expr) -> Expr in
            value
        }
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}"

        
        //MARK: Foreach
        
        Var.resetIndex()
        var foreach = Foreach(collection: [Ref("another/ref/1"), Ref("another/ref/2")] as Arr,
                              lambda: Lambda(vars: Var("refData"),
                                expr: Create(ref: Ref("some/ref"),
                                    params: ["data": ["some": Var("refData").value] as Obj]
                                )))
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"refData\"}}}}}},\"lambda\":\"refData\"}}"
        
        Var.resetIndex()
        foreach = [Ref("another/ref/1"), Ref("another/ref/2")].forEachFauna { ref in
            Create(ref: Ref("some/ref"), params: ["data": ["some": ref.value] as Obj])
        }
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        foreach = (([Ref("another/ref/1"), Ref("another/ref/2")] as Arr)).forEachFauna {
            Create(ref: Ref("some/ref"),
                params: ["data": ["some": $0.value] as Obj])
        }
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        foreach = ([Ref("another/ref/1"), Ref("another/ref/2")] as [Expr]).forEachFauna {
            Create(ref: Ref("some/ref"),
                params: ["data": ["some": $0.value] as Obj])
            }
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}"
            
        Var.resetIndex()
        foreach = ([Ref("another/ref/1"), Ref("another/ref/2")] as [ValueConvertible]).forEachFauna {
            Create(ref: Ref("some/ref"),
                params: ["data": ["some": $0.value] as Obj])
            }
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}"
        
        //MARK: Filter
        
        Var.resetIndex()
        var filter = Filter(collection: [1,2,3] as Arr, lambda: Lambda(lambda: { i in Equals(terms: 1, i) }))
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        filter = [1,2,3].filterFauna { i in  Equals(terms: 1, i) }
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        filter = ([1,2,3] as Arr).filterFauna { i in  Equals(terms: 1, i) }
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        filter = ([1,2,3] as [Expr]).filterFauna { i in  Equals(terms: 1, i) }
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        filter = ([1,2,3] as [ValueConvertible]).filterFauna { i in  Equals(terms: 1, i) }
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"
        
        Var.resetIndex()
        filter = Filter(collection: [1,"Hi",3] as Arr,
                        lambda: Lambda(lambda: { i in
                            Equals(terms: 1, i)
                        })
        )
        expectToJson(filter) == "{\"collection\":[1,\"Hi\",3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"
        
        //MARK: Take
        
        let take = Take(count: 2, collection: [1, 2, 3] as Arr)
        expectToJson(take) == "{\"collection\":[1,2,3],\"take\":2}"
        
        
        let take2 = Take(count: 2 as Expr, collection: [1, 2, 3] as Arr)
        expectToJson(take2) == "{\"collection\":[1,2,3],\"take\":2}"
        
        let take3 = Take(count: 2, collection: [1, "Hi", 3] as Arr)
        expectToJson(take3) == "{\"collection\":[1,\"Hi\",3],\"take\":2}"
        
        //MARK: Drop
        
        let drop = Drop(count: 2, collection: [1,2,3] as Arr)
        expectToJson(drop) == "{\"collection\":[1,2,3],\"drop\":2}"
        
        let drop2 = Drop(count: 2 as Expr, collection: [1, 2, 3] as Arr)
        expectToJson(drop2) == "{\"collection\":[1,2,3],\"drop\":2}"
        
        let drop3 = Drop(count: 2, collection: [1, "Hi", 3] as Arr)
        expectToJson(drop3) == "{\"collection\":[1,\"Hi\",3],\"drop\":2}"
        
        //MARK: Prepend
        
        let prepend = Prepend(elements: [1,2,3] as Arr, toCollection: [4,5,6] as Arr)
        expectToJson(prepend) == "{\"collection\":[1,2,3],\"prepend\":[4,5,6]}"
        
        //MARK: Append
        
        let append = Append(elements: [4,5,6] as Arr, toCollection: [1,2,3] as Arr)
        expectToJson(append) == "{\"collection\":[4,5,6],\"append\":[1,2,3]}"
        
    }
    
    func testResourceRetrievals(){
        
        //MARK: Get
        
        let ref = Ref("some/ref/1")
        var get = Get(ref: ref)
        expectToJson(get) == "{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}"
        
        get = Get(ref: ref, ts: Timestamp(timeIntervalSince1970: 0))
        expectToJson(get) == "{\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"},\"get\":{\"@ref\":\"some\\/ref\\/1\"}}"
        
        //MARK: Exists
        
        var exists = Exists(ref: ref)
        expectToJson(exists) == "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"}}"
        
        exists = Exists(ref: ref, ts: Timestamp(timeIntervalSince1970: 0))
        expectToJson(exists) == "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"
        
        //MARK: Count
        
        var count = Count(set: Match(index: Ref("indexes/spells_by_element"), terms: "fire"))
        expectToJson(count) == "{\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"
        
        count = Count(set: Match(index: Ref("indexes/spells_by_element") as Expr, terms: "fire"),
                      countEvents: true)
        expectToJson(count) == "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"
        
        count = Count(set: Match(index: Ref("indexes/spells_by_element"), terms: "fire"),
                      countEvents: true)
        expectToJson(count) == "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"
        
        count = Count(set: Match(index: Ref("indexes/spells_by_element"), terms: "fire"),
                      countEvents: true)
        expectToJson(count) == "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"
        
        //MARK: Paginate
        
        let paginate = Paginate(resource: Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")))
        expectToJson(paginate) == "{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}"
        
        let paginate2 = Paginate(resource: Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")),
                                 sources: true)
        expectToJson(paginate2) == "{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"sources\":true}"
        
        let paginate3 = Paginate(resource: Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")),
                                 events: true)
        expectToJson(paginate3) == "{\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}"
        
        let paginate4 = Paginate(resource: Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")),
                                 size: 4)
        expectToJson(paginate4) == "{\"size\":4,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}"
        
        let paginate5 = Paginate(Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")),
                                 size: 4, events: true, sources: true)
        expectToJson(paginate5) == "{\"size\":4,\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"sources\":true}"
        
    }
    
    func testMiscellaneousFunctions(){
        
        //MARK: Equals
        
        expectToJson(Equals(terms: 2, 2, Var("v2"))) == "{\"equals\":[2,2,{\"var\":\"v2\"}]}"
        
        expectToJson(Equals(terms: Match(index: Ref("indexes/spells_by_element"), terms: "fire"))) ==
        "{\"equals\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"
        
        //MARK: Contains
        
        var contains = Contains(pathComponents: "favorites", "foods", inExpr:  ["favorites":
            ["foods":
                ["crunchings",
                 "munchings",
                 "lunchings"] as Arr]
                as Obj] as Obj)
        
        expectToJson(contains) == "{\"contains\":[\"favorites\",\"foods\"],\"in\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}"
        
        
        contains = Contains(path: "favorites", inExpr:  ["favorites":
            ["foods":
                ["crunchings",
                    "munchings",
                    "lunchings"] as Arr]
                as Obj] as Obj)
        
        expectToJson(contains) == "{\"contains\":\"favorites\",\"in\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}"
        
        //MARK: Select
        
        var select = Select(pathComponents: "favorites", "foods", 1, from:
            ["favorites":
                ["foods":
                    ["crunchings",
                        "munchings",
                        "lunchings"] as Arr
                ] as Obj
            ] as Obj)
        expectToJson(select) == "{\"select\":[\"favorites\",\"foods\",1],\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}"
        
        select = Select(path: ["favorites", "foods", 1] as Arr, from:
            ["favorites":
                ["foods":
                    ["crunchings",
                        "munchings",
                        "lunchings"] as Arr
                ] as Obj
            ] as Obj)
        expectToJson(select) == "{\"select\":[\"favorites\",\"foods\",1],\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}"
        
        
        expectToJson(Add(terms: 1, 2, 3)) == "{\"add\":[1,2,3]}"
        
        expectToJson(Multiply(terms: 1, 2, 3)) == "{\"multiply\":[1,2,3]}"
        
        expectToJson(Subtract(terms: 1, 2, 3)) == "{\"subtract\":[1,2,3]}"
        
        expectToJson(Divide(terms: 1, 2, 3)) == "{\"divide\":[1,2,3]}"
        
        expectToJson(Modulo(terms: 1, 2, 3)) == "{\"modulo\":[1,2,3]}"
        
        expectToJson(LT(terms: 1, 2, 3)) == "{\"lt\":[1,2,3]}"
        
        expectToJson(LTE(terms: 1, 2, 3)) == "{\"lte\":[1,2,3]}"
        
        expectToJson(GT(terms: 1, 2, 3)) == "{\"gt\":[1,2,3]}"
        
        expectToJson(GTE(terms: 1, 2, 3)) == "{\"gte\":[1,2,3]}"
        
        expectToJson(And(terms: true, false, false)) == "{\"and\":[true,false,false]}"
        
        expectToJson(Or(terms: true, false, false)) == "{\"or\":[true,false,false]}"
        
        expectToJson(Not(boolExpr: true)) == "{\"not\":true}"
    }
    
    func testSets(){
        
        //MARK: Match
        
        var matchSet = Match(index: Ref("indexes/spells_by_elements"),
                             terms: "fire")
        expectToJson(matchSet) == "{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_elements\"}}"
        
        
        
        matchSet = Match(index: Ref("databases"))
        expectToJson(matchSet) == "{\"match\":{\"@ref\":\"databases\"}}"
        
        
        matchSet = Match(index: Ref("indexes/spells_by_elements"),
                         terms: "fire")
        expectToJson(matchSet) == "{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_elements\"}}"
        
        
        
        matchSet = Match(index: Ref("databases"))
        expectToJson(matchSet) == "{\"match\":{\"@ref\":\"databases\"}}"
        
        //MARK: Union
        
        let union = Union(sets: Match(index: Ref("indexes/spells_by_element"), terms: "fire"),
                          Match(index: Ref("indexes/spells_by_element"), terms: "water"))
        expectToJson(union) == "{\"union\":[{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},{\"terms\":\"water\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}]}"
        
        //MARK: Intersection
        
        let intersection = Intersection(sets: Match(index: Ref("indexes/spells_by_element"), terms: "fire"),
                                        Match(index: Ref("indexes/spells_by_element"), terms: "water"))
        expectToJson(intersection) == "{\"intersection\":[{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},{\"terms\":\"water\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}]}"
        
        //MARK: Difference
        
        let difference = Difference(sets: Match(index: Ref("indexes/spells_by_element"), terms: "fire"),
                                    Match(index: Ref("indexes/spells_by_element"), terms: "water"))
        expectToJson(difference) == "{\"difference\":[{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},{\"terms\":\"water\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}]}"
        
        //MARK: Join
        
        let join = Join(sourceSet: Match(index: Ref("indexes/spells_by_element"),
            terms: "fire"),
                        with: Lambda { value in return  Get(ref: value) })
        expectToJson(join) == "{\"with\":{\"expr\":{\"get\":{\"var\":\"v2\"}},\"lambda\":\"v2\"},\"join\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"
        
    }
    
    func testBasicForms() {
        
        // MARK: Let
        
        Var.resetIndex()
        var letExpr = Let(1) { $0 }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1},\"in\":{\"var\":\"v1\"}}"
        
        Var.resetIndex()
        letExpr = Let(1) { x in
            [x.value, 4] as Arr
        }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1},\"in\":[{\"var\":\"v1\"},4]}"
        
        Var.resetIndex()
        letExpr = Let(1, "Hi!", Create(ref: Ref("databases"), params: ["name": "blog_db"])) { x, y, z in
            Do(exprs: x, y, x, y, z)
        }
        expectToJson(letExpr) == "{\"let\":{\"v3\":{\"create\":{\"@ref\":\"databases\"},\"params\":{\"object\":{\"name\":\"blog_db\"}}},\"v1\":1,\"v2\":\"Hi!\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"}]}}"
        
        
        Var.resetIndex()
        letExpr = Let(1, 2, 3, 4) { x, y, z, a in
            Do(exprs: x, y, z, a)
        }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"}]}}"
        
        
        Var.resetIndex()
        letExpr = Let(1, 2, 3, 4, 5) { x, y, z, a, t in
            Do(exprs: x, y, z, a, t)
        }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4,\"v5\":5},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"}]}}"
        
        
        Var.resetIndex()
        letExpr = Let(1, 2, 3, 4, 5) { x, y, z, a, t in
            Let("Hi") { w in
                Do(exprs: x, y, z, a, t, w)
            }
        }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4,\"v5\":5},\"in\":{\"let\":{\"v6\":\"Hi\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"},{\"var\":\"v6\"}]}}}"
        
        
        // MARK: If
        var ifExpr = If(pred: true, then: "was true", else: "was false")
        expectToJson(ifExpr) ==  "{\"then\":\"was true\",\"if\":true,\"else\":\"was false\"}"
        ifExpr = If(pred: true, then: {
            return "was true"
            }(),
                    else: {
                        return "was false"
            }())
        expectToJson(ifExpr) == "{\"then\":\"was true\",\"if\":true,\"else\":\"was false\"}"
        
        //MARK: Do
        
        let doForm = Do(exprs: Create(ref: Ref("some/ref/1"), params: ["data": ["name": "Hen Wen"] as Obj]),
                        Get(ref: Ref("some/ref/1")))
        expectToJson(doForm) == "{\"do\":[{\"create\":{\"@ref\":\"some\\/ref\\/1\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Hen Wen\"}}}}},{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}]}"
        
        //MARK: Lambda
        
        Var.resetIndex()
        let lambda1 = Lambda { a in a }
        expectToJson(lambda1) == "{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}"
        
        Var.resetIndex()
        let lambda2 = Lambda { a, b in Arr([b.value , a.value]) }
        expectToJson(lambda2) == "{\"expr\":[{\"var\":\"v2\"},{\"var\":\"v1\"}],\"lambda\":[\"v1\",\"v2\"]}"
        
        Var.resetIndex()
        let lambda3 = Lambda { a, _, _ in a }
        expectToJson(lambda3) == "{\"expr\":{\"var\":\"v1\"},\"lambda\":[\"v1\",\"v2\",\"v3\"]}"
        
        Var.resetIndex()
        let lambda4 = Lambda { a in Not(boolExpr: a) }
        expectToJson(lambda4) == "{\"expr\":{\"not\":{\"var\":\"v1\"}},\"lambda\":\"v1\"}"
    }

}
