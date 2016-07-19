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
        let data: [String: Any] = ["name": name, "author": author, "content": content, "tags": tags]
        return data.value
    }
}

extension BlogPost: DecodableValue {
    static func decode(value: Value) -> BlogPost? {
        return try? BlogPost(name: value.get(path: "name"), author: value.get(path: "author"), content: value.get(path: "content"))
    }
}


class FieldTests: FaunaDBTests {

    func testField() {
        
        let field = Field<Int>(0)
        
        let arr: Arr = [3, "Hi", Ref("classes/my_class")]
        let myInt = try! field.get(arr)
        expect(myInt) ==  3
        
        // let's see what happens if we use a wrong Value
        let obj: Obj = ["name": "my_db_name"]
        XCTAssertThrows(FieldPathError.UnexpectedType(value: obj, expectedType: Arr.self, path: [0])) { try field.get(obj) }
        
        var arr2 = arr
        arr2.append(["key": Ref("classes")] as Obj)
        let field2 = Field<Ref>(3, "key")
        let ref = try! field2.get(arr2)
        expect(ref) == Ref("classes")
        
        let homogeneousArray = [1, 2, 3]
        let int: Int = try! homogeneousArray.get(path: 0)
        expect(int) ==  1
        
        let homogeneousArray2 = ["Hi", "Hi2"]
        let string: String = try! homogeneousArray2.get(path: 1)
        expect(string) == "Hi2"
        
        let homogeneousArray3 = [Timestamp()]
        let timestamp: Timestamp? = homogeneousArray3.get(path: 0)
        expect(timestamp).notTo(beNil())
        
        let complexArr = [3, 5, ["test": ["test2": ["test3": [1,2,3]]]]]
        let int2: Int = try! complexArr.get(path: 2, "test", "test2", "test3", 0)
        expect(int2) ==  1
        
        
        //MARK: DecodableValue
        let blogField = Field<BlogPost>(0, "data")
        
        let blogPostData = ["name": "My Blog Post", "author": "FaunaDB Inc", "content": "My Content", "tags": ["DB", "Performance"] as Arr] as Obj
        let objContainingPost: Arr = [["data" : blogPostData] as Obj]
    
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
        let blogPostArr: Arr = [["data": [blogPostData, blogPostData, blogPostData, blogPostData, blogPostData] as Arr] as Obj]
        let postArray: [BlogPost]? = blogPostArr.get(path: 0, "data")
        expect(postArray?.count) == 5
        
        // check collections using Fields
        
        let postArray2: [BlogPost]? = blogField.getOptionalArray(blogPostArr)
        expect(postArray2?.count) == 5

        let postArray3: [BlogPost] = try! blogField.getArray(blogPostArr)
        expect(postArray3.count) == 5
    }
}


