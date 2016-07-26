//: [Previous](@previous)

import Foundation
import FaunaDB
import Result



let ourClientSecret = "our_secret"
var client = Client(secret: ourClientSecret, observers: [Logger()])

/*:
 Fauna client `Client` exposes query method to perform queries.
 
 > query function has 2 arguments, first argument is any instance that can be convertible to an expr (it must conforms to ValueConvertible). All fauna queries conforms to `ValueConvertible` but you can also create your owns. Second argument is a swift closure that will be called asyncronous right after the fauna server responses. Clousure callback receive a single parameter of `Result` enum type. Result can be either a value or an error.
 
 > It's up to you extend Client to provide other convenience query methods.
 */

client.query(Create(ref: Ref("databases"), params: Obj(["name": "db_name"])), completion: { (result: Result<Value, Error>) in
    if case .Failure(let error) = result {
        // handle error
    }
    let value = try! result.dematerialize()
})

/*:
> if we don't want to handle errors we can do..
*/

client.query(Create(ref: Ref("databases"), params: Obj(["name": "db_name"])), completion: { (result: Result<Value, Error>) in
    guard let value = try? result.dematerialize() else { return }
    //do whatever you want with the value
    
})

/*:
Normally you can rely on swift type inference and remove type information to make the code simpler and more readable. Also trailing closure makes the code cleaner.
*/

client.query(Create(ref: Ref("databases"), params: Obj(["name": "db_name"]))) { result in
    if case .Failure(let errr) = result {
        // handle error
    }
    let value = try! result.dematerialize()
}

/*:
 > It's up to you to extend client and provide a more convenience way to perform fauna queries. For instance we can extend Client to provides another query func that takes 2 closures as arguments, one for error handling and another for that handles the successful case.
 > trailing form can also be used in the last closure argument.
 

 ```
 client.query(Create(ref: Ref("databases"), params: Obj(["name": "db_name"])), failure: { error in
    print(error)
 },
 success:  { value in
    // do something with value
 })
 
```
 
 */


/*:
 We can also make use of RxSwift reactive extensions provided within RxFauna module.
 
 > we need to add it as a dependency and import it into our project. For more information about reactive programming, please visit: http://reactivex.io/ and its correspond swift implementation: https://github.com/ReactiveX/RxSwif.
 */
import RxSwift
import RxFaunaDB


client.rx_query(Create(ref: Ref("databases"), params: Obj(["name": "db_name"])))
    .mapWithField(["secret"])
    .doOnNext { (secret: String) in
        client = Client(secret: secret, observers: [Logger()])
    }
    .flatMap { _ in
        return client.rx_query(Create(ref: Ref("classes"), params: Obj(["name": "posts"])))
    }
    .flatMap { _ in
        return client.rx_query(Create(ref: Ref("indexes"), params: Obj(["name": "posts_by_tags_with_title",
            "source": Ref("classes/posts"),
            "terms": Arr(Obj(["field": Arr("data", "tags")])),
            "values": Arr()
            ])))
    }
    .subscribe()




/* 
 > ExpressionConvertible protocol allows us to make the code safter.
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
        return Obj(["name": name, "author": author, "content": content, "tags": Arr(tags.map {$0 as Value})])
    }
}


/*:
 > Now we can use BlogPost type to create instances into fauna db. Let's create many blogpost usign map expression and mapFauna syntactic sugar.
 */
client.query({
    let blogPosts: [BlogPost] =  (1...100).map { int in
        let blogName = "Blog Post \(String(int))"
        let tags: [String] = int % 2 == 0 ? ["philosophy", "travel"] : ["travel"]
        return BlogPost(name: blogName, author: "Fauna DB",  content: "bloig post content", tags: tags)
    }
    return blogPosts.mapFauna { (blogValue: ValueConvertible) in
        return Create(ref: Ref("classes/posts"), params: Obj(["data": blogValue]))
    }
}()) { result in
        // do something with the result.
    }



//: [Next](@next)
 
