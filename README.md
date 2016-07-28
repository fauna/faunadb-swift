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


This repository contains FaunaDB driver for Swift language. Basically it provides high level abstractions that allows us to work with fauna DB efficiently and without the need to deal with rest messages, networking errors, data encoding, decoding and so on.

Apart of the FaunaDB driver, we also provide reactive programming extensions for [RxSwift](https://github.com/ReactiveX/RxSwift).

> working on another language? Take a look at our github account, we provide Fauna DB drivers for many popular languages and many others are coming. Don't hesitate to contact us if the language you are working on is not supported yet. Notice you can always use the [REST API](https://faunadb.com/documentation/rest) directly.

## About Fauna BD

FaunaDB is a state of the art db system that aims to be as reliable, secure and fast as possible. For more information about Fauna, please visit our [website](https://faunadb.com/). If you are curious about Fauna DB design and architecture, please check out [Design and Architecture of FaunaDB](https://faunadb.com/pdf/Design%20and%20Architecture%20of%20FaunaDB%2020160701.pdf) whitepaper.

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
import FaunaDB

// create a fauna client
// Logger will shows in the Xcode console the curl representation of each message sent to FaunaDB, it also shows the fauna response data. This is useful during app development.

let secret = <YOUR_CLIENT_SECRET>
let dbName = <YOUR_DB_NAME>
let client = Client(secret: secret, observers: [Logger()])

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
              client.query({
                  return Do(exprs:
                                  Create(ref: Ref("indexes"), params:Obj(["name": "posts_by_tags",
                                                                          "source": BlogPost.classRef,
                                                                          "terms": Arr(Obj(["field": Arr("data", "tags")])),
                                                                          "values": Arr()])),
                                  Create(ref: Ref("indexes"), params: Obj(["name": "posts_by_name",
                                                                           "source": BlogPost.classRef,
                                                                           "terms": Arr(Obj(["field": Arr("data", "name")])),
                                                                           "values": Arr()]))
                         )
              }()) {  createIndexR in
                  callback(createIndexR)
              }
          }
      }
  }
}

// Once we've' set up fauna scheme we are able to create instances and perform queries among other things...

func createInstances(callback: (Result<Value, Error> -> ())) {
    faunaClient.query({
        let blogPosts = (1...100).map {
            BlogPost(name: "Blog Post \($0)", author: "FaunaDB",  content: "content", tags: $0 % 2 == 0 ? ["philosophy", "travel"] : ["travel"])
        }
        return Map(collection: Arr(blogPosts)) { blogPost  in
             Create(ref: Ref("classes/posts"), params: Obj(["data": blogPost]))
        }
    }()) { result in
        callback(result)
    }
}

// let's invoke these async functions to set up the scheme and then create instances
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
* If you **found a bug** or **need help** please **check older issues before submitting an issue.**.

Before contribute check the [CONTRIBUTING](https://github.com/faunadb/faunadb-swift/blob/master/CONTRIBUTING.md) file for more info.

If you use **FaunaDB** in your app We would love to hear about it! Drop us a line on [twitter](https://twitter.com/faunadb).


## Author

* [Fauna, Inc](https://github.com/faunadb) ([@faunadb](https://twitter.com/faunadb))

## License

All projects in this repository are licensed under the [Mozilla Public License](https://github.com/faunadb/faunadb-swift/blob/master/LICENSE).

## Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
