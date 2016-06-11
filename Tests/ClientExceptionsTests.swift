//
//  ClientExceptions.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/10/16.
//
//

import Foundation

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
        
       
        
        
        waitUntil(timeout: 3){ [weak self] action in
            self?.client.query(Create(Ref.classes, ["name": "spells"])){ _ in
                action()
            }
        }
        waitUntil(timeout: 3){ [weak self] action in
            self?.client.query(Create(Ref.indexes, ["name": "spells_by_element",
                                          "source": Ref("classes/spells"),
                                          "terms": Arr(Obj(("path", "data.element"))),
                "active": true])){ _ in
                action()
            }
        }
        waitUntil(timeout: 3) {[weak self] done in
            self?.client.query(Get("classes/spells/1234")) { result in
                guard case let .Failure(queryError) = result, case .NotFoundException(response: _, errors: _, msg: _) = queryError else  {
                    fail()
                    done()
                    return
                }
                done()
            }
        }
    }

}


