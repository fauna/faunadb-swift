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
    let refId: Ref?

    init(name:String, author: String, content: String, tags: [String] = [], refId: Ref? = nil){
        self.name = name
        self.author = author
        self.content = content
        self.tags = tags
        self.refId = refId
    }
}

extension BlogPost: DecodableValue {
    static func decode(value: Value) -> BlogPost? {
        guard let refId: Ref = value.get(path: "ref") else { return nil }
        return try? self.init(name: value.get(path: "data", "name"),
                                               author: value.get(path: "data", "author"),
                                               content: value.get(path: "data", "content"),
                                               tags: value.get(path: "data", "tags") ?? [],
                                               refId: refId)
    }
}

extension BlogPost: FaunaModel {


    var value: Value {
        return Obj(["name": name, "author": author, "content": content, "tags": Arr(tags)])
    }

    static var classRef: Ref { return Ref("classes/posts") }
}

extension BlogPost: Equatable {}

func ==(lhs: BlogPost, rhs: BlogPost) -> Bool{
    return lhs.refId == rhs.refId
}
