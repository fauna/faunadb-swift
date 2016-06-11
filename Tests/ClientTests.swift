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
        let create = Create(Ref.databases, ["name": testDbName])
        var dbRef: Ref?
        var secret: String?
        client.query(create) { [weak self] result in
            dbRef = try! result.dematerialize().get(FaunaDBTests.fieldRef)
            self?.client.query(Create(Ref.keys, ["database": dbRef!, "role": "server"]))  { result in
                let sec: String = try! result.dematerialize().get("secret")
                self?.client = Client(configuration: ClientConfiguration(secret: sec))
                secret = sec
            }
        }
        expect(dbRef).toEventually(equal(Ref("databases/\(testDbName)")))
        expect(secret).toNotEventually(beNil())
        
        
        let obj: Obj = ["foo": "bar"]
        waitUntil { [weak self] done in
            self?.client.query(obj) { result in
                let responseValue = try! result.dematerialize() as! Obj
                expect(responseValue).to(equal(obj))
                done()
            }
        }

        
        var ecoString: String?
        client.query("ayz") { result in
            let responseValue = try! result.dematerialize() as! String
            ecoString = responseValue
        }
        expect(ecoString).toEventually(equal("ayz"))
    }
    
}
