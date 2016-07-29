# FaunaDB Swift Client

<p align="left">
<a href="https://travis-ci.org/faunadb/faunadb-swift"><img src="https://travis-ci.org/faunadb/faunadb-swift.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/faunadb-swift"><img src="https://img.shields.io/badge/pod-1.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/faunadb/faunadb-swift/master/LICENSE"><img src="http://img.shields.io/badge/license-Mozilla Public License 2.0-blue.svg?style=flat" alt="License: Mozilla Public License 2.0" /></a>
</p>

By [Fauna, Inc](http://faunadb.com).

## WIP

***Please, note that this driver is being developed. Changes will happen until we have an official release.***

## Inroduction

This repository contains FaunaDB driver for Swift language. Basically it provides high level abstractions that allows us to work with fauna DB efficiently and without the need to deal with rest messages, networking errors, data encoding, decoding and so on.

Apart of the FaunaDB driver, we also provide [RxSwift](https://github.com/ReactiveX/RxSwift) reactive programming [extensions](RxSources/Client+Rx.swift) for FaunaDB.

> working on another language? Take a look at our github account, we provide Fauna DB drivers for many popular languages and many others are coming. Don't hesitate to contact us if the language you are working on is not supported yet. Notice you can always use the [REST API](https://faunadb.com/documentation/rest) directly.

## About Fauna BD

FaunaDB is a state of the art db system that aims to be as reliable, secure and fast as possible. For more information about Fauna, please visit our [website](https://faunadb.com/). If you are curious about Fauna DB design and architecture, please check out the [Design and Architecture of FaunaDB](https://faunadb.com/pdf/Design%20and%20Architecture%20of%20FaunaDB%2020160701.pdf) whitepaper.

## Requirements

* iOS 8.0+
* Xcode 7.3.1+
* Swift 2.2

## Getting started

1. Install the driver first. We can install the driver either by using [Carthage](https://github.com/Carthage/Carthage), [CocoaPods](https://cocoapods.org/) or manually as Embedded Framework. Go to [Installation](#installation) section to know how.

2. If you haven’t already, [sign up for an account](https://faunadb.com/#signup-modal) to start using FaunaDB.

3. From here, Fauna DB [tutorial](https://faunadb.com/tutorials) will walk you through step by step how to get started with Fauna DB.

#### Basic Usage

```swift
import Foundation
import Result
import FaunaDB

// create a fauna client
// Logger will shows in the Xcode console the curl representation of each message sent to FaunaDB, it also shows the fauna response data. This is useful during app development.

let secret = <YOUR_CLIENT_SECRET>
let dbName = <YOUR_DB_NAME>
var client = Client(secret: secret, observers: [Logger()])

func setUpSchema(callback: (Result<Value, Error> -> ()){
  // Create a database
  client.query(Create(ref: Ref("databases"), params: Obj(["name": dbName]))) { createDbR in

      // create a access key for this particular database
      client.query(Create(ref: Ref("keys"), params: Obj(["database": Ref("databases/\(dbName)"), "role": "server"]))) { createKeyR in
          guard let result = try? createKeyR.dematerialize() else {
              callback(createKeyR)
              return
          }
          // get the new secret key provided by fauna
          let newSecret: String = try! result.get(path: "secret")
          // set up the new client to use the new key
          client = Client(secret: newSecret, observers: [Logger()])
          // create a new class into dbName database
          client.query(Create(ref: Ref("classes"), params: Obj(["name": "posts"]))) { createClassR in
              guard let _ = try? createClassR.dematerialize() else {
                  callback(createClassR)
                  return
              }
              // create some indexes to be able to perform queries
              client.query(
                Do(exprs:
                          Create(ref: Ref("indexes"),
                              params:Obj(["name": "posts_by_tags",
                                          "source": BlogPost.classRef,
                                          "terms": Arr(Obj(["field": Arr("data", "tags")])),
                                          "values": Arr()])),
                          Create(ref: Ref("indexes"),
                              params: Obj(["name": "posts_by_name",
                                           "source": BlogPost.classRef,
                                           "terms": Arr(Obj(["field": Arr("data", "name")])),
                                           "values": Arr()]))
                )
              , completion: callback)
          }
      }
  }
}

// Once we've set up fauna scheme we are able to create instances and perform queries among other things...

func createInstances(callback: (Result<Value, Error> -> ())) {
    client.query({
        let blogPosts = (1...100).map {
            BlogPost(name: "Blog Post \($0)", author: "FaunaDB",  content: "content", tags: $0 % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
        }
        return Map(collection: Arr(blogPosts)) { blogPost  in
             Create(ref: Ref("classes/posts"), params: Obj(["data": blogPost]))
        }
    }(), completion: callback)
}

// let's invoke these async functions to set up the scheme and create blog post instances.
setUpSchema(db_name) { result in
      guard let _ = try? result.dematerialize() else {
          // show error message or propagates it
          return
      }
      createInstances { createInstancesR in
          guard let _ = try? createInstancesR.dematerialize() else { return /* handle error */ }
          // blog post instances are now saved in FaunaDB
      }
}

```

#### Basic Usage (using RxSwift reactive extensions)

```swift

import Foundation
import Result
import FaunaDB
import RxFaunaDB

// create a fauna client
// Logger will shows in the Xcode console the curl representation of each message sent to FaunaDB, it also shows the fauna response data. This is useful during app development.


let secret = <YOUR_CLIENT_SECRET>
let dbName = <YOUR_DB_NAME>
var client = Client(secret: secret, observers: [Logger()])

let disposeBag = DisposeBag()

func rxSetUpSchema(dbName: String) -> Observable<Value> {

    //MARK: Rx schema set up
    return client.rx_query(Create(ref: Ref("databases"), params: Obj(["name": dbName])))
        .flatMap { _ in
            return client.rx_query(Create(ref: Ref("keys"), params: Obj(["database": Ref("databases/\(dbName)"), "role": "server"])))
        }
        .mapWithField("secret")
        .doOnNext { (secret: String) in
            client = Client(secret: secret, observers: [Logger()])
        }
        .flatMap { _ in
            return client.rx_query(Create(ref: Ref("classes"), params: Obj(["name": "posts"])))
        }
        .flatMap { _ in
            return client.rx_query(
                    Do(exprs: Create(ref: Ref("indexes"),
                                  params: Obj(["name": "posts_by_tags",
                                               "source": BlogPost.classRef,
                                               "terms": Arr(Obj(["field": Arr("data", "tags")])),
                                               "values": Arr()])),
                              Create(ref: Ref("indexes"),
                                  params: Obj(["name": "posts_by_name",
                                               "source": BlogPost.classRef,
                                               "terms": Arr(Obj(["field": Arr("data", "name")])),
                                               "values": Arr()]))
                    ))
        }
}

func rxCreateInstances() -> Observable<Value> {
    // let's create 100 blog posts using FaunaDB Map expression. Notice `BlogPost` type conforms to `ValueConvertible`.
    let blogPosts = (1...100).map {
        BlogPost(name: "Blog Post \($0)", author: "FaunaDB",  content: "content", tags: $0 % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
    }
    return client.rx_query(
                    Map(collection: Arr(blogPosts)) { blogPost  in
                        Create(ref: Ref("classes/posts"), params: Obj(["data": blogPost]))
                    })
}

// let's invoke these reactive functions to set up the scheme and create blog post instances.
rxSetUpSchema(db_name)
                .flatMap { _ in
                    rxCreateInstances()
                }
                .doOnError { error in
                  // do something with FaunaDB error }
                .subscribeNext { value in
                    // do something with FaunaDB response value
                }
                .addDisposableTo(disposeBag)

```

#### Fauna Client

All communication between your app and FaunaDB db should be done through a Fauna Client, a `Client` instance.

The simplest way to set up a client is by passing Fauna DB secret as a parameter.

```swift
let client = Client(secret: <YOUR_FAUA_DB_SECRET>)
```

> `Client` accepts other configurations such as endpoint, timeout and observers.

In order to make development process easier we can attach an observer to the client. We provide [Logger](Sources/ClientObserverType.swift) observer that shows the curl representation of every communication with Fauna DB and also displays the response data.

```swift
let client = Client(secret: <YOUR_FAUA_DB_SECRET>, observers: [Logger()]))
```

> Notice that we can add as many observers as we want since observers parameter type is an array of `ClientObserverType` protocol.

Once we have set up the client we can use it by just invoking its `query` method which has 2 parameters, the query expression and a callback that will be called right after the asynchronous operation finishes.

#### How to work directly with your app types

##### ValueConvertible Protocol

As you may have seen in the code snippets above we can use custom types directly in Swift Fauna Driver. To do so we provide `ValueConvertible` protocol which allows us to convert any custom type into a `Value`.
> Every FaunaDB value and expr type conforms to `ValueConvertible` protocol by default.

Let's see an example...

```swift
struct BlogPost {
    let name: String
    let author: String
    let content: String
    let tags: [String]

    // fauna db internal id
    let refId: Ref?

    init(name:String, author: String, content: String, tags: [String] = [], refId: Ref? = nil){
        self.name = name
        self.author = author
        self.content = content
        self.tags = tags
        self.refId = refId
    }
}

extension BlogPost: ValueConvertible {
    var value: Value {
        return Obj(["name": name, "author": author, "content": content, "tags": Arr(tags)])
    }
}
```

Now `BlogPost` instances can be used anywhere a Value is expected.
> Notice that swift fauna `Arr` and `Obj` collection types support `ValueConvertible` items.

A ValueConvertible usage example...

```swift
let blogPosts: [BlogPost] = ....
let createBlogPostsExpr = Map(collection: Arr(blogPosts)) { blogPost  in
                              Create(ref: Ref("classes/posts"), params: Obj(["data": blogPost]))
                          }
client.query(createBlogPostsExpr) { result in
  print(result)
}
```

##### DecodableValue Protocol (How to work with Fauna DB response data)

Typically we have to work with Fauna DB response data. This is the scenario, for example, when we need to compose and perform a nested query or we want to show/work with the response data.

Raw Fauna DB response data is a hierarchy tree of Values items. For more information about Value types check out the related [documentation](https://faunadb.com/documentation/queries#values).

Swift driver allows us to work seamlessly with fauna DB data. First and most importantly swift driver tries to use swift types representation as Fauna types whenever possible. This means that swift `Int`, `Double`, `String`, `Bool` are used as fauna `Integer`, `Decimal`, `String` and `Bool` respectively so we can  pass these types in and out when working with swift Fauna driver API. Secondly, we provide a build-in way to decode fauna db response into any custom type, here is where `DecodableValue` comes in handy...

Let's see some examples (continue taking BlogPost type as example)...

```swift

// Make BlogPost type conform to DecodableValue protocol.
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
```

Now we can decode any value instance into a `BlogPost` by ether using `Value`'s `get` method or `Field` type...

```swift
var items = [BlogPost]()
var cursor: Cursor? // will be useful to retrieve next page

//..
//.

client.query(predicateExpr) { [weak self] result in
    switch result {
    case .Failure(let error):
        // handle failure
    case .Success(let value):
        let data: [BlogPost] = try! value.get(path: "data")
        var cursorData: Arr? = value.get(path: "after")
        self?.cursor = cursorData.map { Cursor.After(expr: $0)}
        cursorData = value.get(path: "before")
        let beforeCursor = cursorData.map { Cursor.Before(expr: $0)}
        if let _ = beforeCursor {
            self?.items.appendContentsOf(data)
        }
        else {
            self?.items = data
        }
    }
}
```

Let's define a PaginationResult generic type to make this code cleaner.

```swift
struct PaginationResult<T: DecodableValue where T.DecodedType == T>: DecodableValue {
    let items: [T]
    let afterCursor: Cursor?
    let beforeCursor: Cursor?

    init(items: [T], afterCursor: Cursor? = nil, beforeCursor: Cursor? = nil){
        self.items = items
        self.afterCursor = afterCursor
        self.beforeCursor = beforeCursor
    }

    static func decode(value: Value) -> PaginationResult<T>? {
        let afterCursorData: Arr? = value.get(path: "after")
        let beforeCursorData: Arr? = value.get(path: "before")
        return try? self.init(      items: value.get(path: "data"),
                              afterCursor: afterCursorData.map { Cursor.After(expr: $0)},
                             beforeCursor: beforeCursorData.map { Cursor.Before(expr: $0)})
    }
}

//  now we will refactor the above code as ....

var items = [BlogPost]()
var lastPageRetrieved: PaginationResult<BlogPost>? // will be useful to retrieve next page

client.query(predicateExpr) { [weak self] result in
    switch result {
    case .Failure(let error):
        // handle failure
    case .Success(let value):
        let paginationData: PaginationResult<BlogPost> = try! value.get()
        lastPageRetrieved = paginationData
        if let _ = paginationData.beforeCursor {
            self?.items.appendContentsOf(paginationData.items)
        }
        else {
            self?.items = paginationData.items
        }
    }
}
```

> Notice that all Fauna DB value types conforms to DecodableValue.

### Example project

`FaunaDB.workspace` contains an Example app that shows the basics of how to use the driver and populates an iOS UITableView with fauna db data as well as paginate and filter fauna db data. It shows how to create a database, create classes, indexes, performs queries and handle queries results.

You can run the `Example` iOS app in the iPhone simulator by just cloning this repository, opening the `FaunaDB.workspace` using Xcode and then running `Example` app.

### Playground

FaunaDB workspace also contains a swift playground indented to show FaunaDB swift driver basic functionality, syntax and usage.
You can play with it to get familiar quickly with the FaunaDB swift driver API.

## Installation

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

To install FaunaDB, simply add the following line to your Cartfile:

```ogdl
github "faunadb/FaunaDB" ~> 1.0
```

then run `carthage `

Carthage will build your dependencies and provide you with binary frameworks.

#### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install FaunaDB, simply add the following line to your Podfile:

```ruby
pod 'FaunaDB', '~> 1.0'
```

#### Manually as Embedded Framework

* Clone FaunaDB as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command from your project root git folder.

```bash
$ git submodule add git@github.com:faunadb/faunadb-swift.git
```

* Open `faunadb-swift` folder that was created by the previous git submodule command and drag the FaunaDB.xcodeproj into the Project Navigator of your application's Xcode project.

* Select the FaunaDB.xcodeproj in the Project Navigator and verify the deployment target matches with your application deployment target.

* Select your project in the Xcode Navigation and then select your application target from the sidebar. Next select the "General" tab and click on the + button under the "Embedded Binaries" section.

* Select `FaunaDB.framework` and we are done!

Reactive Extension installation

### Dependencies

#### FaunaDB

* [Foundation](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/ObjC_classic/) framework.
* [Result](https://github.com/antitypical/Result).

#### RxFaunaDB (Reactive programming extensions)

* FaunaDB.
* [RxSwift](https://github.com/ReactiveX/RxSwift).


## Getting involved

Any contribution is very welcomed!! 💪  

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues before submitting an issue**.

Before contribute check the [CONTRIBUTING](https://github.com/faunadb/faunadb-swift/blob/master/CONTRIBUTING.md) file for more info.

If you use **FaunaDB** in your app We would love to hear about it! Drop us a line on [twitter](https://twitter.com/faunadb).


## Author

* [Fauna, Inc](https://github.com/faunadb) ([@faunadb](https://twitter.com/faunadb))

## License

All projects in this repository are licensed under the [Mozilla Public License](https://github.com/faunadb/faunadb-swift/blob/master/LICENSE).

## Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
