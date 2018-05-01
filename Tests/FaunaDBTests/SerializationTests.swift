import XCTest

@testable import FaunaDB

fileprivate struct Point {
    let x, y: Int
}

extension Point: FaunaDB.Encodable {
    func encode() -> Expr {
        return Obj("x" => x, "y" => y)
    }
}

class SerializationTests: XCTestCase {

    override func setUp() {
        Var.resetIndex()
    }

    func testString() {
        assert(expr: StringV("a string"), toBecome: "\"a string\"")
        assert(expr: "a string", toBecome: "\"a string\"")
    }

    func testLong() {
        assert(expr: LongV(42), toBecome: "42")
        assert(expr: 42, toBecome: "42")
    }

    func testDouble() {
        assert(expr: DoubleV(42.3), toBecome: "42.3")
        assert(expr: 42.3, toBecome: "42.3")
    }

    func testBoolean() {
        assert(expr: BooleanV(true), toBecome: "true")
        assert(expr: BooleanV(false), toBecome: "false")
        assert(expr: true, toBecome: "true")
        assert(expr: false, toBecome: "false")
    }

    func testRefV() {
        assert(expr: RefV("spells", class: Native.CLASSES),
               toBecome: "{\"@ref\":{\"id\":\"spells\",\"class\":{\"@ref\":{\"id\":\"classes\"}}}}")
        assert(expr: RefV("42", class: RefV("spells", class: Native.CLASSES)),
               toBecome: "{\"@ref\":{\"id\":\"42\",\"class\":{\"@ref\":{\"id\":\"spells\",\"class\":{\"@ref\":{\"id\":\"classes\"}}}}}}")
    }

    func testSetRefV() {
        assert(
            expr: SetRefV(["match": RefV("all_spells", class: Native.INDEXES)]),
            toBecome: "{\"@set\":{\"match\":{\"@ref\":{\"id\":\"all_spells\",\"class\":{\"@ref\":{\"id\":\"indexes\"}}}}}}"
        )
    }

    func testTimeV() {
        assert(expr: TimeV(date: Date(timeIntervalSince1970: 5 * 60)), toBecome: "{\"@ts\":\"1970-01-01T00:05:00.000000000Z\"}")
        assert(expr: TimeV(date: Date(timeIntervalSince1970: 1)), toBecome: "{\"@ts\":\"1970-01-01T00:00:01.000000000Z\"}")
        assert(expr: TimeV(HighPrecisionTime(secondsSince1970: 0, millisecondsOffset: 1)), toBecome: "{\"@ts\":\"1970-01-01T00:00:00.001000000Z\"}")
        assert(expr: TimeV(HighPrecisionTime(secondsSince1970: 0, nanosecondsOffset: 1_000)), toBecome: "{\"@ts\":\"1970-01-01T00:00:00.000001000Z\"}")
        assert(expr: TimeV(HighPrecisionTime(secondsSince1970: 0, nanosecondsOffset: 1)), toBecome: "{\"@ts\":\"1970-01-01T00:00:00.000000001Z\"}")
        assert(expr: HighPrecisionTime(secondsSince1970: 0, nanosecondsOffset: 1), toBecome: "{\"@ts\":\"1970-01-01T00:00:00.000000001Z\"}")
        assert(expr: Date(timeIntervalSince1970: 0), toBecome: "{\"@ts\":\"1970-01-01T00:00:00.000000000Z\"}")
    }

    func testTimeVOverflow() {
        assert(expr: HighPrecisionTime(secondsSince1970: 0, millisecondsOffset: 1_001), toBecome: "{\"@ts\":\"1970-01-01T00:00:01.001000000Z\"}")
        assert(expr: HighPrecisionTime(secondsSince1970: 0, microsecondsOffset: 1_001_001), toBecome: "{\"@ts\":\"1970-01-01T00:00:01.001001000Z\"}")
        assert(expr: HighPrecisionTime(secondsSince1970: 0, nanosecondsOffset: 1_001_001_001), toBecome: "{\"@ts\":\"1970-01-01T00:00:01.001001001Z\"}")

    }

    func testDateV() {
        assert(expr: DateV(Date(timeIntervalSince1970: 0)), toBecome: "{\"@date\":\"1970-01-01\"}")
    }

    func testNullV() {
        assert(expr: NullV(), toBecome: "null")
        assert(expr: nil, toBecome: "null")
    }

    func testObjectV() {
        assert(expr: ObjectV(["key": StringV("value")]), toBecome: "{\"object\":{\"key\":\"value\"}}")
    }

    func testArrayV() {
        assert(expr: ArrayV([StringV("a"), LongV(10)]), toBecome: "[\"a\",10]")
    }

    func testBytesV() {
        assert(expr: BytesV(fromArray: [1, 2, 3, 4]), toBecome: "{\"@bytes\":\"AQIDBA==\"}")
    }

    func testQueryV() {
        assert(expr: QueryV(.object(["lambda":.string("x"), "expr":.object(["var":.string("x")])])),
               toBecome: "{\"@query\":{\"lambda\":\"x\",\"expr\":{\"var\":\"x\"}}}")
    }

    func testEncodable() {
        assert(expr: Point(x: 10, y: 4), toBecome: "{\"object\":{\"y\":4,\"x\":10}}")
    }

    func testObj() {
        assert(
            expr: Obj(wrap: [
                "k1": "v1",
                "k2": 10,
                "k3": nil
            ]),
            toBecome: "{\"object\":{\"k2\":10,\"k3\":null,\"k1\":\"v1\"}}"
        )

        assert(
            expr: Obj(
                ("k1", "v1"),
                ("k2", 10),
                ("k3", nil)
            ),
            toBecome: "{\"object\":{\"k2\":10,\"k3\":null,\"k1\":\"v1\"}}"
        )

        assert(
            expr: Obj(
                "k1" => "v1",
                "k2" => 10,
                "k3" => nil
            ),
            toBecome: "{\"object\":{\"k2\":10,\"k3\":null,\"k1\":\"v1\"}}"
        )
    }

    func testArr() {
        assert(
            expr: Arr(wrap: ["a string", 1, 10.19, false, nil]),
            toBecome: "[\"a string\",1,10.19,false,null]"
        )

        assert(
            expr: Arr("a string", 1, 10.19, false, nil),
            toBecome: "[\"a string\",1,10.19,false,null]"
        )
    }

    func testAbort() {
        assert(
            expr: Abort("abort message"),
            toBecome: "{\"abort\":\"abort message\"}"
        )
    }

    func testRef() {
        assert(
            expr: Ref("classes/spells/42"),
            toBecome: "{\"@ref\":\"classes\\/spells\\/42\"}"
        )

        assert(
            expr: Ref(class: "classes/spells", id: "42"),
            toBecome: "{\"ref\":\"classes\\/spells\",\"id\":\"42\"}"
        )
    }

    func testLet() {
        assert(
            expr: Let(bindings: [("a", 10)], in: Var("a")),
            toBecome: "{\"let\":{\"a\":10},\"in\":{\"var\":\"a\"}}"
        )

        assert(
            expr: Let(bindings: ["a" => 10], in: Var("a")),
            toBecome: "{\"let\":{\"a\":10},\"in\":{\"var\":\"a\"}}"
        )

        assert(
            expr: Let(bindings: "a" => 10) { Var("a") },
            toBecome: "{\"let\":{\"a\":10},\"in\":{\"var\":\"a\"}}"
        )

        assert(
            expr: Let(1) { Arr($0) },
            toBecome: "{\"let\":{\"v1\":1},\"in\":[{\"var\":\"v1\"}]}"
        )

        assert(
            expr: Let(1, 2) { Arr($0, $1) },
            toBecome: "{\"let\":{\"v3\":2,\"v2\":1},\"in\":[{\"var\":\"v2\"},{\"var\":\"v3\"}]}"
        )

        assert(
            expr: Let(1, 2, 3) { Arr($0, $1, $2) },
            toBecome: "{\"let\":{\"v5\":2,\"v4\":1,\"v6\":3},\"in\":[{\"var\":\"v4\"},{\"var\":\"v5\"},{\"var\":\"v6\"}]}"
        )

        assert(
            expr: Let(1, 2, 3, 4) { Arr($0, $1, $2, $3) },
            toBecome: "{\"let\":{\"v7\":1,\"v9\":3,\"v10\":4,\"v8\":2},\"in\":[{\"var\":\"v7\"},{\"var\":\"v8\"},{\"var\":\"v9\"},{\"var\":\"v10\"}]}"
        )

        assert(
            expr: Let(1, 2, 3, 4, 5) { Arr($0, $1, $2, $3, $4) },
            toBecome: "{\"let\":{\"v12\":2,\"v13\":3,\"v14\":4,\"v11\":1,\"v15\":5},\"in\":[{\"var\":\"v11\"},{\"var\":\"v12\"},{\"var\":\"v13\"},{\"var\":\"v14\"},{\"var\":\"v15\"}]}"
        )
    }

    func testAt() {
        assert(
            expr: At(timestamp: HighPrecisionTime(secondsSince1970: 0, nanosecondsOffset: 1), Paginate(Classes())),
            toBecome: "{\"at\":{\"@ts\":\"1970-01-01T00:00:00.000000001Z\"},\"expr\":{\"paginate\":{\"classes\":null}}}"
        )

        assert(
            expr: At(timestamp: 1, Paginate(Classes())),
            toBecome: "{\"at\":1,\"expr\":{\"paginate\":{\"classes\":null}}}"
        )
    }

    func testIf() {
        assert(
            expr: If(true, then: "was true", else: "was false"),
            toBecome: "{\"if\":true,\"then\":\"was true\",\"else\":\"was false\"}"
        )
    }

    func testDo() {
        assert(expr: Do(Arr(1, 2, 3)), toBecome: "{\"do\":[1,2,3]}")
        assert(expr: Do(1, 2, 3), toBecome: "{\"do\":[1,2,3]}")
    }

    func testLambda() {
        assert(
            expr: Lambda(vars: "x", in: Var("x")),
            toBecome: "{\"lambda\":\"x\",\"expr\":{\"var\":\"x\"}}"
        )

        assert(
            expr: Lambda(vars: Arr("x", "_", "y"), in: Var("y")),
            toBecome: "{\"lambda\":[\"x\",\"_\",\"y\"],\"expr\":{\"var\":\"y\"}}"
        )

        assert(
            expr: Lambda(vars: "x", "_", "y", in: Var("y")),
            toBecome: "{\"lambda\":[\"x\",\"_\",\"y\"],\"expr\":{\"var\":\"y\"}}"
        )

        assert(
            expr: Lambda { $0 },
            toBecome: "{\"lambda\":\"v1\",\"expr\":{\"var\":\"v1\"}}"
        )

        assert(
            expr: Lambda { (a, b) in Arr(a, b) },
            toBecome: "{\"lambda\":[\"v2\",\"v3\"],\"expr\":[{\"var\":\"v2\"},{\"var\":\"v3\"}]}"
        )

        assert(
            expr: Lambda { (a, b, c) in Arr(a, b, c) },
            toBecome: "{\"lambda\":[\"v4\",\"v5\",\"v6\"],\"expr\":[{\"var\":\"v4\"},{\"var\":\"v5\"},{\"var\":\"v6\"}]}"
        )

        assert(
            expr: Lambda { (a, b, c, d) in Arr(a, b, c, d) },
            toBecome: "{\"lambda\":[\"v7\",\"v8\",\"v9\",\"v10\"],\"expr\":[{\"var\":\"v7\"},{\"var\":\"v8\"},{\"var\":\"v9\"},{\"var\":\"v10\"}]}"
        )

        assert(
            expr: Lambda { (a, b, c, d, e) in Arr(a, b, c, d, e) },
            toBecome: "{\"lambda\":[\"v11\",\"v12\",\"v13\",\"v14\",\"v15\"],\"expr\":[{\"var\":\"v11\"},{\"var\":\"v12\"},{\"var\":\"v13\"},{\"var\":\"v14\"},{\"var\":\"v15\"}]}"
        )
    }

    func testMap() {
        assert(
            expr: Map(collection: Arr(1, 2, 3), to: Lambda(vars: "i", in: Var("i"))),
            toBecome: "{\"map\":{\"lambda\":\"i\",\"expr\":{\"var\":\"i\"}},\"collection\":[1,2,3]}"
        )

        assert(
            expr: Map(collection: Arr(1, 2, 3), to: Lambda { $0 }),
            toBecome: "{\"map\":{\"lambda\":\"v1\",\"expr\":{\"var\":\"v1\"}},\"collection\":[1,2,3]}"
        )

        assert(
            expr: Map(Arr(1, 2, 3)) { $0 },
            toBecome: "{\"map\":{\"lambda\":\"v2\",\"expr\":{\"var\":\"v2\"}},\"collection\":[1,2,3]}"
        )

        assert(
            expr: Map(Arr(Arr(1, 2))) { (a, b) in Arr(a, b) },
            toBecome: "{\"map\":{\"lambda\":[\"v3\",\"v4\"],\"expr\":[{\"var\":\"v3\"},{\"var\":\"v4\"}]},\"collection\":[[1,2]]}"
        )

        assert(
            expr: Map(Arr(Arr(1, 2, 3))) { (a, b, c) in Arr(a, b, c) },
            toBecome: "{\"map\":{\"lambda\":[\"v5\",\"v6\",\"v7\"],\"expr\":[{\"var\":\"v5\"},{\"var\":\"v6\"},{\"var\":\"v7\"}]},\"collection\":[[1,2,3]]}"
        )

        assert(
            expr: Map(Arr(Arr(1, 2, 3, 4))) { (a, b, c, d) in Arr(a, b, c, d) },
            toBecome: "{\"map\":{\"lambda\":[\"v8\",\"v9\",\"v10\",\"v11\"],\"expr\":[{\"var\":\"v8\"},{\"var\":\"v9\"},{\"var\":\"v10\"},{\"var\":\"v11\"}]},\"collection\":[[1,2,3,4]]}"
        )

        assert(
            expr: Map(Arr(Arr(1, 2, 3, 4, 5))) { (a, b, c, d, e) in Arr(a, b, c, d, e) },
            toBecome: "{\"map\":{\"lambda\":[\"v12\",\"v13\",\"v14\",\"v15\",\"v16\"],\"expr\":[{\"var\":\"v12\"},{\"var\":\"v13\"},{\"var\":\"v14\"},{\"var\":\"v15\"},{\"var\":\"v16\"}]},\"collection\":[[1,2,3,4,5]]}"
        )
    }

    func testForeach() {
        assert(
            expr: Foreach(collection: Arr(1, 2, 3), in: Lambda(vars: "i", in: Var("i"))),
            toBecome: "{\"foreach\":{\"lambda\":\"i\",\"expr\":{\"var\":\"i\"}},\"collection\":[1,2,3]}"
        )

        assert(
            expr: Foreach(collection: Arr(1, 2, 3), in: Lambda { $0 }),
            toBecome: "{\"foreach\":{\"lambda\":\"v1\",\"expr\":{\"var\":\"v1\"}},\"collection\":[1,2,3]}"
        )

        assert(
            expr: Foreach(Arr(1, 2, 3)) { $0 },
            toBecome: "{\"foreach\":{\"lambda\":\"v2\",\"expr\":{\"var\":\"v2\"}},\"collection\":[1,2,3]}"
        )

        assert(
            expr: Foreach(Arr(Arr(1, 2))) { (a, b) in Arr(a, b) },
            toBecome: "{\"foreach\":{\"lambda\":[\"v3\",\"v4\"],\"expr\":[{\"var\":\"v3\"},{\"var\":\"v4\"}]},\"collection\":[[1,2]]}"
        )

        assert(
            expr: Foreach(Arr(Arr(1, 2, 3))) { (a, b, c) in Arr(a, b, c) },
            toBecome: "{\"foreach\":{\"lambda\":[\"v5\",\"v6\",\"v7\"],\"expr\":[{\"var\":\"v5\"},{\"var\":\"v6\"},{\"var\":\"v7\"}]},\"collection\":[[1,2,3]]}"
        )

        assert(
            expr: Foreach(Arr(Arr(1, 2, 3, 4))) { (a, b, c, d) in Arr(a, b, c, d) },
            toBecome: "{\"foreach\":{\"lambda\":[\"v8\",\"v9\",\"v10\",\"v11\"],\"expr\":[{\"var\":\"v8\"},{\"var\":\"v9\"},{\"var\":\"v10\"},{\"var\":\"v11\"}]},\"collection\":[[1,2,3,4]]}"
        )

        assert(
            expr: Foreach(Arr(Arr(1, 2, 3, 4, 5))) { (a, b, c, d, e) in Arr(a, b, c, d, e) },
            toBecome: "{\"foreach\":{\"lambda\":[\"v12\",\"v13\",\"v14\",\"v15\",\"v16\"],\"expr\":[{\"var\":\"v12\"},{\"var\":\"v13\"},{\"var\":\"v14\"},{\"var\":\"v15\"},{\"var\":\"v16\"}]},\"collection\":[[1,2,3,4,5]]}"
        )
    }

    func testFilter() {
        assert(
            expr: Filter(collection: Arr(true, false, true), with: Lambda(vars: "i", in: Var("i"))),
            toBecome: "{\"filter\":{\"lambda\":\"i\",\"expr\":{\"var\":\"i\"}},\"collection\":[true,false,true]}"
        )

        assert(
            expr: Filter(collection: Arr(true, false, true), with: Lambda { $0 }),
            toBecome: "{\"filter\":{\"lambda\":\"v1\",\"expr\":{\"var\":\"v1\"}},\"collection\":[true,false,true]}"
        )

        assert(
            expr: Filter(Arr(true, false, true)) { $0 },
            toBecome: "{\"filter\":{\"lambda\":\"v2\",\"expr\":{\"var\":\"v2\"}},\"collection\":[true,false,true]}"
        )

        assert(
            expr: Filter(Arr(Arr(true, false))) { (a, b) in And(a, b) },
            toBecome: "{\"filter\":{\"lambda\":[\"v3\",\"v4\"],\"expr\":{\"and\":[{\"var\":\"v3\"},{\"var\":\"v4\"}]}},\"collection\":[[true,false]]}"
        )

        assert(
            expr: Filter(Arr(Arr(true, false, true))) { (a, b, c) in And(a, b, c) },
            toBecome: "{\"filter\":{\"lambda\":[\"v5\",\"v6\",\"v7\"],\"expr\":{\"and\":[{\"var\":\"v5\"},{\"var\":\"v6\"},{\"var\":\"v7\"}]}},\"collection\":[[true,false,true]]}"
        )

        assert(
            expr: Filter(Arr(Arr(true, false, true, false))) { (a, b, c, d) in And(a, b, c, d) },
            toBecome: "{\"filter\":{\"lambda\":[\"v8\",\"v9\",\"v10\",\"v11\"],\"expr\":{\"and\":[{\"var\":\"v8\"},{\"var\":\"v9\"},{\"var\":\"v10\"},{\"var\":\"v11\"}]}},\"collection\":[[true,false,true,false]]}"
        )

        assert(
            expr: Filter(Arr(Arr(true, false, true, false, true))) { (a, b, c, d, e) in And(a, b, c, d, e) },
            toBecome: "{\"filter\":{\"lambda\":[\"v12\",\"v13\",\"v14\",\"v15\",\"v16\"],\"expr\":{\"and\":[{\"var\":\"v12\"},{\"var\":\"v13\"},{\"var\":\"v14\"},{\"var\":\"v15\"},{\"var\":\"v16\"}]}},\"collection\":[[true,false,true,false,true]]}"
        )
    }

    func testTake() {
        assert(expr: Take(count: 2, from: Arr(1, 2, 3)), toBecome: "{\"take\":2,\"collection\":[1,2,3]}")
    }

    func testDrop() {
        assert(expr: Drop(count: 2, from: Arr(1, 2, 3)), toBecome: "{\"drop\":2,\"collection\":[1,2,3]}")
    }

    func testPrepend() {
        assert(
            expr: Prepend(elements: Arr(1, 2), to: Arr(3, 4)),
            toBecome: "{\"prepend\":[1,2],\"collection\":[3,4]}"
        )
    }

    func testAppend() {
        assert(
            expr: Append(elements: Arr(3, 4), to: Arr(1, 2)),
            toBecome: "{\"append\":[3,4],\"collection\":[1,2]}"
        )
    }

    func testIsEmpty() {
        assert(
            expr: IsEmpty(Arr(1, 2, 3)),
            toBecome: "{\"is_empty\":[1,2,3]}"
        )
    }

    func testIsNonEmpty() {
        assert(
            expr: IsNonEmpty(Arr(1, 2, 3)),
            toBecome: "{\"is_nonempty\":[1,2,3]}"
        )
    }

    func testGet() {
        assert(
            expr: Get(Ref("classes/spells/42")),
            toBecome: "{\"get\":{\"@ref\":\"classes\\/spells\\/42\"}}"
        )

        assert(
            expr: Get(Ref("classes/spells/42"), ts: 123),
            toBecome: "{\"ts\":123,\"get\":{\"@ref\":\"classes\\/spells\\/42\"}}"
        )
    }

    func testKeyFromSecret() {
        assert(
            expr: KeyFromSecret("s3cr3t"),
            toBecome: "{\"key_from_secret\":\"s3cr3t\"}"
        )
    }

    func testPaginate() {
        assert(
            expr: Paginate(Ref("indexes")),
            toBecome: "{\"paginate\":{\"@ref\":\"indexes\"}}"
        )

        assert(
            expr: Paginate(Ref("indexes"), ts: 123),
            toBecome: "{\"paginate\":{\"@ref\":\"indexes\"},\"ts\":123}"
        )

        assert(
            expr: Paginate(
                Ref("indexes"),
                before: Ref("indexes/ten"),
                after: Ref("indexes/two"),
                ts: 123,
                size: 4,
                events: true,
                sources: true
            ),
            toBecome: "{\"sources\":true,\"paginate\":{\"@ref\":\"indexes\"},\"after\":{\"@ref\":\"indexes\\/two\"},\"size\":4,\"events\":true,\"ts\":123,\"before\":{\"@ref\":\"indexes\\/ten\"}}"
        )
    }

    func testExists() {
        assert(
            expr: Exists(Ref("classes/spells")),
            toBecome: "{\"exists\":{\"@ref\":\"classes\\/spells\"}}"
        )

        assert(
            expr: Exists(Ref("classes/spells"), ts: 123),
            toBecome: "{\"ts\":123,\"exists\":{\"@ref\":\"classes\\/spells\"}}"
        )
    }

    func testCreate() {
        assert(
            expr: Create(at: Ref("classes/spells"), Obj("data" => Obj("name" => "fireball"))),
            toBecome: "{\"create\":{\"@ref\":\"classes\\/spells\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"fireball\"}}}}}")
    }

    func testUpdate() {
        assert(
            expr: Update(ref: Ref("classes/spells/42"), to: Obj("data" => Obj("name" => "fireball"))),
            toBecome: "{\"update\":{\"@ref\":\"classes\\/spells\\/42\"},\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"fireball\"}}}}}")
    }

    func testReplace() {
        assert(
            expr: Replace(ref: Ref("classes/spells/42"), with: Obj("data" => Obj("name" => "fireball"))),
            toBecome: "{\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"fireball\"}}}},\"replace\":{\"@ref\":\"classes\\/spells\\/42\"}}")
    }

    func testDelete() {
        assert(
            expr: Delete(ref: Ref("classes/spells/42")),
            toBecome: "{\"delete\":{\"@ref\":\"classes\\/spells\\/42\"}}")
    }

    func testInsert() {
        assert(
            expr: Insert(
                ref: Ref("classes/spells/42"),
                ts: 123,
                action: "create",
                params: Obj("data" => Obj("name" => "fireball"))
            ),
            toBecome: "{\"insert\":{\"@ref\":\"classes\\/spells\\/42\"},\"action\":\"create\",\"ts\":123,\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"fireball\"}}}}}")

        assert(
            expr: Insert(
                in: Ref("classes/spells/42"),
                ts: 123,
                action: .create,
                params: Obj("data" => Obj("name" => "fireball"))
            ),
            toBecome: "{\"insert\":{\"@ref\":\"classes\\/spells\\/42\"},\"action\":\"create\",\"ts\":123,\"params\":{\"object\":{\"data\":{\"object\":{\"name\":\"fireball\"}}}}}")
    }

    func testRemove() {
        assert(
            expr: Remove(
                ref: Ref("classes/spells/42"),
                ts: 123,
                action: "delete"
            ),
            toBecome: "{\"remove\":{\"@ref\":\"classes\\/spells\\/42\"},\"action\":\"delete\",\"ts\":123}")

        assert(
            expr: Remove(
                from: Ref("classes/spells/42"),
                ts: 123,
                action: .delete
            ),
            toBecome: "{\"remove\":{\"@ref\":\"classes\\/spells\\/42\"},\"action\":\"delete\",\"ts\":123}")
    }

    func testCreateClass() {
        assert(
            expr: CreateClass(Obj("name" => "spells")),
            toBecome: "{\"create_class\":{\"object\":{\"name\":\"spells\"}}}"
        )
    }

    func testCreateDatabase() {
        assert(
            expr: CreateDatabase(Obj("name" => "test-db")),
            toBecome: "{\"create_database\":{\"object\":{\"name\":\"test-db\"}}}"
        )
    }

    func testCreateIndex() {
        assert(
            expr: CreateIndex(Obj("name" => "all_spells", "source" => Ref("classes/spells"))),
            toBecome: "{\"create_index\":{\"object\":{\"name\":\"all_spells\",\"source\":{\"@ref\":\"classes\\/spells\"}}}}"
        )
    }

    func testCreateKey() {
        assert(
            expr: CreateKey(Obj("role" => "server", "database" => Ref("databases/test-db"))),
            toBecome: "{\"create_key\":{\"object\":{\"role\":\"server\",\"database\":{\"@ref\":\"databases\\/test-db\"}}}}"
        )
    }

    func testSingleton() {
        assert(
            expr: Singleton(Ref("classes/spells/123456789")),
            toBecome: "{\"singleton\":{\"@ref\":\"classes\\/spells\\/123456789\"}}"
        )
    }

    func testEvents() {
        assert(
            expr: Events(Ref("classes/spells/123456789")),
            toBecome: "{\"events\":{\"@ref\":\"classes\\/spells\\/123456789\"}}"
        )
    }

    func testMatch() {
        assert(
            expr: Match(index: Ref("indexes/all_spells")),
            toBecome: "{\"match\":{\"@ref\":\"indexes\\/all_spells\"}}"
        )

        assert(
            expr: Match(index: Ref("indexes/spells_by_name"), terms: "fireball"),
            toBecome: "{\"terms\":\"fireball\",\"match\":{\"@ref\":\"indexes\\/spells_by_name\"}}"
        )

        assert(
            expr: Match(index: Ref("indexes/spells_by_name_and_power"), terms: Arr("fireball", 10)),
            toBecome: "{\"terms\":[\"fireball\",10],\"match\":{\"@ref\":\"indexes\\/spells_by_name_and_power\"}}"
        )

        assert(
            expr: Match(index: Ref("indexes/spells_by_name_and_power"), terms: "fireball", 10),
            toBecome: "{\"terms\":[\"fireball\",10],\"match\":{\"@ref\":\"indexes\\/spells_by_name_and_power\"}}"
        )
    }

    func testUnion() {
        assert(
            expr: Union(Arr(Ref("set1"), Ref("set2"))),
            toBecome: "{\"union\":[{\"@ref\":\"set1\"},{\"@ref\":\"set2\"}]}"
        )

        assert(
            expr: Union(Ref("set1"), Ref("set2")),
            toBecome: "{\"union\":[{\"@ref\":\"set1\"},{\"@ref\":\"set2\"}]}"
        )
    }

    func testIntersection() {
        assert(
            expr: Intersection(Arr(Ref("set1"), Ref("set2"))),
            toBecome: "{\"intersection\":[{\"@ref\":\"set1\"},{\"@ref\":\"set2\"}]}"
        )

        assert(
            expr: Intersection(Ref("set1"), Ref("set2")),
            toBecome: "{\"intersection\":[{\"@ref\":\"set1\"},{\"@ref\":\"set2\"}]}"
        )
    }

    func testDifference() {
        assert(
            expr: Difference(Arr(Ref("set1"), Ref("set2"))),
            toBecome: "{\"difference\":[{\"@ref\":\"set1\"},{\"@ref\":\"set2\"}]}"
        )

        assert(
            expr: Difference(Ref("set1"), Ref("set2")),
            toBecome: "{\"difference\":[{\"@ref\":\"set1\"},{\"@ref\":\"set2\"}]}"
        )
    }

    func testDistinct() {
        assert(expr: Distinct(Arr(1, 2, 1)), toBecome: "{\"distinct\":[1,2,1]}")
    }

    func testJoin() {
        assert(
            expr: Join(Ref("aSet"), with: Ref("otherSet")),
            toBecome: "{\"with\":{\"@ref\":\"otherSet\"},\"join\":{\"@ref\":\"aSet\"}}"
        )

        assert(
            expr: Join(Ref("aSet"), with: Lambda { $0 }),
            toBecome: "{\"with\":{\"lambda\":\"v1\",\"expr\":{\"var\":\"v1\"}},\"join\":{\"@ref\":\"aSet\"}}"
        )

        assert(
            expr: Join(Ref("aSet")) { $0 },
            toBecome: "{\"with\":{\"lambda\":\"v2\",\"expr\":{\"var\":\"v2\"}},\"join\":{\"@ref\":\"aSet\"}}"
        )

        assert(
            expr: Join(Ref("aSet")) { (a, b) in b },
            toBecome: "{\"with\":{\"lambda\":[\"v3\",\"v4\"],\"expr\":{\"var\":\"v4\"}},\"join\":{\"@ref\":\"aSet\"}}"
        )

        assert(
            expr: Join(Ref("aSet")) { (a, b, c) in c },
            toBecome: "{\"with\":{\"lambda\":[\"v5\",\"v6\",\"v7\"],\"expr\":{\"var\":\"v7\"}},\"join\":{\"@ref\":\"aSet\"}}"
        )

        assert(
            expr: Join(Ref("aSet")) { (a, b, c, d) in d },
            toBecome: "{\"with\":{\"lambda\":[\"v8\",\"v9\",\"v10\",\"v11\"],\"expr\":{\"var\":\"v11\"}},\"join\":{\"@ref\":\"aSet\"}}"
        )

        assert(
            expr: Join(Ref("aSet")) { (a, b, c, d, e) in e },
            toBecome: "{\"with\":{\"lambda\":[\"v12\",\"v13\",\"v14\",\"v15\",\"v16\"],\"expr\":{\"var\":\"v16\"}},\"join\":{\"@ref\":\"aSet\"}}"
        )
    }

    func testLogin() {
        assert(
            expr: Login(for: Ref("classes/users/1"), Obj("password" => "abracadabra")),
            toBecome: "{\"login\":{\"@ref\":\"classes\\/users\\/1\"},\"params\":{\"object\":{\"password\":\"abracadabra\"}}}"
        )
    }

    func testLogout() {
        assert(expr: Logout(all: true), toBecome: "{\"logout\":true}")
    }

    func testIdentify() {
        assert(
            expr: Identify(ref: Ref("classes/users/1"), password: "abracadabra"),
            toBecome: "{\"password\":\"abracadabra\",\"identify\":{\"@ref\":\"classes\\/users\\/1\"}}"
        )
    }

    func testIdentity() {
        assert(expr: Identity(), toBecome: "{\"identity\":null}")
    }

    func testHasIdentity() {
        assert(expr: HasIdentity(), toBecome: "{\"has_identity\":null}")
    }

    func testConcat() {
        assert(expr: Concat(Arr("Hellow", "World")), toBecome: "{\"concat\":[\"Hellow\",\"World\"]}")
        assert(expr: Concat("Hellow", "World"), toBecome: "{\"concat\":[\"Hellow\",\"World\"]}")
        assert(expr: Concat("Hellow", "World", separator: ","), toBecome: "{\"concat\":[\"Hellow\",\"World\"],\"separator\":\",\"}")
    }

    func testNGram() {
        assert(expr: NGram("str"), toBecome: "{\"ngram\":\"str\"}")
        assert(expr: NGram("str0", "str1"), toBecome: "{\"ngram\":[\"str0\",\"str1\"]}")

        assert(expr: NGram("str", min: 1), toBecome: "{\"ngram\":\"str\",\"min\":1}")
        assert(expr: NGram("str", max: 1), toBecome: "{\"ngram\":\"str\",\"max\":1}")

        assert(expr: NGram("str", min: 1, max: 2), toBecome: "{\"ngram\":\"str\",\"min\":1,\"max\":2}")
    }

    func testCasefold() {
        assert(expr: Casefold("HELLOW"), toBecome: "{\"casefold\":\"HELLOW\"}")

        assert(expr: Casefold("HELLOW", "NFC"), toBecome: "{\"normalizer\":\"NFC\",\"casefold\":\"HELLOW\"}")
        assert(expr: Casefold("HELLOW", normalizer: .NFC), toBecome: "{\"normalizer\":\"NFC\",\"casefold\":\"HELLOW\"}")
    }

    func testTime() {
        assert(expr: Time(fromString: "now"), toBecome: "{\"time\":\"now\"}")
    }

    func testEpoch() {
        assert(expr: Epoch(10, "second"), toBecome: "{\"unit\":\"second\",\"epoch\":10}")
        assert(expr: Epoch(10, unit: .second), toBecome: "{\"unit\":\"second\",\"epoch\":10}")
        assert(expr: Epoch(10, unit: .millisecond), toBecome: "{\"unit\":\"millisecond\",\"epoch\":10}")
        assert(expr: Epoch(10, unit: .microsecond), toBecome: "{\"unit\":\"microsecond\",\"epoch\":10}")
        assert(expr: Epoch(10, unit: .nanosecond), toBecome: "{\"unit\":\"nanosecond\",\"epoch\":10}")
    }

    func testDate() {
        assert(expr: DateFn(string: "1970-01-01"), toBecome: "{\"date\":\"1970-01-01\"}")
    }

    func testNewId() {
        assert(expr: NewId(), toBecome: "{\"new_id\":null}")
    }

    func testDatabase() {
        assert(expr: Database("db-test"), toBecome: "{\"database\":\"db-test\"}")
        assert(expr: Database("db-test", scope: Database("parent")), toBecome: "{\"scope\":{\"database\":\"parent\"},\"database\":\"db-test\"}")
    }

    func testIndex() {
        assert(expr: Index("all_spells"), toBecome: "{\"index\":\"all_spells\"}")
        assert(expr: Index("all_spells", scope: Database("parent")), toBecome: "{\"scope\":{\"database\":\"parent\"},\"index\":\"all_spells\"}")
    }

    func testClass() {
        assert(expr: Class("spells"), toBecome: "{\"class\":\"spells\"}")
        assert(expr: Class("spells", scope: Database("parent")), toBecome: "{\"scope\":{\"database\":\"parent\"},\"class\":\"spells\"}")
    }

    func testFunction() {
        assert(expr: Function("func"), toBecome: "{\"function\":\"func\"}")
        assert(expr: Function("func", scope: Database("parent")), toBecome: "{\"scope\":{\"database\":\"parent\"},\"function\":\"func\"}")
    }

    func testNativeRefs() {
        assert(expr: Classes(), toBecome: "{\"classes\":null}")
        assert(expr: Databases(), toBecome: "{\"databases\":null}")
        assert(expr: Indexes(), toBecome: "{\"indexes\":null}")
        assert(expr: Functions(), toBecome: "{\"functions\":null}")
        assert(expr: Keys(), toBecome: "{\"keys\":null}")
        assert(expr: Tokens(), toBecome: "{\"tokens\":null}")
        assert(expr: Credentials(), toBecome: "{\"credentials\":null}")

        assert(expr: Classes(scope: Database("scope")), toBecome: "{\"classes\":{\"database\":\"scope\"}}")
        assert(expr: Databases(scope: Database("scope")), toBecome: "{\"databases\":{\"database\":\"scope\"}}")
        assert(expr: Indexes(scope: Database("scope")), toBecome: "{\"indexes\":{\"database\":\"scope\"}}")
        assert(expr: Functions(scope: Database("scope")), toBecome: "{\"functions\":{\"database\":\"scope\"}}")
        assert(expr: Keys(scope: Database("scope")), toBecome: "{\"keys\":{\"database\":\"scope\"}}")
        assert(expr: Tokens(scope: Database("scope")), toBecome: "{\"tokens\":{\"database\":\"scope\"}}")
        assert(expr: Credentials(scope: Database("scope")), toBecome: "{\"credentials\":{\"database\":\"scope\"}}")
    }

    func testEquals() {
        assert(expr: Equals(Arr(1, 1)), toBecome: "{\"equals\":[1,1]}")
        assert(expr: Equals(1, 1), toBecome: "{\"equals\":[1,1]}")
    }

    func testContains() {
        assert(
            expr: Contains(path: Arr("favorite", "foods"), in: Var("obj")),
            toBecome: "{\"contains\":[\"favorite\",\"foods\"],\"in\":{\"var\":\"obj\"}}"
        )

        assert(
            expr: Contains(path: "favorite", "foods", in: Var("obj")),
            toBecome: "{\"contains\":[\"favorite\",\"foods\"],\"in\":{\"var\":\"obj\"}}"
        )

    }

    func testSelect() {
        assert(
            expr: Select(path: Arr("data", "name"), from: Var("obj")),
            toBecome: "{\"from\":{\"var\":\"obj\"},\"select\":[\"data\",\"name\"]}"
        )

        assert(
            expr: Select(path: "data", "name", from: Var("obj")),
            toBecome: "{\"from\":{\"var\":\"obj\"},\"select\":[\"data\",\"name\"]}"
        )

        assert(
            expr: Select(path: "data", "name", from: Var("obj"), default: 1),
            toBecome: "{\"from\":{\"var\":\"obj\"},\"default\":1,\"select\":[\"data\",\"name\"]}"
        )
    }

    func testSelectAll() {
        assert(
            expr: SelectAll(path: "foo", from: Obj("foo" => "bar")),
            toBecome: "{\"from\":{\"object\":{\"foo\":\"bar\"}},\"select_all\":\"foo\"}"
        )
    }

    func testAdd() {
        assert(expr: Add(Arr(1, 1)), toBecome: "{\"add\":[1,1]}")
        assert(expr: Add(1, 1), toBecome: "{\"add\":[1,1]}")
    }

    func testMultiply() {
        assert(expr: Multiply(Arr(1, 1)), toBecome: "{\"multiply\":[1,1]}")
        assert(expr: Multiply(1, 1), toBecome: "{\"multiply\":[1,1]}")
    }

    func testSubtract() {
        assert(expr: Subtract(Arr(1, 1)), toBecome: "{\"subtract\":[1,1]}")
        assert(expr: Subtract(1, 1), toBecome: "{\"subtract\":[1,1]}")
    }

    func testDivide() {
        assert(expr: Divide(Arr(1, 1)), toBecome: "{\"divide\":[1,1]}")
        assert(expr: Divide(1, 1), toBecome: "{\"divide\":[1,1]}")
    }

    func testModulo() {
        assert(expr: Modulo(Arr(1, 1)), toBecome: "{\"modulo\":[1,1]}")
        assert(expr: Modulo(1, 1), toBecome: "{\"modulo\":[1,1]}")
    }

    func testLT() {
        assert(expr: LT(Arr(1, 1)), toBecome: "{\"lt\":[1,1]}")
        assert(expr: LT(1, 1), toBecome: "{\"lt\":[1,1]}")
    }

    func testLTE() {
        assert(expr: LTE(Arr(1, 1)), toBecome: "{\"lte\":[1,1]}")
        assert(expr: LTE(1, 1), toBecome: "{\"lte\":[1,1]}")
    }

    func testGT() {
        assert(expr: GT(Arr(1, 1)), toBecome: "{\"gt\":[1,1]}")
        assert(expr: GT(1, 1), toBecome: "{\"gt\":[1,1]}")
    }

    func testGTE() {
        assert(expr: GTE(Arr(1, 1)), toBecome: "{\"gte\":[1,1]}")
        assert(expr: GTE(1, 1), toBecome: "{\"gte\":[1,1]}")
    }

    func testAnd() {
        assert(expr: And(Arr(true, false)), toBecome: "{\"and\":[true,false]}")
        assert(expr: And(true, false), toBecome: "{\"and\":[true,false]}")
    }

    func testOr() {
        assert(expr: Or(Arr(true, false)), toBecome: "{\"or\":[true,false]}")
        assert(expr: Or(true, false), toBecome: "{\"or\":[true,false]}")
    }

    func testNot() {
        assert(expr: Not(false), toBecome: "{\"not\":false}")
    }

    private func assert(expr: Expr?, toBecome jsonString: String) {
        XCTAssertEqual(JSON.stringify(expr: expr as Any), jsonString)
    }

}
