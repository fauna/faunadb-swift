//
//  ClientExceptions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/10/16.
//
//
import XCTest
import Nimble
import Result
@testable import FaunaDB


class ClientExceptionsTests: FaunaDBTests {
    
    lazy var client: Client = {
        let result = Client(configuration: ClientConfiguration(secret: FaunaDBTests.secret))
        result.observers = [Logger()]
        return result
    }()
    
    let testDbName = "faunadb-swift-test-\(arc4random())"
    
    
    override func setUp() {
        super.setUp()
        Nimble.AsyncDefaults.Timeout = 6.SEC
    }
    
    func testClientExceptions() {
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
        
       
        
        
        waitUntil(timeout: 3){ [weak self] action in
            self?.client.query(Create(ref: Ref.classes, params: ["name": "spells"])){ _ in
                action()
            }
        }
        waitUntil(timeout: 3){ [weak self] action in
            self?.client.query(Create(ref: Ref.indexes, params: ["name": "spells_by_element",
                                          "source": Ref("classes/spells"),
                                          "terms": [["path": "data.element"] as Obj] as Arr ,
                "active": true])){ _ in
                action()
            }
        }
        
        
        waitUntil(timeout: 3){ [weak self] action in
            self?.client.query(Create(ref: Ref.indexes, params: ["name": "spells_by_element",
                "source": Ref("classes/spells"),
                "terms": [["path": "data.element"] as Obj] as Arr ,
                "active": true])){ _ in
                    action()
            }
        }
        
        waitUntil(timeout: 3) {[weak self] done in
            self?.client.query(Get(ref: "classes/spells/1234")) { result in
                guard case let .Failure(queryError) = result, case .NotFoundException(response: _, errors: _, msg: _) = queryError else {
                    fail()
                    done()
                    return
                }
                done()
            }
        }
    }
    
    func testUnauthorized(){
        let badClient = Client(configuration: ClientConfiguration(secret: "notavalidsecret"))
        waitUntil(timeout: 3) { done in
            badClient.query(Get(ref: "classes/spells/1234")) { result in
                guard case let .Failure(queryError) = result, case .UnauthorizedException(response: _, errors: _, msg: _) = queryError else {
                    fail()
                    done()
                    return
                }
                done()
            }
        }
    }

}


