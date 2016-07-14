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
    
    func testClient() {
        
        // Create a database
        var value = await(expr: Create(ref: Ref("databases"), params: ["name": testDbName]))
        expect(value).notTo(beNil())
        
        let dbRef: Ref = try! value!.get(field: Fields.ref)
        expect(dbRef) == Ref("databases/\(testDbName)")
        
        // Get a new key
        value = await(expr: Create(ref: Ref("keys"), params: ["database": dbRef, "role": "server"]))
        expect(value).notTo(beNil())
        
        let secret: String = try! value!.get(path: "secret")
        
        // set up client using the new secret
        client = Client(secret: secret, observers: [Logger()])
    
        
        // Create spells class
        value = await(expr: Create(ref: Ref("classes"), params: ["name": "spells"]))
        expect(value).notTo(beNil())
        
        
        // Create an index
        value = await(expr: Create(ref: Ref("indexes"), params: [
            "name": "spells_by_element",
            "source": Ref("classes/spells"),
            "terms": [["path": "data.element"] as Obj] as Arr,
            "active": true]))
        expect(value).notTo(beNil())
        
        
        // MARK: echo values
        
        value = await(expr: ["foo": "bar"] as Obj)
        expect(value).notTo(beNil())
        let objResult: Obj? = value?.get()
        expect(objResult) == ["foo": "bar"]
        
        
        value = await(expr: [1, 2, "foo"] as Arr)
        expect(value).notTo(beNil())
        let arrResult: Arr? = value?.get()
        expect(arrResult) == [Double(1), Double(2), "foo"]
        
        value = await(expr: "qux")
        expect(value).notTo(beNil())
        expect(value?.get()) == "qux"

        
        
        
        // Create an instance
        
        value = await(expr: Create(ref: Ref("classes/spells"), params: ["data": ["testField": "testValue"] as Obj]))
        expect(value).notTo(beNil())
        
        expect(value?.get(field: Fields.ref)?.ref).to(beginWith("classes/spells/"))
        expect(value?.get(field: Fields.`class`)) == Ref("classes/spells")
        expect(value?.get(path: "data", "testField")) == "testValue"
        
        // Check that it exists
        let ref: Ref? = value?.get(field: Fields.ref)
        value = await(expr: Exists(ref: ref!))
        expect(value?.get()) == true
        
        
        value = await(expr: Create(ref: Ref("classes/spells"), params:
                                                                    ["data": [ "testData" : [  "array": [1, "2", 3.4] as Arr,
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

    
        //MARK: Issue a batched query
        let classRef = Ref("classes/spells")
        let expr1 = Create(ref: classRef, params: ["data": ["queryTest1": "randomText1"] as Obj])
        let expr2 = Create(ref: classRef, params: ["data": ["queryTest2": "randomText2"] as Obj])
        
        value = await(expr: Arr(expr1.value, expr2.value))
        let arr: Arr? = value?.get()
        expect(arr?.count) == 2
        expect(arr?[0].get(path: "data", "queryTest1")) == "randomText1"
        expect(arr?[1].get(path: "data", "queryTest2")) == "randomText2"
        
        
        //MARK: "issue a paginated query"
        
        
        let randomClassName = String(randomWithLength: 8)
        
        value = await(expr: Create(ref: Ref("classes"), params: ["name": randomClassName]))
        expect(value).notTo(beNil())
        
        let classRef2: Ref? = value?.get(field: Fields.ref)
        expect(classRef2) == Ref("classes/" + randomClassName)
        
        
        value = await(expr: Create(ref: Ref("indexes"), params: ["name": randomClassName + "_class_index", "source": classRef, "active": true, "unique": false]))
        expect(value).notTo(beNil())
        let randomClassIndex: Ref? = value?.get(field: Fields.ref)
        expect(randomClassIndex) == Ref("indexes/" + randomClassName + "_class_index")

        
        value = await(expr: Create(ref: Ref("indexes"), params: ["name": randomClassName + "_test_index", "source": classRef, "active": true, "unique": false, "terms": [["path": "data.queryTest1"] as Obj] as Arr]))
        expect(value).notTo(beNil())
        let testIndex: Ref? = value?.get(field: Fields.ref)
        expect(testIndex) == Ref("indexes/" + randomClassName + "_test_index")
        

        let randomText1 = String(randomWithLength: 8)
        let randomText2 = String(randomWithLength: 8)
        let randomText3 = String(randomWithLength: 8)
        
        let create1Value = await(expr: Create(ref: classRef, params: ["data": ["queryTest1": randomText1] as Obj]))
        expect(create1Value).notTo(beNil())
        let create2Value = await(expr: Create(ref: classRef, params: ["data": ["queryTest1": randomText2] as Obj]))
        expect(create2Value).notTo(beNil())
        let create3Value = await(expr: Create(ref: classRef, params: ["data": ["queryTest1": randomText3] as Obj]))
        expect(create3Value).notTo(beNil())
        
        
        let queryMatchValue = await(expr: Paginate(resource: Match(index: testIndex!, terms: randomText1)))
        expect(queryMatchValue).notTo(beNil())
        

    }
    
    // Helper
    private func await(expr expr: Expr) -> Value? {
        var res: Value?
        waitUntil(timeout: 5) { [weak self] done in
            self?.client.query(expr) { result in
                guard let value = try? result.dematerialize() else {
                    fail()
                    return
                }
                res = value
                done()
            }
        }
        return res
    }
    
}
