//
//  FieldTests.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/7/16.
//
//

import XCTest
@testable import FaunaDB

class FieldTests: FaunaDBTests {


    func testFieldbyArrIdx() {
        
        let field = Field<Int>(0)
        
        let arr: Arr = [3, "Hi", Ref("classes/my_class")]
        let myInt = try! field.get(arr)
        XCTAssertEqual(myInt, 3)
        
        // let's see what happens if we use a wrong ValueType
        let obj: Obj = ["name": "my_db_name"]
        XCTAssertThrowss(FieldPathError.UnexpectedType(v: obj, expectedType: Arr.self, fieldPath: 0)) { try field.get(obj) }
        
        
        
        var arr2 = arr
        arr2.append(Obj(("key", Ref.classes)))
        let field2 = Field<Ref>(3, "key")
        let ref = try! field2.get(arr2)
        XCTAssertEqual(ref, Ref.classes)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
}


