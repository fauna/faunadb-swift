//
//  BlogPost.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
import FaunaDB

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

extension BlogPost: DecodableValue {
    static func decode(value: Value) -> BlogPost? {
        return try? self.init(name: value.get(path: "name"),
                              author: value.get(path: "author"),
                              content: value.get(path: "content"),
                              tags: value.get(path: "tags") ?? [])
    }
}

extension BlogPost: FaunaModel {
    
    
    var value: Value {
        return Obj(["name": name, "author": author, "content": content, "tags": Arr(tags)])
    }
    
    static var classRef: Ref { return Ref("classes/posts") }
}

