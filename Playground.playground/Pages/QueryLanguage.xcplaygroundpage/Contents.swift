//: [Previous](@previous)
import Foundation
import FaunaDB

/*:
### How to transverse response data.
*/
 
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
}

extension BlogPost: ValueConvertible {
    
    var value: Value {
        return (["name": name, "author": author, "content": content, "tags": Arr(tags.map {$0 as Value})] as Obj)
    }
}

let blogPost: ValueConvertible = BlogPost(name: "My first bloigpost", author: "Fauna Inc", content: "content", tags: ["getting started with fauna", "set up fauna db"])

/*:
> Notice that we can transverse values using any ValueConvertible type, any Value type or eventually any custom `ValueConvertible` type.
 */

let arr: Arr = try blogPost.get("tags")


//: [Next](@ne