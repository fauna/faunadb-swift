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
                            params: Obj(["name": testDbName]))
        let dbRef: Ref? = await(create)?.get(field: Fields.ref)
        expect(dbRef) == Ref("databases/\(testDbName)")
        let secret: String? = await(Create(ref: Ref("keys"), params: Obj(["database": dbRef!, "role": "server"])))?.get(path: "secret")
        expect(secret).notTo(beNil())

        client = Client(secret: secret!, endpoint: NSURL(string: "https://cloud.faunadb.com")! as URL)

        var value: Value?
        value = await(Create(ref: Ref("classes"), params: Obj(["name": "spells"])))
        expect(value).notTo(beNil())
        value = await(Create(ref: Ref("indexes"),
                          params: Obj(["name": "spells_by_element",
                        "source": Ref("classes/spells"),
                         "terms": Arr(
                                    Obj(("field", Arr("data", "element")))
                                  ),
                        "active": true])))
        expect(value).notTo(beNil())
    }

    
    override func tearDown() {
        _ = await(Delete(ref: testDbName))
        super.tearDown()
    }
    
    
    func testNotFoundException(){
        // MARK: NotFoundException

        setupFaunaDB()

        let error = awaitError(Get(ref: Ref("classes/spells/1234")))
        expect(error?.equalType(FaunaError.notFoundException(response: nil, errors: []))) == true
    }

    func testBadRequest() {
        // MARK: BadRequestException

        setupFaunaDB()

        let error = awaitError(Get(ref: 3))
        expect(error?.equalType(FaunaError.badRequestException(response: nil, errors: []))) == true
    }

    func testUnauthorized(){
        // MARK: UnauthorizedException
        client = Client(secret: "notavalidsecret", endpoint: URL(string: "https://cloud.faunadb.com")!)

        let error = awaitError(Get(ref: Ref("classes/spells/1234")))
        expect(error?.equalType(FaunaError.unauthorizedException(response: nil, errors: []))) == true
    }


    func testNetworkException(){
        // MARK: NetworkException
        client = Client(secret: client.secret, endpoint: URL(string: "https://notValidSubdomain.faunadb.com")!)
        let error = awaitError("Hi!")
        expect(error?.equalType(FaunaError.networkException(response: nil, error: nil, msg: nil))) == true
    }

    func testUnparseableDataException(){
        // MARK: UnparseableDataException
        do {
            try _ = Mapper.fromData([Float(3)] as AnyObject)
        }
        catch FaunaError.unparsedDataException(data: _, msg: _) {}
        catch {
            fail()
        }
    }

    func testDriverException(){
        // MARK: DriverException
        do {
            try _ = Client.toData(3 as AnyObject)
        }
        catch FaunaError.driverException(data: _, msg: _) {}
        catch {
            fail()
        }

    }
}
