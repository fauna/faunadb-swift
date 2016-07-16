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
    
    lazy var client: Client = {
        return Client(secret: FaunaDBTests.secret)
    }()
    
    let testDbName = "faunadb-swift-test-\(arc4random())"
    
    override func setUp() {
        super.setUp()
        Nimble.AsyncDefaults.Timeout = 5.SEC
    }
    
    private func setupFaunaDB(){

        var value: Value?
        
        // Create a database
        value = await(
            Create(ref: Ref("databases"),
                params: ["name": testDbName])
        )
        expect(value).notTo(beNil())
        
        let dbRef: Ref = try! value!.get(field: Fields.ref)
        expect(dbRef) == Ref("databases/\(testDbName)")
        
        // Get a new key
        value = await(
            Create(ref: Ref("keys"),
                params: ["database": dbRef,
                    "role": "server"])
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
                params:
                ["name": "spells_by_element",
                    "source": Ref("classes/spells"),
                    "terms": [["path": "data.element"] as Obj] as Arr,
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
        
        let value2 = await([expr1.value, expr2.value])
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
                                   "terms": [["path": "data.queryTest1"] as Obj] as Arr])
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
                          "terms": [["path": "data.uniqueTest1"] as Obj] as Arr,
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

        expect(Ref("indexes/spells_by_element")) == set?.value.get(path: "match")
        expect("arcane") == set?.value.get(path: "terms")
    }
    
    
    
    // MARK: Helpers
    
    private func await(expr: ValueConvertible) -> Value? {
        var res: Value?
        waitUntil(timeout: 5) { [weak self] done in
            self?.client.query(expr) { result in
                res = try? result.dematerialize()
                done()
            }
        }
        return res
    }
    
    private func awaitError(expr: Expr) -> FaunaDB.Error? {
        var res: FaunaDB.Error?
        waitUntil(timeout: 5) { [weak self] done in
            self?.client.query(expr) { result in
                res = result.error
                done()
            }
        }
        return res
    }
}
