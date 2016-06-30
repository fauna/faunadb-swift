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


    func testField() {
        
        let field = Field<Int>(0)
        
        let arr: Arr = [3, "Hi", Ref("classes/my_class")]
        let myInt = try! field.get(arr)
        XCTAssertEqual(myInt, 3)
        
        // let's see what happens if we use a wrong Value
        let obj: Obj = ["name": "my_db_name"]
        XCTAssertThrowss(FieldPathError.UnexpectedType(value: obj, expectedType: Arr.self, path: [0])) { try field.get(obj) }
        
        var arr2 = arr
        arr2.append(["key": Ref.classes] as Obj)
        let field2 = Field<Ref>(3, "key")
        let ref = try! field2.get(arr2)
        XCTAssertEqual(ref, Ref.classes)
        
        let homogeneousArray = [1, 2, 3]
        let int: Int = try! homogeneousArray.get(0)
        XCTAssertEqual(int, 1)
        
        let homogeneousArray2 = ["Hi", "Hi2"]
        let string: String = try! homogeneousArray2.get(1)
        XCTAssertEqual(string, "Hi2")
        
        let homogeneousArray3 = [Timestamp()]
        let timestamp: Timestamp? = homogeneousArray3.get(0)
        XCTAssertTrue(timestamp != nil)
        
        let complexArr = [3, 5, ["test": ["test2": ["test3": [1,2,3]]]]]
        let int2: Int = try! complexArr.get(2, "test", "test2", "test3", 0)
        XCTAssertEqual(int2, 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
}


