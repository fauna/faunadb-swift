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
        var arr2 = Arr(3, "test", Null(), 2.4)
        let arr2Copy =  arr2
        expect(arr2 == arr2Copy).to(beTrue())
        expectToJson(arr2) == "[3,\"test\",null,2.4]"
        arr2.replaceSubrange(1..<3, with: ["FaunaDB"])
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

        expectToJson(Arr([1, 2, 3])) == "[1,2,3]"

        expectToJson(Arr(["Hi", "Hi2", "Hi3"])) == "[\"Hi\",\"Hi2\",\"Hi3\"]"

        expectToJson(Arr([Timestamp(timeIntervalSince1970: 0)])) == "[{\"@ts\":\"1970-01-01T00:00:00.000Z\"}]"

        expectToJson(Arr([Ref("some/ref")])) == "[{\"@ref\":\"some\\/ref\"}]"

        let valueArr: [ValueConvertible] = [3, "test", Timestamp(timeIntervalSince1970: 0), Double(3.5)]
        expectToJson(Arr(valueArr)) == "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5]"

        let complexValue = Arr(3, "test", Timestamp(timeIntervalSince1970: 0), 3.5, Arr(3, "test", Timestamp(timeIntervalSince1970: 0), 3.5))

        expectToJson(complexValue) == "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5,[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5]]"

        expectToJson(Arr(3, 4, 5, 6, Arr(3, 5, 6, 7))) == "[3,4,5,6,[3,5,6,7]]"

        expectToJson(Arr(Arr(3, 5, 6, 7))) == "[[3,5,6,7]]"

        let intArr = Arr(3, 5, 6, 7)
        expectToJson(Arr(intArr)) == "[[3,5,6,7]]"

    }

    func testObj() {

        // MARK: Obj
        let obj = Obj(["test": 1, "test2": Ref("some/ref")])
        expectToJson(obj).to(satisfyAnyOf(equal("{\"object\":{\"test\":1,\"test2\":{\"@ref\":\"some\\/ref\"}}}"), equal("{\"object\":{\"test2\":{\"@ref\":\"some\\/ref\"},\"test\":1}}")))

        var obj2 = Obj([:])
        obj2["test"] = 1
        obj2["test2"] =  Ref("some/ref")
        expect(obj2) == obj

        let obj3 = Obj(["key": 3, "key2": "test", "key3": Timestamp(timeIntervalSince1970: 0)])
        expectToJson(obj3) == "{\"object\":{\"key2\":\"test\",\"key\":3,\"key3\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}}"


        let obj4 = Obj(["key1": 1, "key2": 2])
        expectToJson(obj4) == "{\"object\":{\"key1\":1,\"key2\":2}}"

        let obj5 = Obj(["key1": 1, "key2": "faunaDB"])
        expectToJson(obj5) == "{\"object\":{\"key1\":1,\"key2\":\"faunaDB\"}}"
    }

    func testArrWithObj() {
        let arr = Arr(Arr(Obj(["test":"value"]), 2323, true), "hi", Obj(["test2": Null(),"test": "yo"]))
        expectToJson(arr).to(satisfyAnyOf(equal("[[{\"object\":{\"test\":\"value\"}},2323,true],\"hi\",{\"object\":{\"test\":\"yo\",\"test2\":null}}]"), equal("[[{\"object\":{\"test\":\"value\"}},2323,true],\"hi\",{\"object\":{\"test2\":null,\"test\":\"yo\"}}]")))
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

        let ts2 = Timestamp(timeInterval: 5.MIN, since: ts)
        expectToJson(ts2) == "{\"@ts\":\"1970-01-01T00:05:00.000Z\"}"

        let ts3 = Timestamp(iso8601: "1970-01-01T00:00:00.123Z")
        expectToJson(ts3) == "{\"@ts\":\"1970-01-01T00:00:00.123Z\"}"

        let ts4 = Timestamp(iso8601: "1970-01-01T00:00:00Z")
        expectToJson(ts4) == "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}"

        //MARK: Date

        let date = FaunaDB.Date(day: 18, month: 7, year: 1984)
        expectToJson(date) == "{\"@date\":\"1984-07-18\"}"

        let date2 = FaunaDB.Date(iso8601:"1984-07-18")
        XCTAssertNotNil(date2)
        expectToJson(date2) == "{\"@date\":\"1984-07-18\"}"
    }

    func testStringFunctions() {

        //MARK: Concat

        expectToJson(Concat(strList: Arr("Hen", "Wen"))) == "{\"concat\":[\"Hen\",\"Wen\"]}"
        expectToJson(Concat(strList: Arr("Hen", "Wen"), separator: " ")) == "{\"concat\":[\"Hen\",\"Wen\"],\"separator\":\" \"}"

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

        let spell = Obj(["name": "Mountainous Thunder", "element": "air", "cost": 15])
        var create = Create(ref: Ref("classes/spells"),
                            params: Obj(["data": spell]))
        expectToJson(create).to(satisfyAnyOf(equal("{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"element\":\"air\",\"name\":\"Mountainous Thunder\",\"cost\":15}}}}}"), equal("{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}")))

        create = Create(ref: Ref("classes/spells"),
                        params: Obj(["data": Obj(["name": "Mountainous Thunder", "element": "air", "cost": 15])]))
        expectToJson(create).to(satisfyAnyOf(equal("{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"element\":\"air\",\"name\":\"Mountainous Thunder\",\"cost\":15}}}}}"), equal("{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}")))
        
        
        //MARK: Update

        let update = Update(ref: Ref("classes/spells/123456"),
                            params: Obj(["data": Obj(["name": "Mountain's Thunder", "cost": Null()])]))
        expectToJson(update).to(satisfyAnyOf(equal("{\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":null}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}"), equal("{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}")))

        //MARK: Replace

        var replaceSpell = spell
        replaceSpell["name"] = "Mountain's Thunder"
        replaceSpell["element"] = Arr("air", "earth")
        replaceSpell["cost"] = 10
        var replace = Replace(ref: Ref("classes/spells/123456"),
                              params: Obj(["data": replaceSpell]))
        expectToJson(replace).to(satisfyAnyOf(equal("{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"element\":[\"air\",\"earth\"],\"name\":\"Mountain's Thunder\",\"cost\":10}}}}}"), equal("{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}")))


        replace = Replace(ref: Ref("classes/spells/123456"),
                          params: Obj(["data": Obj(["name": "Mountain's Thunder", "element": Arr("air", "earth"), "cost": 10])]))
        expectToJson(replace).to(satisfyAnyOf(equal("{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"element\":[\"air\",\"earth\"],\"name\":\"Mountain's Thunder\",\"cost\":10}}}}}"), equal("{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}")))
        
        //MARK: Delete

        var delete = Delete(ref: Ref("classes/spells/123456"))

        expectToJson(delete) == "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}"

        delete = Delete(ref: Ref("classes/spells/123456"))

        expectToJson(delete) == "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}"

        //MARK: Insert
        
        var insert = Insert(ref: Ref("classes/spells/123456"),
                            ts: Timestamp(timeIntervalSince1970: 0),
                            action: .Create,
                            params: Obj(["data": replaceSpell]))

        expectToJson(insert).to(satisfyAnyOf(equal("{\"params\":{\"object\":{\"data\":{\"object\":{\"element\":[\"air\",\"earth\"],\"name\":\"Mountain\'s Thunder\",\"cost\":10}}}},\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"), equal("{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")))

        insert = Insert(ref: Ref("classes/spells/123456"),
                        ts: Timestamp(timeIntervalSince1970: 0),
                        action: Action.Create,
                        params: Obj(["data": Obj(["name": "Mountain's Thunder", "element": Arr("air", "earth"), "cost": 10])]))

        expectToJson(insert).to(satisfyAnyOf(equal("{\"params\":{\"object\":{\"data\":{\"object\":{\"element\":[\"air\",\"earth\"],\"name\":\"Mountain\'s Thunder\",\"cost\":10}}}},\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"), equal("{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")))

        //MARK: Remove

        let remove = Remove(ref: Ref("classes/spells/123456"),
                            ts: Timestamp(timeIntervalSince1970: 0),
                            action: .Create)
        expectToJson(remove).to(satisfyAnyOf(equal("{\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"), equal("{\"action\":\"create\",\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")))
    }

    func testCollections() {

        //MARK: Map

        Var.resetIndex()
        var map = Map(collection: Arr(1,2,3),
                      lambda: Lambda(vars: Var("munchings"), expr: Var("munchings")))
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"munchings\"},\"lambda\":\"munchings\"}}"

        Var.resetIndex()
        map = Map(collection: Arr(1,2,3)) { x in
                                                x
                                          }
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}"

        Var.resetIndex()
        map = Map(collection: Arr(1,2,3)) { $0 }
        expectToJson(map) == "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}"


        //MARK: Foreach

        Var.resetIndex()
        var foreach = Foreach(collection: Arr(Ref("another/ref/1"), Ref("another/ref/2")),
                              lambda: Lambda(vars: Var("refData"),
                                expr: Create(ref: Ref("some/ref"),
                                    params: Obj(["data": Obj(["some": Var("refData")])])
                                )))
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"refData\"}}}}}},\"lambda\":\"refData\"}}"

        Var.resetIndex()
        foreach = Foreach(collection: Arr(Ref("another/ref/1"), Ref("another/ref/2"))) { ref in
            Create(ref: Ref("some/ref"), params: Obj(["data": Obj(["some": ref])]))
        }
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}"

        Var.resetIndex()
        foreach = Foreach(collection: Arr(Ref("another/ref/1"), Ref("another/ref/2"))) {
            Create(ref: Ref("some/ref"), params: Obj(["data": Obj(["some": $0])]))
        }
        expectToJson(foreach) == "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}"

        //MARK: Filter

        Var.resetIndex()
        var filter = Filter(collection: Arr(1,2,3), lambda: Lambda(lambda: { i in Equals(terms: 1, i) }))
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"

        Var.resetIndex()
        filter = Filter(collection: Arr(1,2,3)) { i in  Equals(terms: 1, i) }
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"

        Var.resetIndex()
        filter = Filter(collection: Arr(1,2,3)) { Equals(terms: 1, $0) }
        expectToJson(filter) == "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"

        Var.resetIndex()
        filter = Filter(collection: Arr(1,"Hi",3),
                        lambda: Lambda(lambda: { i in
                            Equals(terms: 1, i)
                        })
        )
        expectToJson(filter) == "{\"collection\":[1,\"Hi\",3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}"

        //MARK: Take

        let take = Take(count: 2, collection: Arr(1, 2, 3))
        expectToJson(take) == "{\"collection\":[1,2,3],\"take\":2}"


        let take2 = Take(count: 2 as Expr, collection: Arr(1, 2, 3))
        expectToJson(take2) == "{\"collection\":[1,2,3],\"take\":2}"

        let take3 = Take(count: 2, collection: Arr(1, "Hi", 3))
        expectToJson(take3) == "{\"collection\":[1,\"Hi\",3],\"take\":2}"

        //MARK: Drop

        let drop = Drop(count: 2, collection: Arr(1,2,3))
        expectToJson(drop).to(satisfyAnyOf(equal("{\"drop\":2,\"collection\":[1,2,3]}"), equal("{\"collection\":[1,2,3],\"drop\":2}")))

        let drop2 = Drop(count: 2 as Expr, collection: Arr(1, 2, 3))
        expectToJson(drop2).to(satisfyAnyOf(equal("{\"drop\":2,\"collection\":[1,2,3]}"), equal("{\"collection\":[1,2,3],\"drop\":2}")))

        let drop3 = Drop(count: 2, collection: Arr(1, "Hi", 3))
        expectToJson(drop3).to(satisfyAnyOf(equal("{\"drop\":2,\"collection\":[1,\"Hi\",3]}"), equal("{\"collection\":[1,\"Hi\",3],\"drop\":2}")))

        //MARK: Prepend

        let prepend = Prepend(elements: Arr(1,2,3), toCollection: Arr(4,5,6))
        expectToJson(prepend) == "{\"collection\":[1,2,3],\"prepend\":[4,5,6]}"

        //MARK: Append

        let append = Append(elements: Arr(4,5,6), toCollection: Arr(1,2,3))
        expectToJson(append) == "{\"collection\":[4,5,6],\"append\":[1,2,3]}"
        
    }

    func testResourceRetrievals(){

        //MARK: Get

        let ref = Ref("some/ref/1")
        var get = Get(ref: ref)
        expectToJson(get) == "{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}"

        get = Get(ref: ref, ts: Timestamp(timeIntervalSince1970: 0))
        expectToJson(get).to(satisfyAnyOf(equal("{\"get\":{\"@ref\":\"some\\/ref\\/1\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"), equal("{\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"},\"get\":{\"@ref\":\"some\\/ref\\/1\"}}")))

        //MARK: Exists

        var exists = Exists(ref: ref)
        expectToJson(exists) == "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"}}"

        exists = Exists(ref: ref, ts: Timestamp(timeIntervalSince1970: 0))
        expectToJson(exists) == "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}"

        //MARK: Count

        var count = Count(set: Match(index: Ref("indexes/spells_by_element"), terms: "fire"))
        expectToJson(count) == "{\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"

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
        expectToJson(paginate3).to(satisfyAnyOf(equal("{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"events\":true}"), equal("{\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")))
        
        let paginate4 = Paginate(resource: Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")),
                                 size: 4)
        expectToJson(paginate4).to(satisfyAnyOf(equal("{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"size\":4}"), equal("{\"size\":4,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")))

        let paginate5 = Paginate(Union(sets: Match(index: Ref("indexes/some_index"), terms: "term"),
            Match(index: Ref("indexes/some_index"), terms: "term2")),
                                 size: 4, events: true, sources: true)
        expectToJson(paginate5).to(satisfyAnyOf(equal("{\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"size\":4,\"sources\":true}"), equal("{\"size\":4,\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"sources\":true}")))
    }

    func testMiscellaneousFunctions(){

        //MARK: Equals

        expectToJson(Equals(terms: 2, 2, Var("v2"))) == "{\"equals\":[2,2,{\"var\":\"v2\"}]}"

        expectToJson(Equals(terms: Match(index: Ref("indexes/spells_by_element"), terms: "fire"))) ==
        "{\"equals\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}"

        //MARK: Contains

        var contains = Contains(pathComponents: "favorites", "foods", inExpr:  Obj(["favorites":
            Obj(["foods":
                Arr("crunchings", "munchings", "lunchings")]
                )]))

        expectToJson(contains) == "{\"contains\":[\"favorites\",\"foods\"],\"in\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}"


        contains = Contains(path: "favorites", inExpr: Obj(["favorites":
            Obj(["foods":
                Arr("crunchings", "munchings", "lunchings")]
                )]))

        expectToJson(contains) == "{\"contains\":\"favorites\",\"in\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}"

        //MARK: Select

        var select = Select(pathComponents: "favorites", "foods", 1, from:
            Obj(["favorites":
                Obj(["foods":
                    Arr("crunchings",
                        "munchings",
                        "lunchings")
                ])
            ]))
        expectToJson(select).to(satisfyAnyOf(equal("{\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}},\"select\":[\"favorites\",\"foods\",1]}"), equal("{\"select\":[\"favorites\",\"foods\",1],\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}")))

        select = Select(path: Arr("favorites", "foods", 1), from:
            Obj(["favorites":
                Obj(["foods":
                    Arr("crunchings", "munchings", "lunchings")
                ])
            ]))
        expectToJson(select).to(satisfyAnyOf(equal("{\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}},\"select\":[\"favorites\",\"foods\",1]}"), equal("{\"select\":[\"favorites\",\"foods\",1],\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}")))
        
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

        Var.resetIndex()
        let join = Join(sourceSet: Match(index: Ref("indexes/spells_by_element"),
            terms: "fire"),
                        with: Lambda { value in return  Get(ref: value) })
        expectToJson(join).to(satisfyAnyOf(equal("{\"join\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},\"with\":{\"expr\":{\"get\":{\"var\":\"v1\"}},\"lambda\":\"v1\"}}"), equal("{\"with\":{\"expr\":{\"get\":{\"var\":\"v1\"}},\"lambda\":\"v1\"},\"join\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")))
    }

    func testBasicForms() {

        // MARK: Let

        Var.resetIndex()
        var letExpr = Let(1) { $0 }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1},\"in\":{\"var\":\"v1\"}}"

        Var.resetIndex()
        letExpr = Let(1) { x in
            Arr(x, 4)
        }
        expectToJson(letExpr) == "{\"let\":{\"v1\":1},\"in\":[{\"var\":\"v1\"},4]}"

        Var.resetIndex()
        letExpr = Let(1, "Hi!", Create(ref: Ref("databases"), params: Obj(["name": "blog_db"]))) { x, y, z in
            Do(exprs: x, y, x, y, z)
        }
        expectToJson(letExpr).to(satisfyAnyOf(equal("{\"let\":{\"v3\":{\"create\":{\"@ref\":\"databases\"},\"params\":{\"object\":{\"name\":\"blog_db\"}}},\"v2\":\"Hi!\",\"v1\":1},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"}]}}"), equal("{\"let\":{\"v3\":{\"create\":{\"@ref\":\"databases\"},\"params\":{\"object\":{\"name\":\"blog_db\"}}},\"v1\":1,\"v2\":\"Hi!\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"}]}}")))
        
        Var.resetIndex()
        letExpr = Let(1, 2, 3, 4) { x, y, z, a in
            Do(exprs: x, y, z, a)
        }
        expectToJson(letExpr).to(satisfyAnyOf(equal("{\"let\":{\"v4\":4,\"v3\":3,\"v2\":2,\"v1\":1},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"}]}}"), equal("{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"}]}}")))
        
        
        Var.resetIndex()
        letExpr = Let(1, 2, 3, 4, 5) { x, y, z, a, t in
            Do(exprs: x, y, z, a, t)
        }
        expectToJson(letExpr).to(satisfyAnyOf(equal("{\"let\":{\"v5\":5,\"v4\":4,\"v3\":3,\"v2\":2,\"v1\":1},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"}]}}"), equal("{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4,\"v5\":5},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"}]}}")))
        
        
        Var.resetIndex()
        letExpr = Let(1, 2, 3, 4, 5) { x, y, z, a, t in
            Let("Hi") { w in
                Do(exprs: x, y, z, a, t, w)
            }
        }
        expectToJson(letExpr).to(satisfyAnyOf(equal("{\"let\":{\"v5\":5,\"v4\":4,\"v3\":3,\"v2\":2,\"v1\":1},\"in\":{\"let\":{\"v6\":\"Hi\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"},{\"var\":\"v6\"}]}}}"), equal("{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4,\"v5\":5},\"in\":{\"let\":{\"v6\":\"Hi\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"},{\"var\":\"v6\"}]}}}")))
        
        // MARK: If
        var ifExpr = If(pred: true, then: "was true", else: "was false")
        expectToJson(ifExpr).to(satisfyAnyOf(equal("{\"if\":true,\"then\":\"was true\",\"else\":\"was false\"}"), equal("{\"then\":\"was true\",\"if\":true,\"else\":\"was false\"}")))
        ifExpr = If(pred: true, then: {
                    return "was true"
                 }(),
                else: {
                    return "was false"
                }())
        expectToJson(ifExpr).to(satisfyAnyOf(equal("{\"if\":true,\"then\":\"was true\",\"else\":\"was false\"}"), equal("{\"then\":\"was true\",\"if\":true,\"else\":\"was false\"}")))
        
        //MARK: Do
        
        let doForm = Do(exprs: Create(ref: Ref("some/ref/1"), params: Obj(["data": Obj(["name": "Hen Wen"])])),
                        Get(ref: Ref("some/ref/1")))
        expectToJson(doForm) == "{\"do\":[{\"create\":{\"@ref\":\"some\\/ref\\/1\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Hen Wen\"}}}}},{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}]}"
        
        //MARK: Lambda
        
        Var.resetIndex()
        let lambda1 = Lambda { a in a }
        expectToJson(lambda1) == "{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}"
        
        Var.resetIndex()
        let lambda2 = Lambda { a, b in Arr(b , a) }
        expectToJson(lambda2) == "{\"expr\":[{\"var\":\"v2\"},{\"var\":\"v1\"}],\"lambda\":[\"v1\",\"v2\"]}"
        
        Var.resetIndex()
        let lambda3 = Lambda { a, _, _ in a }
        expectToJson(lambda3) == "{\"expr\":{\"var\":\"v1\"},\"lambda\":[\"v1\",\"v2\",\"v3\"]}"
        
        Var.resetIndex()
        let lambda4 = Lambda { a in Not(boolExpr: a) }
        expectToJson(lambda4) == "{\"expr\":{\"not\":{\"var\":\"v1\"}},\"lambda\":\"v1\"}"
        
    }

}
