//
//  ClientConfigurationTests.swift
//  FaunaDBTests
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import XCTest
import Nimble
@testable import FaunaDB


struct BlogPost {
    let name: String
    let author: String
    let content: String
    let tags: [String]
    
    init(name:String, author: String, content: String, tags: [String] = []){
        self.name = name
        self.author = author
        self.content = content
        self.tags = tags
    }
    
    var fId: String?
}

extension BlogPost: ValueConvertible {
    
    var value: Value {
        return [  "name": name,
                "author": author,
               "content": content,
                  "tags": Arr(tags)] as Obj
    }
}

extension BlogPost: DecodableValue {
    static func decode(value: Value) -> BlogPost? {
        return try? BlogPost(name: value.get(path: "name"), author: value.get(path: "author"), content: value.get(path: "content"))
    }
}


class FieldTests: FaunaDBTests {

    
    func testStandaloneField() {
        let arrField = Field<Int>(0)
        
        let arr = Arr(3, "Hi", Ref("classes/my_class"))
        let arrInt = try? arrField.get(arr)
        expect(arrInt) ==  3
        expect(try! arrField.get(arr)) == 3
        
        let objField = Field<Int>("data", 0)
        let obj: Obj = ["data" : Arr(3, "Hi", Ref("classes/my_class"))]
        let objInt = try? objField.get(obj)
        expect(objInt) ==  3
        expect(try! arrField.get(arr)) == 3
        
    }
    
    
    func testFieldErrors() {
        let arrField = Field<Int>(0)
        let objField = Field<Int>("data")
        let obj: Obj = ["name": "my_db_name"]
        var arr = Arr(1, 2, 3)
        
        XCTAssertThrows(FieldPathError.UnexpectedType(value: obj, expectedType: Arr.self, path: [0])) { try arrField.get(obj) }
        XCTAssertThrows(FieldPathError.UnexpectedType(value: arr, expectedType: Obj.self, path: ["data"])) { try objField.get(arr) }
        
        arr.removeAll()
        XCTAssertThrows(FieldPathError.NotFound(value: arr, path: [9])) { try Field<Int>(9).get(arr) }
        XCTAssertThrows(FieldPathError.NotFound(value: obj, path: ["data"])) { try objField.get(obj) }
    }
    
    func testFieldComposition() {
        let obj: Obj = ["name": "my_db_name"]
        let arr: Arr = Arr(0, 1, 2, obj, "FaunaDB")
        
        let zip1: (Value -> (Int, Int)?) = FieldComposition.zip(field1: 0, field2: 2)
        let zip2: (Value -> (Int, Int, String)?) = FieldComposition.zip(field1: 0, field2: 2, field3: [3 , "name"])
        let zip3: (Value -> (Int, Int, String, Obj)?) = FieldComposition.zip(field1: 0, field2: 2, field3: [3 , "name"], field4: 3)
        let zip4: (Value -> (Int, Int, String, Obj, String)?) = FieldComposition.zip(field1: 0, field2: 2, field3: [3 , "name"], field4: 3, field5: 4)
        
        let zip1R = zip1(arr)
        let zip2R = zip2(arr)
        let zip3R = zip3(arr)
        let zip4R = zip4(arr)
        
        expect(zip1R).toNot(beNil())
        expect(zip2R).toNot(beNil())
        expect(zip3R).toNot(beNil())
        expect(zip4R).toNot(beNil())
        expect((0, 2) == zip1R!).to(beTrue())
        expect((0, 2, "my_db_name") == zip2R!).to(beTrue())
        expect((0, 2, "my_db_name", obj) == zip3R!).to(beTrue())
        expect((0, 2, "my_db_name", obj) == zip3R!).to(beTrue())
        expect((0, 2, "my_db_name", obj, "FaunaDB") == zip4R!).to(beTrue())
        
        
        var fieldLiteralR: Field<Int>? = "data"
        expect(fieldLiteralR).toNot(beNil())
        fieldLiteralR = 3
        expect(fieldLiteralR).toNot(beNil())
        fieldLiteralR = ["data", 3]
        expect(fieldLiteralR).toNot(beNil())
        
        
        let zip1T: (Value throws -> (Int, Int)) = FieldComposition.zip(field1: 0, field2: 2)
        let zip2T: (Value throws -> (Int, Int, String)) = FieldComposition.zip(field1: 0, field2: 2, field3: [3 , "name"])
        let zip3T: (Value throws -> (Int, Int, String, Obj)) = FieldComposition.zip(field1: 0, field2: 2, field3: [3 , "name"], field4: 3)
        let zip4T: (Value throws -> (Int, Int, String, Obj, String)) = FieldComposition.zip(field1: 0, field2: 2, field3: [3 , "name"], field4: 3, field5: 4)
        
        
        let zip1TR: (Int, Int) = try! arr.get(fieldComposition: zip1T)
        let zip2TR: (Int, Int, String) = try! arr.get(fieldComposition: zip2T)
        let zip3TR: (Int, Int, String, Obj) = try! arr.get(fieldComposition: zip3T)
        let zip4TR: (Int, Int, String, Obj, String) = try! arr.get(fieldComposition: zip4T)
        expect(zip1TR == zip1R!).to(beTrue())
        expect(zip2TR == zip2R!).to(beTrue())
        expect(zip3TR == zip3R!).to(beTrue())
        expect(zip4TR == zip4R!).to(beTrue())
        
        
        let zip1FR: (Int, Int)? = arr.get(field1: 0, field2: 2)
        let zip2FR: (Int, Int, String)? = arr.get(field1: 0, field2: 2, field3: [3 , "name"])
        let zip3FR: (Int, Int, String, Obj)? = arr.get(field1: 0, field2: 2, field3: [3 , "name"], field4: 3)
        let zip4FR: (Int, Int, String, Obj, String)? = arr.get(field1: 0, field2: 2, field3: [3 , "name"], field4: 3, field5: 4)
        expect(zip1FR).toNot(beNil())
        expect(zip2FR).toNot(beNil())
        expect(zip3FR).toNot(beNil())
        expect(zip4FR).toNot(beNil())
        expect(zip1FR! == zip1R!).to(beTrue())
        expect(zip2FR! == zip2R!).to(beTrue())
        expect(zip3FR! == zip3R!).to(beTrue())
        expect(zip4FR! == zip4R!).to(beTrue())
    }
    
    
    func testAtMehod() {
        let field = Field<Int>("data", 3, "fauna")
        let field2 = field.at(Field<String>("FaunaDB"))
        expect(field2.path.count) == 4
        expect(field2.path[3] as? String) == "FaunaDB"
    }
    
    
    func testField(){
        var arr = Arr(1, 2, 3)
        arr.append(["key": Ref("classes")] as Obj)
        let field2 = Field<Ref>(3, "key")
        let ref = try! field2.get(arr)
        expect(ref) == Ref("classes")
        
        let homogeneousArray = Arr(1, 2, 3)
        let int: Int = try! homogeneousArray.get(path: 0)
        expect(int) ==  1
        
        let homogeneousArray2 = Arr("Hi", "Hi2")
        let string: String = try! homogeneousArray2.get(path: 1)
        expect(string) == "Hi2"
        
        let homogeneousArray3 = Arr(Timestamp())
        let timestamp: Timestamp? = homogeneousArray3.get(path: 0)
        expect(timestamp).notTo(beNil())
        
        let complexArr = Arr(3, 5, ["test": ["test2": ["test3": Arr(1,2,3)] as Obj] as Obj] as Obj)
        let int2: Int = try! complexArr.get(path: 2, "test", "test2", "test3", 0)
        expect(int2) ==  1
    }
    
    
    func testFieldUsingACustomDecodableValue(){
        //MARK: DecodableValue
        let blogField = Field<BlogPost>(0, "data")
        
        let blogPostData = ["name": "My Blog Post", "author": "FaunaDB Inc", "content": "My Content", "tags": Arr("DB", "Performance")] as Obj
        let objContainingPost = Arr(["data" : blogPostData] as Obj)
        
        let post: BlogPost? = objContainingPost.get(path: 0, "data")
        expect(post?.name) == "My Blog Post"
        expect(post?.author) == "FaunaDB Inc"
        expect(post?.content) == "My Content"
        
        // checking non-collection item using Field instance.
        let post2: BlogPost? = blogField.getOptional(objContainingPost)
        expect(post2?.name) == "My Blog Post"
        expect(post2?.author) == "FaunaDB Inc"
        expect(post2?.content) == "My Content"
        
        
        let post3: BlogPost = try! blogField.get(objContainingPost)
        expect(post3.name) == "My Blog Post"
        expect(post3.author) == "FaunaDB Inc"
        expect(post3.content) == "My Content"
        
        // check decoding an array of a DecodableValue
        let blogPostArr = Arr(["data": Arr(blogPostData, blogPostData, blogPostData, blogPostData, blogPostData)] as Obj)
        let postArray: [BlogPost]? = blogPostArr.get(path: 0, "data")
        expect(postArray?.count) == 5
        
        // check collections using Fields
        
        let postArray2: [BlogPost]? = blogField.collectOptional(blogPostArr)
        expect(postArray2?.count) == 5
        let postArray2C: [BlogPost]? = blogPostArr.get(field: [0, "data"])
        expect(postArray2C?.count) == 5
        
        let postArray3: [BlogPost] = try! blogField.collect(blogPostArr)
        expect(postArray3.count) == 5
        
        
    }
    
    func testFieldFromAValueConvertible(){
        
        let blogPost = BlogPost(name: "My Blogpost", author: "FaunaDB", content: "My content")
        expect(blogPost.get(field: "name")) == "My Blogpost"
        expect(blogPost.get(path: "author")) == "FaunaDB"
        expect(blogPost.get(field: Field("content"))) == "My content"
    }
}


