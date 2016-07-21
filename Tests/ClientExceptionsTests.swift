//
//  ClientConfigurationTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
import Nimble
import Result
@testable import FaunaDB


class ClientExceptionsTests: FaunaDBTests {
    
    private func setupFaunaDB(){
        
        let create = Create(ref: Ref("databases"),
                            params: ["name": testDbName])
        let dbRef: Ref? = await(create)?.get(field: Fields.ref)
        expect(dbRef) == Ref("databases/\(testDbName)")
        let secret: String? = await(Create(ref: Ref("keys"), params: ["database": dbRef!, "role": "server"]))?.get(path: "secret")
        expect(secret).notTo(beNil())
        
        client = Client(secret: secret!)
        
        var value: Value?
        value = await(Create(ref: Ref("classes"), params: ["name": "spells"]))
        expect(value).notTo(beNil())
        value = await(Create(ref: Ref("indexes"),
                          params: ["name": "spells_by_element",
                        "source": Ref("classes/spells"),
                         "terms": [["field": "data.element"] as Obj] as Arr,
                        "active": true]))
        expect(value).notTo(beNil())
    }
    
    func testNotFoundException(){
        // MARK: NotFoundException
        
        setupFaunaDB()
        
        let error = awaitError(Get(ref: Ref("classes/spells/1234")))
        expect(error?.equalType(Error.NotFoundException(response: nil, errors: []))) == true
    }
    
    func testBadRequest() {
        // MARK: BadRequestException
        
        setupFaunaDB()
        
        let error = awaitError(Get(ref: 3))
        expect(error?.equalType(Error.BadRequestException(response: nil, errors: []))) == true
    }
    
    func testUnauthorized(){
        // MARK: UnauthorizedException
        client = Client(secret: "notavalidsecret")
        
        let error = awaitError(Get(ref: Ref("classes/spells/1234")))
        expect(error?.equalType(Error.UnauthorizedException(response: nil, errors: []))) == true
    }
    
    
    func testNetworkException(){
        // MARK: NetworkException
        client = Client(secret: client.secret, endpoint: NSURL(string: "https://notValidSubdomain.faunadb.com")!)
        let error = awaitError("Hi!")
        expect(error?.equalType(Error.NetworkException(response: nil, error: nil, msg: nil))) == true
    }
    
    func testUnparseableDataException(){
        // MARK: UnparseableDataException
        do {
            try Mapper.fromData([Float(3)])
        }
        catch Error.UnparsedDataException(data: _, msg: _) {}
        catch {
            fail()
        }
    }
    
    func testDriverException(){
        // MARK: DriverException
        do {
            try Client.toData(3)
        }
        catch Error.DriverException(data: _, msg: _) {}
        catch {
            fail()
        }

    }
}


