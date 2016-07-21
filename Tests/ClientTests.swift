//
//  ClientTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
import Nimble
import Result
@testable import FaunaDB


class ClientTests: FaunaDBTests {
        
    private func setupFaunaDB(){

        var value: Value?
        
        // Create a database
        value = await(
            Create(ref: Ref("databases"),
                params: ["name": testDbName])
        )
        expect(value).notTo(beNil())
        
        let dbRef: Ref? = value?.get(field: Fields.ref)
        expect(dbRef) == Ref("databases/\(testDbName)")
        
        // Get a new key
        value = await(
            Create(ref: Ref("keys"),
                params: ["database": dbRef!, "role": "server"])
        )
        expect(value).notTo(beNil())
        
        let secret: String = try! value!.get(path: "secret")
        
        // set up client using the new secret
        client = Client(secret: secret, observers: [Logger()])
        
        
        // Create spells class
        value = await(
            Create(ref: Ref("classes"),
                params: ["name": "spells"])
        )
        expect(value).notTo(beNil())
        
        
        // Create an index
        value = await(
            Create(ref: Ref("indexes"),
                params: ["name": "spells_by_element",
                         "source": Ref("classes/spells"),
                         "terms": [["field": "data.element"] as Obj] as Arr,
                         "active": true])
        )
        expect(value).notTo(beNil())
    }
    
    
    func testNotFoundException() {
        setupFaunaDB()
        
        let expr: Expr = Ref("classes/spells/1234")
        let error = awaitError(Get(ref: expr))
        expect(error?.equalType(Error.NotFoundException(response: nil, errors: []))) == true
    }
    
    
    func testEchoValues(){
        setupFaunaDB()
        
        // MARK: echo values
        var value: Value?
        value = await(["foo": "bar"] as Obj)
        expect(value).notTo(beNil())
        let objResult: Obj? = value?.get()
        expect(objResult) == ["foo": "bar"]
        
        value = await([1, 2, "foo"] as Arr)
        expect(value).notTo(beNil())
        let arrResult: Arr? = value?.get()
        expect(arrResult) == [Double(1), Double(2), "foo"]
        
        value = await("qux")
        expect(value).notTo(beNil())
        expect(value?.get()) == "qux"

    }
    
    
    func testCreateAnInstance(){
        setupFaunaDB()
        
        var value: Value?
        
        // Create an instance
        
        value = await(
            Create(ref: Ref("classes/spells"),
                params: ["data": ["testField": "testValue"] as Obj])
        )
        expect(value).notTo(beNil())
        
        expect(value?.get(field: Fields.ref)?.ref).to(beginWith("classes/spells/"))
        expect(value?.get(field: Fields.`class`)) == Ref("classes/spells")
        expect(value?.get(path: "data", "testField")) == "testValue"
        
        // Check that it exists
        let ref: Ref? = value?.get(field: Fields.ref)
        value = await(
            Exists(ref: ref!)
        )
        expect(value?.get()) == true
        
        
        value = await(
            Create(ref: Ref("classes/spells"),
                params:  ["data": [ "testData" : [ "array": [1, "2", 3.4] as Arr,
                    "bool": true,
                    "num": 1234,
                    "string": "sup",
                    "float": 1.234,
                    "null": Null()]
                    as Obj]
                    as Obj]
            ))
        
        let testData: Obj? = value?.get(path: "data", "testData")
        expect(testData).notTo(beNil())
        expect(testData?.get(path: "array", 0)) == Double(1)
        expect(testData?.get(path: "array", 1)) == "2"
        expect(testData?.get(path: "array", 2)) == 3.4
        expect(testData?.get(path: "string")) == "sup"
        expect(testData?.get(path: "num")) == Double(1234)
    }
    
    
    func testBatcheQuery() {
        setupFaunaDB()
        
        //MARK: Issue a batched query
        
        let classRef = Ref("classes/spells")
        let randomText1 = String(randomWithLength: 8)
        let randomText2 = String(randomWithLength: 8)
        let expr1 = Create(ref: classRef, params: ["data": ["queryTest1": randomText1] as Obj])
        let expr2 = Create(ref: classRef, params: ["data": ["queryTest2": randomText2] as Obj])
        
        let value = await(Arr(expr1.value, expr2.value))
        let arr: Arr? = value?.get()
        expect(arr?.count) == 2
        expect(arr?[0].get(path: "data", "queryTest1")) == randomText1
        expect(arr?[1].get(path: "data", "queryTest2")) == randomText2
        
        let value2 = await([expr1.value, expr2.value] as Arr)
        let arr2: Arr? = value2?.get()
        expect(arr2?.count) == 2
        expect(arr2?[0].get(path: "data", "queryTest1")) == randomText1
        expect(arr2?[1].get(path: "data", "queryTest2")) == randomText2
    }
    
    
        

    func testPaginatedQuery() {
        setupFaunaDB()
        
        //MARK: "issue a paginated query"
        let randomClassName = String(randomWithLength: 8)
        var value: Value?
        value = await(Create(ref: Ref("classes"),
                          params: ["name": randomClassName])
        )
        expect(value).notTo(beNil())
        
        let randomClassRef: Ref? = value?.get(field: Fields.ref)
        expect(randomClassRef) == Ref("classes/" + randomClassName)
        
        
        value = await(Create(ref: Ref("indexes"),
                    params:   ["name": "\(randomClassName)_class_index",
                             "source": randomClassRef!,
                             "active": true,
                             "unique": false]))
        expect(value).notTo(beNil())
        let randomClassIndex: Ref? = value?.get(field: Fields.ref)
        expect(randomClassIndex) == Ref("indexes/\(randomClassName)_class_index")

        
        value = await(Create(ref: Ref("indexes"),
                           params: ["name": "\(randomClassName)_test_index",
                                  "source": randomClassRef!,
                                  "active": true,
                                  "unique": false,
                                   "terms": [["field": "data.queryTest1"] as Obj] as Arr])
        )
        expect(value).notTo(beNil())
        let testIndex: Ref? = value?.get(field: Fields.ref)
        expect(testIndex) == Ref("indexes/\(randomClassName)_test_index")
        

        let randomText1 = String(randomWithLength: 8)
        let randomText2 = String(randomWithLength: 8)
        let randomText3 = String(randomWithLength: 8)
        
        let create1Value = await(Create(ref: randomClassRef!, params: ["data": ["queryTest1": randomText1] as Obj]))
        expect(create1Value).notTo(beNil())
        let create2Value = await(Create(ref: randomClassRef!, params: ["data": ["queryTest1": randomText2] as Obj]))
        expect(create2Value).notTo(beNil())
        let create3Value = await(Create(ref: randomClassRef!, params: ["data": ["queryTest1": randomText3] as Obj]))
        expect(create3Value).notTo(beNil())
        
        
        let queryMatchValue = await(
            Paginate(resource: Match(index: testIndex!,
                                     terms: randomText1))
        )
        expect(queryMatchValue).notTo(beNil())
        
        let createValue1Ref: Ref = try! create1Value!.get(field: Fields.ref)
        let arr: [Ref]? = try? queryMatchValue!.get(path: "data")
        expect(arr) == [createValue1Ref]
        
        
        value = await(
            Paginate(resource: Match(index:randomClassIndex!),
                         size:1)
        )
        expect(value).notTo(beNil())
        
        var paginateArr: Arr = try! value!.get(path: "data")
        expect(paginateArr.count) == 1
        
        var after: Arr? = value?.get(path: "after")
        var before: Arr? = value?.get(path: "before")
        expect(after).notTo(beNil())
        expect(before).to(beNil())
        
        
        
        value = await(Paginate(resource: Match(index:randomClassIndex!),
                                   size: 1,
                                 cursor: .After(expr: after!)))
        expect(value).notTo(beNil())
        
        paginateArr = try! value!.get(path: "data")
        expect(paginateArr.count) == 1
        
        after = value?.get(path: "after")
        before = value?.get(path: "before")
        expect(after).notTo(beNil())
        expect(before).notTo(beNil())
        

        value = await(Count(set: Match(index: randomClassIndex!)))
        expect(value).notTo(beNil())
        expect(value?.get()) == 3.0
    }
    
    func testHandleConstraintViolation() {
        setupFaunaDB()
        
        let randomClassName = String(randomWithLength: 8)
        let value = await(
            Create(ref: Ref("classes"),
                params: ["name": randomClassName])
        )
        expect(value).notTo(beNil())
        let classRef: Ref? = value?.get(field: Fields.ref)
        
        
        
        let uniqueIndexRes = await(
            Create(ref: Ref("indexes"),
                params: [ "name": randomClassName + "_by_unique_test",
                          "source": classRef!,
                          "terms": [["field": "data.uniqueTest1"] as Obj] as Arr,
                          "unique": true,
                          "active": true])
        )
        expect(uniqueIndexRes).notTo(beNil())
        
        let randomText = String(randomWithLength: 8)
        let create: Create = Create(ref: classRef!,
                            params: ["data": ["uniqueTest1": randomText] as Obj])
        let cretate = await(create)
        expect(cretate).notTo(beNil())
        let error = awaitError(create)
        expect(error?.equalType(Error.BadRequestException(response: nil, errors: []))) == true
        expect(error?.responseErrors.count) == 1
        expect("validation failed") == error?.responseErrors[0].code
        expect("duplicate value") == error?.responseErrors[0].failures.filter { $0.field == ["data", "uniqueTest1"] }.first?.code
    }
    
    func testTypes() {
        setupFaunaDB()
        
        let value = await(Match(index: Ref("indexes/spells_by_element"),
                                terms: "arcane" as Expr))
        expect(value).notTo(beNil())
        let set: SetRef? = value?.get()

        expect(Ref("indexes/spells_by_element")) == set?.parameters.get(path: "match")
        expect("arcane") == set?.parameters.get(path: "terms")
    }
    
    func testBasicForms() {
        setupFaunaDB()
        
        let letR = await(Let(1, 2) { x, _ in x })
        expect(Double(1)) == letR?.get()
        
        let ifR = await(If(pred: true, then: "was true", else: "was false"))
        expect("was true") == ifR?.get()

        let randomRef: Ref = Ref("classes/spells/" + String(randomNumWithLength: 4))
        let doR = await(
            Do(exprs: Create(ref: randomRef,
                          params: ["data": ["name": "Magic Missile"] as Obj]),
                      Get(ref: randomRef))
        )
        expect(randomRef) == doR?.get(field: Fields.ref)
   

        let objectR = await(["name": "Hen Wen", "age": 123] as Obj)
        expect(objectR?.get(path:"name")) == "Hen Wen"
        expect(objectR?.get(path: "age")) == Double(123)
    }
    
    func testCollections(){
        setupFaunaDB()
        
        let mapR = await(
            Map(collection: [1, 2, 3] as Arr) { x in Add(terms: x, 1) }
        )
        expect(mapR?.get()) == [2.0, 3.0, 4.0]
        

        let foreachR = await(
            Foreach(collection:  ["Fireball Level 1", "Fireball Level 2"] as Arr) { spell in
                Create(ref: Ref("classes/spells"), params: ["data": ["name": spell.value] as Obj])
            }
        )
        expect(foreachR?.get()) == ["Fireball Level 1", "Fireball Level 2"]
        
        let filterR = await(
            Filter(collection: [1, 2, 11, 12] as Arr) {
                GT(terms: $0, 10)
            }
        )
        expect(filterR?.get()) == [11.0, 12.0]
    }
    
    func testResourceModification() {
        setupFaunaDB()
        
        let createR = await(
            Create(ref: Ref("classes/spells"),
                params: ["data": ["name": "Magic Missile",
                                  "element": "arcane",
                                  "cost": Double(10)]
                                  as Obj]
            )
        )
        expect(createR?.get(field: Fields.ref)?.ref).to(beginWith("classes/spells/"))
        expect(createR?.get(path: "data", "name")) == "Magic Missile"
        expect(createR?.get(path: "data", "element")) == "arcane"
        expect(createR?.get(path: "data", "cost")) == 10.0
        
        
        let updateR = await(
            try! Update(ref: createR!.get(field: Fields.ref),
                params: ["data": ["name": "Faerie Fire",
                                  "cost": Null()] as Obj])
        )
        let updateRef: Ref? = updateR?.get(field: Fields.ref)
        expect(updateRef) == createR?.get(field: Fields.ref)
        expect(updateR?.get(path: "data", "name")) == "Faerie Fire"
        expect(updateR?.get(path: "data", "element")) == "arcane"
        let nullCost: Double? = updateR?.get(path: "data", "cost")
        expect(nullCost).to(beNil())
        
        
        let replaceR = await(
            Replace(ref: try! createR!.get(path: "ref"),
                                  params: ["data": ["name": "Volcano",
                                                 "element": ["fire", "earth"] as Arr,
                                                    "cost": 10.0] as Obj])
        )
        let replaceRef: Ref? = replaceR?.get(field: Fields.ref)
        expect(replaceRef) == createR?.get(field: Fields.ref)
        expect(replaceR?.get(path: "data", "name")) == "Volcano"
        expect(replaceR?.get(path: "data", "element")) == ["fire", "earth"]
        expect(replaceR?.get(path: "data", "cost")) == 10.0
        
        
        let insertR = await(
            Insert(
                    ref: try! createR!.get(path: "ref"),
                    ts: Timestamp(timeIntervalSince1970: 1),
                action: Action.Create,
                params: ["data": ["cooldown": 5.0] as Obj]
            )
        )
        let insertRef: Ref? = insertR?.get(field: Fields.ref)
        expect(insertRef) == createR?.get(field: Fields.ref)
        expect(insertR?.get(path: "data")) == ["cooldown": 5.0] as Obj
        
        let removeR = await(
            Remove(ref: try! createR!.get(path: "ref"),
                    ts: Timestamp(timeIntervalSince1970: 2),
                action: Action.Delete)
        )
        expect(removeR as? Null) == Null()
        
        
        let deleteR = await(
            Delete(ref: try! createR!.get(path: "ref"))
        )
        expect(deleteR).notTo(beNil())
        let notFoundError = awaitError(Get(ref: try! createR!.get(path: "ref")))
        expect(notFoundError?.equalType(Error.NotFoundException(response: nil, errors: []))) == true
    }
    
    struct Ev: DecodableValue {
        let ref: Ref
        let ts: Double
        let action: String
        
        static func decode(value: Value) -> Ev?{
            return try? Ev(ref: value.get(path: "resource"), ts: value.get(path: "ts"), action: value.get(path: "action"))
        }
    }

    func testSets() {
        setupFaunaDB()
        
        let create1R = await(
            Create(ref: Ref("classes/spells"), params: ["data": ["name": "Magic Missile",
                                                                 "element": "arcane",
                                                                 "cost": 10.0] as Obj])
        )
        expect(create1R).notTo(beNil())
        let create1Ref: Ref = try! create1R!.get(path: "ref")
        
        let create2R = await(
            Create(ref: Ref("classes/spells"), params: ["data": ["name": "Fireball",
                                                                 "element": "fire",
                                                                 "cost": 10.0] as Obj])
        )
        expect(create2R).notTo(beNil())
        let create2Ref: Ref = try! create2R!.get(path: "ref")
        
        let create3R = await(
            Create(ref: Ref("classes/spells"), params: ["data": ["name": "Faerie Fire",
                                                                 "element": ["arcane", "nature"] as Arr,
                                                                 "cost": 10.0] as Obj])
        )
        expect(create3R).notTo(beNil())
        let create3Ref: Ref = try! create3R!.get(path: "ref")
        
        let create4R = await(
            Create(ref: Ref("classes/spells"), params: ["data": ["name": "Summon Animal Companion",
                                                              "element": "nature",
                                                                 "cost": 10.0] as Obj])
        )
        expect(create4R).notTo(beNil())
        let create4Ref: Ref = try! create4R!.get(path: "ref")
        
        
        let matchR = await(Paginate(resource: Match(index: Ref("indexes/spells_by_element"), terms: "arcane")))
        expect(matchR?.get(path: "data") as [Ref]?).to(contain(create1Ref))
        
        let matchEventsR = await(
            Paginate(resource: Match(index: Ref("indexes/spells_by_element"),
                                     terms: "arcane"),
                       events: true)
        )
        let pageEv: [Ev] = try! matchEventsR!.get(path: "data")
        expect(pageEv.map { $0.ref }).to(contain(create1Ref))

        
        let unionR = await(
            Paginate(resource: Union(sets: Match(index: Ref("indexes/spells_by_element"), terms: "arcane"),
                                           Match(index: Ref("indexes/spells_by_element"), terms: "fire")))
        
        )
        expect(unionR?.get(path: "data") as [Ref]?).to(contain(create1Ref, create2Ref))
        
        
        let unionEventsR = await(
            Paginate(resource: Union(sets: Match(index: Ref("indexes/spells_by_element"), terms: "arcane"),
                                           Match(index: Ref("indexes/spells_by_element"), terms: "fire")),
                       events: true)
        
        )
        let unionEventsPageEv: [Ev] = try! unionEventsR!.get(path: "data")
        expect(unionEventsPageEv.filter { $0.action == "create" }.map { $0.ref }).to(contain(create1Ref, create2Ref))


        let intersectionR = await(
            Paginate(resource: Intersection(sets: Match(index: Ref("indexes/spells_by_element"), terms: "arcane"),
                                                  Match(index: Ref("indexes/spells_by_element"), terms: "nature")))
        )
        let refs: [Ref]? = intersectionR?.get(path: "data")
        expect(refs).to(contain(create3Ref))

        let differenceR = await(
            Paginate(resource: Difference(sets: Match(index: Ref("indexes/spells_by_element"), terms: "nature"),
                                                Distinct(set:Match(index: Ref("indexes/spells_by_element"), terms: "arcane"))))
        )
        expect(differenceR?.get(path: "data") as [Ref]?).to(contain(create4Ref))
    }
    
    func testMiscellaneous() {
        let equalsR = await(
            Equals(terms: "fire", "fire")
        )
        expect(equalsR?.get()) == true
        
        
        let concatR = await(
            Concat(strList: ["Magic", "Missile"] as Arr)
        )
        expect(concatR?.get()) == "MagicMissile"
        
        
        let concatR2 = await(
            Concat(strList: ["Magic", "Missile"] as Arr,
                 separator: " ")
        )
        expect(concatR2?.get()) == "Magic Missile"
        
        
        let containsR = await(
            Contains(pathComponents: "favorites", "foods",
                             inExpr: ["favorites": ["foods": ["crunchings", "munchings"] as Arr] as Obj] as Obj)
        )
        expect(containsR?.get()) == true
        
        
        let containsR2 = await(
            Contains(path: ["favorites", "foods"] as Arr,
                inExpr: ["favorites": ["foods": ["crunchings", "munchings"] as Arr] as Obj] as Obj)
        )
        expect(containsR2?.get()) == true
        
        
        let selectR = await(
            Select(pathComponents: "favorites", "foods", 1, from: ["favorites": ["foods": ["crunchings", "munchings", "lunchings"] as Arr] as Obj] as Obj)
        )
        expect(selectR?.get()) == "munchings"
        
        let addR = await(
            Add(terms:100.0, 10.0)
        )
        expect(addR?.get()) == 110.0

        let multiplyR = await(
            Multiply(terms:100.0, 10.0)
        )
        expect(multiplyR?.get()) == 1000.0
        
        let subtractR = await(
            Subtract(terms:100.0, 10.0)
        )
        expect(subtractR?.get()) == 90.0

        let divideR = await(
            Divide(terms:100.0, 10.0)
        )
        expect(divideR?.get()) == 10.0

        let moduloR = await(
            Modulo(terms:101.0, 10.0)
        )
        expect(moduloR?.get()) == 1.0
        
        let andR = await(
            And(terms:true, false)
        )
        expect(andR?.get()) == false
        
        let orR = await(
            Or(terms:true, false)
        )
        expect(orR?.get()) == true
        
        let notR = await(
            Not(boolExpr:false)
        )
        expect(notR?.get()) == true
    }
    
    func testDateAndTime(){
        
        let timeR = await(Time("1970-01-01T00:00:00-04:00"))
        expect(timeR?.get()) == Timestamp(iso8601: "1970-01-01T00:00:00-04:00")

        let epochR = await(Epoch(offset: 30, unit: TimeUnit.second))
        expect(epochR?.get()) == Timestamp(timeIntervalSince1970: 30)

        let dateR = await(DateFn(iso8601: "1970-01-02"))
        expect(dateR?.get()) == Date(iso8601: "1970-01-02")
    }


    func  testAuthentication() {
        setupFaunaDB()
        
        let createR = await(
            Create(ref: Ref("classes/spells"), params: ["credentials": ["password": "abcdefg"] as Obj])
        )
        let createRef: Ref? = createR?.get(path: "ref")
        expect(createRef).toNot(beNil())
        
        let secret: String? = await(
            Login(ref: createRef!, params: ["password": "abcdefg"])
            )?.get(path: "secret")
        expect(secret).toNot(beNil())
        let oldSecret = client.secret
        client = Client(secret: secret!, observers: [Logger()])
        
        let logoutR: Bool? = await(
            Logout(invalidateAll: false)
        )?.get()
        
        expect(logoutR) == true

        
        client = Client(secret: oldSecret, observers: [Logger()])
        
        let identifyR = await(
            Identify(ref: createRef!, password: "abcdefg")
        )
        expect(identifyR?.get()) == true
    }
}

