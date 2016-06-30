//
//  ClientTests.swift
//  FaunaDB
//
//  Created by Martin Barreto on 5/31/16.
//
//

import XCTest
import Nimble
import Result

@testable import FaunaDB


class ClientTests: FaunaDBTests {
    
    lazy var client: Client = {
        let result = Client(configuration: ClientConfiguration(secret: FaunaDBTests.secret))
        result.observers = [Logger()]
        return result
    }()
    
    let testDbName = "faunadb-swift-test-\(arc4random())"
    
    override func setUp() {
        super.setUp()
        Nimble.AsyncDefaults.Timeout = 3.SEC
    }
    
    func testClient() {
        let create = Create(ref: Ref.databases, params: ["name": testDbName])
        var dbRef: Ref?
        var secret: String?
        client.query(create) { [weak self] result in
            dbRef = try! result.dematerialize().get(FaunaDBTests.fieldRef)
            self?.client.query(Create(ref: Ref.keys, params: ["database": dbRef!, "role": "server"]))  { result in
                let sec: String = try! result.dematerialize().get("secret")
                self?.client = Client(configuration: ClientConfiguration(secret: sec))
                secret = sec
            }
        }
        expect(dbRef).toEventually(equal(Ref("databases/\(testDbName)")))
        expect(secret).toNotEventually(beNil())
        
        
        // Create spells class
        waitUntil(timeout: 3) { [weak self] done in
            self?.client.query(Create(ref: Ref.classes, params: ["name": "spells"])) { result in
                if case .Failure(_) = result {
                    fail()
                }
                done()
            }
        }
        
        // Create a index
        waitUntil(timeout: 3) { [weak self] done in
            self?.client.query(Create(ref: Ref.indexes, params: [
            "name": "spells_by_element",
            "source": Ref("classes/spells"),
            "terms": [["path": "data.element"] as Obj] as Arr,
                "active": true])){  result in
                    if case .Failure(_) = result {
                        fail()
                    }
                    done()
            }
        }

        
        let obj: Obj = ["foo": "bar"]
        waitUntil { [weak self] done in
            self?.client.query(obj) { result in
                let responseValue = try! result.dematerialize() as! Obj
                expect(responseValue).to(equal(obj))
                done()
            }
        }
        

//        var ecoString: String?
//        client.query("ayz") { result in
//            let responseValue = try! result.dematerialize() as! String
//            ecoString = responseValue
//        }
//        expect(ecoString).toEventually(equal("ayz"))
        
        
        // Create an instance
        var inst: Value?
        waitUntil(timeout: 3) { [weak self] done in
            self?.client.query(Create(ref: "classes/spells", params: ["data": ["testField": "testValue"] as Obj])){ result in
                inst = try! result.dematerialize()
                done()
            }
        }
        
        expect(try! inst?.get(FaunaDBTests.fieldRef).ref).to(beginWith("classes/spells/"))
        let dataField = Field<String>("data", "testField")
        expect(inst?.get(dataField)).to(equal("testValue"))
        
        
        waitUntil(timeout: 3) { [weak self] done in
            self?.client.query(Exists(ref: try! inst!.get(FaunaDBTests.fieldRef))){ result in
                let responseValue = try! result.dematerialize() as! Bool
                expect(responseValue).to(beTrue())
                done()
            }
        }
        
        
        // create instance 2
//        let testData: Obj = ["array": Arr(1, "2", 3.4),
//                             "bool": true,
//                             "num": 1234,
//                             "string": "sup",
//                             "float": 1.234,
//                             "null": Null()]
//        waitUntil(timeout: 3) { [weak self] done in
//            self?.client.query(Create(Ref("classes/spells"), Obj(("data", Obj(("testData", testData)))))){ result in
//                let inst = try! result.dematerialize()
//                let value: Obj = try! inst.get("data", "testData")
//                let array_0: Int = try! value.get("array", 0)
//                let array_1: String = try! value.get("array", 1)
//                let array_2: Double = try! value.get("array", 2)
//                let string: String = try! value.get("string")
//                let integer: Int = try! value.get("num")
//                done()
//            }
//        }
        
        
//        val inst2 = await(client.query(Create(Ref("classes/spells"),
//        Obj("data" -> Obj(
//        "testData" -> Obj(
//        "array" -> Arr(1, "2", 3.4),
//        "bool" -> true,
//        "num" -> 1234,
//        "string" -> "sup",
//        "float" -> 1.234,
//        "null" -> NullV))))))
//        
//        val testData = inst2("data", "testData")
//        
//        testData.isDefined shouldBe true
//        testData("array", 0).as[Long].get shouldBe 1
//        testData("array", 1).as[String].get shouldBe "2"
//        testData("array", 2).as[Double].get shouldBe 3.4
//        testData("string").as[String].get shouldBe "sup"
//        testData( "num").as[Long].get shouldBe 1234
//        
        
        
    }
    
}
