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
        
        // MARK: Ref
        
        let ref = Ref("some/ref")
        XCTAssertEqual(ref.jsonString, "{\"@ref\":\"some\\/ref\"}")
        
        let ref2: Ref = "some/ref"
        XCTAssertTrue(ref == ref2)
    }
    
    func testArr(){
        
        // MARK: Arr
        let arr: [Any] = [3, "test", Null()]
        XCTAssertEqual(arr.jsonString, "[3,\"test\",null]")
        
        let arr2: Arr = [3, "test", Null()]
        XCTAssertEqual(arr2.jsonString, "[3,\"test\",null]")
        
        let intArr = [1, 2, 3]
        XCTAssertEqual(intArr.jsonString, "[1,2,3]")
        
        let strArray = ["Hi", "Hi2", "Hi3"]
        XCTAssertEqual(strArray.jsonString, "[\"Hi\",\"Hi2\",\"Hi3\"]")
        
        let timestampArray = [Timestamp(timeIntervalSince1970: 0)]
        XCTAssertEqual(timestampArray.jsonString, "[{\"@ts\":\"1970-01-01T00:00:00.000Z\"}]")
        
        let refArray = [Ref("some/ref")]
        XCTAssertEqual(refArray.jsonString, "[{\"@ref\":\"some\\/ref\"}]")
        
        let nsObjcetArr: [NSObject] = [3, "test", Timestamp(timeIntervalSince1970: 0)]
        XCTAssertEqual(nsObjcetArr.jsonString, "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"}]")
        
        let nsObjcetArr2: [NSObject] = [3, "test", Timestamp(timeIntervalSince1970: 0), Double(3.5)]
        XCTAssertEqual(nsObjcetArr2.jsonString, "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5]")

        let complexValue = [3, "test", Timestamp(timeIntervalSince1970: 0), 3.5, [3, "test", Timestamp(timeIntervalSince1970: 0), 3.5]]
        XCTAssertEqual(complexValue.jsonString, "[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5,[3,\"test\",{\"@ts\":\"1970-01-01T00:00:00.000Z\"},3.5]]")

        let complexValue3 = [3, 4, 5, 6, [3, 5, 6, 7]]
        XCTAssertEqual(complexValue3.jsonString, "[3,4,5,6,[3,5,6,7]]")
        
    }
    
    func testObj() {
        
        // MARK: Obj
        let obj: [String: Value] = ["test": 1, "test2": Ref("some/ref")]
        XCTAssertEqual(obj.jsonString, "{\"object\":{\"test2\":{\"@ref\":\"some\\/ref\"},\"test\":1}}")
        
        let obj2: Obj = ["test": 1, "test2": Ref("some/ref")]
        XCTAssertEqual(obj2.jsonString, "{\"object\":{\"test2\":{\"@ref\":\"some\\/ref\"},\"test\":1}}")
        
        var obj3: Obj = [:]
        obj3["test"] = 1
        obj3["test2"] =  Ref("some/ref")
        XCTAssertEqual(obj3, obj2)
        
        XCTAssertTrue(obj3.isEquals(obj.value))
        
        // [String: NSObject]
        let obj4 = ["key": 3, "key2": "test", "key3": Timestamp(timeIntervalSince1970: 0)]
        XCTAssertEqual(obj4.jsonString, "{\"object\":{\"key3\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"},\"key\":3,\"key2\":\"test\"}}")
        
    }
    
    func testArrWithObj() {
        let arr: Arr = [[["test":"value"] as Obj, 2323, true] as Arr, "hi", ["test": "yo","test2": nil as Null] as Obj]
        XCTAssertEqual(arr.jsonString, "[[{\"object\":{\"test\":\"value\"}},2323,true],\"hi\",{\"object\":{\"test2\":null,\"test\":\"yo\"}}]")
    }
    
    func testLiteralValues() {
        
        // MARK: Literal Values
        XCTAssertEqual(true.toJSON() as? Bool, true)
        XCTAssertEqual(false.toJSON() as? Bool, false)
        XCTAssertEqual("test".toJSON() as? String, "test")
        XCTAssertEqual(Int.max.toJSON() as? Int, Int.max)
        XCTAssertEqual(3.14.toJSON() as? Double, Double(3.14))
        XCTAssertEqual(Null().toJSON() as? NSNull, NSNull())
    }
    
    func testBasicForms() {
        
        // MARK: Let
        
        Var.resetIndex()
        let let1 = Let(1) { $0 }
        XCTAssertEqual(let1.jsonString, "{\"let\":{\"v1\":1},\"in\":{\"var\":\"v1\"}}")
        
        Var.resetIndex()
        let let2 = Let(1) { x in
                        [x, 4]
                    }
        XCTAssertEqual(let2.jsonString, "{\"let\":{\"v1\":1},\"in\":[{\"var\":\"v1\"},4]}")
        
        Var.resetIndex()
        let let3 = Let(1, "Hi!", Create(ref: Ref.databases, params: ["name": "blog_db"])) { x, y, z in
                        Do(exprs: x, y, x, y, z)
                   }
        XCTAssertEqual(let3.jsonString,"{\"let\":{\"v3\":{\"create\":{\"@ref\":\"databases\"},\"params\":{\"object\":{\"name\":\"blog_db\"}}},\"v1\":1,\"v2\":\"Hi!\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"}]}}")
        
        
        Var.resetIndex()
        let let4 = Let(1, 2, 3, 4) { x, y, z, a in
                        Do(exprs: x, y, z, a)
                   }
        XCTAssertEqual(let4.jsonString, "{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"}]}}")

        
        Var.resetIndex()
        let let5 = Let(1, 2, 3, 4, 5) { x, y, z, a, t in
                        Do(exprs: x, y, z, a, t)
                   }
        XCTAssertEqual(let5.jsonString, "{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4,\"v5\":5},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"}]}}")
        
        
        Var.resetIndex()
        let let6 = Let(1, 2, 3, 4, 5) { x, y, z, a, t in
                                            Let("Hi") { w in
                                                Do(exprs: x, y, z, a, t, w)
                                            }
                   }
        XCTAssertEqual(let6.jsonString, "{\"let\":{\"v1\":1,\"v2\":2,\"v3\":3,\"v4\":4,\"v5\":5},\"in\":{\"let\":{\"v6\":\"Hi\"},\"in\":{\"do\":[{\"var\":\"v1\"},{\"var\":\"v2\"},{\"var\":\"v3\"},{\"var\":\"v4\"},{\"var\":\"v5\"},{\"var\":\"v6\"}]}}}")
        
        
        // MARK: If
        let if1 = If(pred: true, then: "was true", else: "was false")
        XCTAssertEqual(if1.jsonString,  "{\"then\":\"was true\",\"if\":true,\"else\":\"was false\"}")
        let if2 = If(pred: true, then: {
                                    return "was true"
                                 }(),
                                 else: {
                                    return "was false"
                                 }())
        XCTAssertEqual(if2.jsonString, "{\"then\":\"was true\",\"if\":true,\"else\":\"was false\"}")
        
        //MARK: Do
        
        let doForm = Do(exprs: Create(ref: "some/ref/1", params: ["data": ["name": "Hen Wen"]]),
                               Get(ref: "some/ref/1"))
        XCTAssertEqual(doForm.jsonString, "{\"do\":[{\"create\":{\"@ref\":\"some\\/ref\\/1\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Hen Wen\"}}}}},{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}]}")
        
        //MARK: Lambda
        
        Var.resetIndex()
        let lambda1 = Lambda { a in a }
        XCTAssertEqual(lambda1.jsonString, "{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}")
        
        Var.resetIndex()
        let lambda2 = Lambda { a, b in [b , a] }
        XCTAssertEqual(lambda2.jsonString, "{\"expr\":[{\"var\":\"v2\"},{\"var\":\"v1\"}],\"lambda\":[\"v1\",\"v2\"]}")
  
        Var.resetIndex()
        let lambda3 = Lambda { a, _, _ in a }
        XCTAssertEqual(lambda3.jsonString, "{\"expr\":{\"var\":\"v1\"},\"lambda\":[\"v1\",\"v2\",\"v3\"]}")

        Var.resetIndex()
        let lambda4 = Lambda { a in Not(boolExpr: a) }
        XCTAssertEqual(lambda4.jsonString, "{\"expr\":{\"not\":{\"var\":\"v1\"}},\"lambda\":\"v1\"}")
    }

    func testResourceModifications(){
        
        //MARK: Create
        
        let spell: Obj = ["name": "Mountainous Thunder", "element": "air", "cost": 15]
        var create = Create(ref: "classes/spells",
                         params: ["data": spell])
        XCTAssertEqual(create.jsonString, "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}")
        
        create = Create(ref: "classes/spells",
                            params: ["data": ["name": "Mountainous Thunder", "element": "air", "cost": 15]])
        XCTAssertEqual(create.jsonString, "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}")
        
        create = Create(Expr(Ref("classes/spells")),
                        params: ["data": ["name": "Mountainous Thunder", "element": "air", "cost": 15]])
        XCTAssertEqual(create.jsonString, "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountainous Thunder\",\"cost\":15,\"element\":\"air\"}}}}}")
        
 
        //MARK: Update
        
        var update = Update(ref: "classes/spells/123456",
                         params: ["data": ["name": "Mountain's Thunder", "cost": Null()] as Obj])
        XCTAssertEqual(update.jsonString, "{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}")
        
        update = Update(ref: "classes/spells/123456",
                     params: ["data": ["name": "Mountain's Thunder", "cost": Expr(Null())]])
        XCTAssertEqual(update.jsonString, "{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}")
        
        update = Update(Expr(Ref("classes/spells/123456")),
                        params: ["data": ["name": "Mountain's Thunder", "cost": Expr(Null())]])
        XCTAssertEqual(update.jsonString, "{\"params\":{\"object\":{\"data\":{\"object\":{\"cost\":null,\"name\":\"Mountain\'s Thunder\"}}}},\"update\":{\"@ref\":\"classes\\/spells\\/123456\"}}")
        
        //MARK: Replace
        
        var replaceSpell = spell
        replaceSpell["name"] = "Mountain's Thunder"
        replaceSpell["element"] = ["air", "earth"] as Arr
        replaceSpell["cost"] = 10
        var replace = Replace(ref: "classes/spells/123456",
                           params: ["data": replaceSpell])
        XCTAssertEqual(replace.jsonString, "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}")
        
        
        replace = Replace(ref: "classes/spells/123456",
                              params: ["data": ["name": "Mountain's Thunder", "element": ["air", "earth"], "cost": 10]])
        XCTAssertEqual(replace.jsonString, "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}")

        replace = Replace(Expr(Ref("classes/spells/123456")),
                          params: ["data": ["name": "Mountain's Thunder", "element": ["air", "earth"], "cost": 10]])
        XCTAssertEqual(replace.jsonString, "{\"replace\":{\"@ref\":\"classes\\/spells\\/123456\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain's Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}}}")

        //MARK: Delete
        
        var delete = Delete(ref: "classes/spells/123456")
        XCTAssertEqual(delete.jsonString, "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}")
        
        delete = Delete(Expr(Ref("classes/spells/123456")))
        XCTAssertEqual(delete.jsonString, "{\"delete\":{\"@ref\":\"classes\\/spells\\/123456\"}}")
        
        //MARK: Insert
        
        var insert = Insert(ref: "classes/spells/123456",
                             ts: Timestamp(timeIntervalSince1970: 0),
                         action: .Create,
                         params: ["data": replaceSpell])
        XCTAssertEqual(insert.jsonString, "{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
        
        
        insert = Insert(Expr(Ref("classes/spells/123456")),
                        ts: Expr(Timestamp(timeIntervalSince1970: 0)),
                        action: Expr(Action.Create),
                        params: ["data": ["name": "Mountain's Thunder", "element": ["air", "earth"], "cost": 10]])
        
        XCTAssertEqual(insert.jsonString, "{\"insert\":{\"@ref\":\"classes\\/spells\\/123456\"},\"action\":\"create\",\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"Mountain\'s Thunder\",\"cost\":10,\"element\":[\"air\",\"earth\"]}}}},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
        
        
        //MARK: Remove
        
        var remove = Remove(ref: "classes/spells/123456",
                             ts: Timestamp(timeIntervalSince1970: 0),
                         action: .Create)
        XCTAssertEqual(remove.jsonString, "{\"action\":\"create\",\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
        
        remove = Remove(Expr(Ref("classes/spells/123456")),
                        ts: Expr(Timestamp(timeIntervalSince1970: 0)),
                        action: Expr(Action.Create))
        XCTAssertEqual(remove.jsonString, "{\"action\":\"create\",\"remove\":{\"@ref\":\"classes\\/spells\\/123456\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
    }
    
    
    func testDateAndTimestamp() {
        
        //MARK: Timestamp
        
        let ts = Timestamp(timeIntervalSince1970: 0)
        XCTAssertEqual(ts.jsonString, "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}")
        
        let ts2 = Timestamp(timeInterval: 5.MIN, sinceDate: ts)
        XCTAssertEqual(ts2.jsonString, "{\"@ts\":\"1970-01-01T00:05:00.000Z\"}")
        
        let ts3 = Timestamp(iso8601: "1970-01-01T00:00:00.123Z")
        XCTAssertEqual(ts3?.jsonString, "{\"@ts\":\"1970-01-01T00:00:00.123Z\"}")
        
        let ts4 = Timestamp(iso8601: "1970-01-01T00:00:00Z")
        XCTAssertEqual(ts4?.jsonString, "{\"@ts\":\"1970-01-01T00:00:00.000Z\"}")
        
        //MARK: Date
        
        let date = Date(day: 18, month: 7, year: 1984)
        XCTAssertEqual(date.jsonString, "{\"@date\":\"1984-07-18\"}")
        
        let date2 = Date(iso8601:"1984-07-18")
        XCTAssertNotNil(date2)
        XCTAssertEqual(date2?.jsonString, "{\"@date\":\"1984-07-18\"}")
    }
    
    func testCollections() {
        
        //MARK: Map
        
         Var.resetIndex()
        let map = Map(arr: [1,2,3],
                      lambda: Lambda(vars: "munchings", expr: Expr(Var("munchings"))))
        XCTAssertEqual(map.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"munchings\"},\"lambda\":\"munchings\"}}")
        
        Var.resetIndex()
        let map1 = Map(arr: [1,2,3] as Arr,
                    lambda: { x in
                                x
                            })
        XCTAssertEqual(map1.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}")
        
        Var.resetIndex()
        let map2 = Map(arr: [1,2,3] as [Int]) { $0 }
        XCTAssertEqual(map2.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}")
        
        Var.resetIndex()
        let map3 = [1,2,3].mapFauna { (value: Expr) -> Expr in
            value
        }
        XCTAssertEqual(map3.jsonString, "{\"collection\":[1,2,3],\"map\":{\"expr\":{\"var\":\"v1\"},\"lambda\":\"v1\"}}")

        //MARK: Foreach
        
        Var.resetIndex()
        let foreach = Foreach(arr: [Ref("another/ref/1"), Ref("another/ref/2")],
                           lambda: Lambda(vars: "refData",
                                          expr: Create(ref: Ref("some/ref"),
                                                    params: ["data": ["some": Expr(Var("refData"))]]
                                    )))
        XCTAssertEqual(foreach.jsonString, "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"refData\"}}}}}},\"lambda\":\"refData\"}}")
        
        Var.resetIndex()
        let foreach2 = Foreach(arr: [Ref("another/ref/1"), Ref("another/ref/2")]) { ref in
            Create(ref: "some/ref", params: ["data": ["some": ref]])
                        }
        XCTAssertEqual(foreach2.jsonString, "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}")
        
        Var.resetIndex()
        let foreach3 = [Ref("another/ref/1"), Ref("another/ref/2")].forEachFauna {
                            Create(ref: "some/ref",
                                params: ["data": ["some": $0]])
                        }
        XCTAssertEqual(foreach3.jsonString, "{\"collection\":[{\"@ref\":\"another\\/ref\\/1\"},{\"@ref\":\"another\\/ref\\/2\"}],\"foreach\":{\"expr\":{\"create\":{\"@ref\":\"some\\/ref\"},\"params\":{\"object\":{\"data\":{\"object\":{\"some\":{\"var\":\"v1\"}}}}}},\"lambda\":\"v1\"}}")
        

        //MARK: Filter
        
        Var.resetIndex()
        let filter = Filter(arr: [1,2,3] as Arr, lambda: Lambda(lambda: { i in  Equals(terms: 1, i) }))
        XCTAssertEqual(filter.jsonString, "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}")
        
        Var.resetIndex()
        let filter2 = Filter(arr: [1,2,3] as [Int], lambda: Lambda(lambda: { i in  Equals(terms: 1, i) }))
        XCTAssertEqual(filter2.jsonString, "{\"collection\":[1,2,3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}")
        
        Var.resetIndex()
        let filter3 = Filter(arr: [1,"Hi",3],
                          lambda: Lambda(lambda: { i in
                                                    Equals(terms: 1, i)
                                                 })
        )
        XCTAssertEqual(filter3.jsonString, "{\"collection\":[1,\"Hi\",3],\"filter\":{\"expr\":{\"equals\":[1,{\"var\":\"v1\"}]},\"lambda\":\"v1\"}}")
        
        //MARK: Take
        
        let take = Take(count: 2, collection: [1, 2, 3])
        XCTAssertEqual(take.jsonString, "{\"collection\":[1,2,3],\"take\":2}")
        
        
        let take2 = Take(count: 2, collection: Expr([1, 2, 3]))
        XCTAssertEqual(take2.jsonString, "{\"collection\":[1,2,3],\"take\":2}")

        let take3 = Take(count: 2, collection: [1, "Hi", 3])
        XCTAssertEqual(take3.jsonString, "{\"collection\":[1,\"Hi\",3],\"take\":2}")
        
        //MARK: Drop
        
        let drop = Drop(count: 2, collection: [1,2,3])
        XCTAssertEqual(drop.jsonString, "{\"collection\":[1,2,3],\"drop\":2}")
        
        let drop2 = Drop(count: 2, collection: Expr([1, 2, 3] as [Int]))
        XCTAssertEqual(drop2.jsonString, "{\"collection\":[1,2,3],\"drop\":2}")
        
        let drop3 = Drop(count: 2, collection: [1, "Hi", 3])
        XCTAssertEqual(drop3.jsonString, "{\"collection\":[1,\"Hi\",3],\"drop\":2}")
        
        //MARK: Prepend

        let prepend = Prepend(elements: [1,2,3], toCollection: [4,5,6])
        XCTAssertEqual(prepend.jsonString, "{\"collection\":[1,2,3],\"prepend\":[4,5,6]}")
    
        //MARK: Append
        
        let append = Append(elements: [4,5,6], toCollection: [1,2,3])
        XCTAssertEqual(append.jsonString, "{\"collection\":[4,5,6],\"append\":[1,2,3]}")
    }
    
    func testResourceRetrievals(){
        
        //MARK: Get
        
        let ref: Ref = "some/ref/1"
        var get = Get(ref: ref)
        XCTAssertEqual(get.jsonString, "{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        get = Get(Expr(ref))
        XCTAssertEqual(get.jsonString, "{\"get\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        get = Get(ref: ref, ts: Timestamp(timeIntervalSince1970: 0))
        XCTAssertEqual(get.jsonString, "{\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"},\"get\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        get = Get(Expr(ref), ts: Expr(Timestamp(timeIntervalSince1970: 0)))
        XCTAssertEqual(get.jsonString, "{\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"},\"get\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        //MARK: Exists
        
        var exists = Exists(ref: ref)
        XCTAssertEqual(exists.jsonString, "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        exists = Exists(Expr(ref))
        XCTAssertEqual(exists.jsonString, "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"}}")
        
        exists = Exists(ref: ref, ts: Timestamp(timeIntervalSince1970: 0))
        XCTAssertEqual(exists.jsonString, "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
        
        exists = Exists(Expr(ref), ts: Expr(Timestamp(timeIntervalSince1970: 0)))
        XCTAssertEqual(exists.jsonString, "{\"exists\":{\"@ref\":\"some\\/ref\\/1\"},\"ts\":{\"@ts\":\"1970-01-01T00:00:00.000Z\"}}")
        
        //MARK: Count
        
        var count = Count(set: Match(index: "indexes/spells_by_element", terms: "fire"))
        XCTAssertEqual(count.jsonString, "{\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
        count = Count(set: Match(index: "indexes/spells_by_element", terms: "fire"),
                           countEvents: true)
        XCTAssertEqual(count.jsonString, "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
        count = Count(set: Match(index: "indexes/spells_by_element", terms: "fire"),
                           countEvents: true)
        XCTAssertEqual(count.jsonString, "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
        count = Count(set: Match(index: "indexes/spells_by_element", terms: "fire"),
                      countEvents: Expr(true))
        XCTAssertEqual(count.jsonString, "{\"events\":true,\"count\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
        //MARK: Paginate
        
        let paginate = Paginate(resource: Union(sets: Match(index: "indexes/some_index", terms: "term"),
                                                       Match(index: "indexes/some_index", terms: "term2")))
        XCTAssertEqual(paginate.jsonString, "{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")
        
        let paginate2 = Paginate(resource: Union(sets: Match(index: "indexes/some_index", terms: "term"),
                                          Match(index: "indexes/some_index", terms: "term2")),
                                 sources: true)
        XCTAssertEqual(paginate2.jsonString, "{\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"sources\":true}")
        
        let paginate3 = Paginate(resource: Union(sets: Match(index: "indexes/some_index", terms: "term"),
                                                      Match(index: "indexes/some_index", terms: "term2")),
                                 events: true)
        XCTAssertEqual(paginate3.jsonString, "{\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")
        
        let paginate4 = Paginate(resource: Union(sets: Match(index: "indexes/some_index", terms: "term"),
                                                       Match(index: "indexes/some_index", terms: "term2")),
                                 size: 4)
        XCTAssertEqual(paginate4.jsonString, "{\"size\":4,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]}}")
        
        let paginate5 = Paginate(Union(sets: Match(index: "indexes/some_index", terms: "term"),
            Match(index: "indexes/some_index", terms: "term2")),
                                 size: Expr(4), events: Expr(true), sources: Expr(true))
        XCTAssertEqual(paginate5.jsonString, "{\"size\":4,\"events\":true,\"paginate\":{\"union\":[{\"terms\":\"term\",\"match\":{\"@ref\":\"indexes\\/some_index\"}},{\"terms\":\"term2\",\"match\":{\"@ref\":\"indexes\\/some_index\"}}]},\"sources\":true}")
        
    }
    
    
    func testSets(){
        
        //MARK: Match
        
        let matchSet = Match(index: "indexes/spells_by_elements",
                                terms: "fire")
        XCTAssertEqual(matchSet.jsonString, "{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_elements\"}}")
        
        //MARK: Union
        
        let union = Union(sets: Match(index: "indexes/spells_by_element", terms: "fire"),
                                Match(index: "indexes/spells_by_element", terms: "water"))
        XCTAssertEqual(union.jsonString, "{\"union\":[{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},{\"terms\":\"water\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}]}")
        
        //MARK: Intersection
        
        let intersection = Intersection(sets: Match(index: "indexes/spells_by_element", terms: "fire"),
                                              Match(index: "indexes/spells_by_element", terms: "water"))
        XCTAssertEqual(intersection.jsonString, "{\"intersection\":[{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},{\"terms\":\"water\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}]}")
        
        //MARK: Difference
        
        let difference = Difference(sets: Match(index: "indexes/spells_by_element", terms: "fire"),
                                          Match(index: "indexes/spells_by_element", terms: "water"))
        XCTAssertEqual(difference.jsonString, "{\"difference\":[{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}},{\"terms\":\"water\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}]}")
        
        //MARK: Join
        
        let lambda_ = Lambda { value in return  Get(value) }
        
        let join = Join(sourceSet: Match(index: Ref("indexes/spells_by_element"),
                                            terms: "fire"),
                        with: lambda_)
        XCTAssertEqual(join.jsonString, "{\"with\":{\"expr\":{\"get\":{\"var\":\"v2\"}},\"lambda\":\"v2\"},\"join\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
    }
    
    func testMiscellaneousFunctions(){
        
        let equals = Equals(terms: 2, 2, Expr(Var("v2")))
        XCTAssertEqual(equals.jsonString, "{\"equals\":[2,2,{\"var\":\"v2\"}]}")
        
        let equals2 = Equals(terms: Match(index: "indexes/spells_by_element", terms: "fire"))
        XCTAssertEqual(equals2.jsonString, "{\"equals\":{\"terms\":\"fire\",\"match\":{\"@ref\":\"indexes\\/spells_by_element\"}}}")
        
        let contains = Contains(path: "favorites", "foods", inExpr:  ["favorites":
            ["foods":
                ["crunchings",
                    "munchings",
                    "lunchings"]
                ]
            ])
        
        XCTAssertEqual(contains.jsonString, "{\"contains\":[\"favorites\",\"foods\"],\"in\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}")
        
        
        let contains2 = Contains(path: "favorites", inExpr:  ["favorites":
            ["foods":
                ["crunchings",
                    "munchings",
                    "lunchings"]
                ]
            ])
        
        XCTAssertEqual(contains2.jsonString, "{\"contains\":\"favorites\",\"in\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}")
        
        //MARK: Select
        
        let select = Select(path: "favorites", "foods", 1, from:
            ["favorites":
                ["foods":
                    ["crunchings",
                        "munchings",
                        "lunchings"]
                    ]
                ])
        XCTAssertEqual(select.jsonString, "{\"select\":[\"favorites\",\"foods\",1],\"from\":{\"object\":{\"favorites\":{\"object\":{\"foods\":[\"crunchings\",\"munchings\",\"lunchings\"]}}}}}")
    }
    
}
