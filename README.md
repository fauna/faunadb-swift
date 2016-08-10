# FaunaDB Swift Client

<p align="left">
<a href="https://travis-ci.org/faunadb/faunadb-swift"><img src="https://travis-ci.org/faunadb/faunadb-swift.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS | OSX |tvOS | watchOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/faunadb-swift"><img src="https://img.shields.io/badge/pod-1.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/faunadb/faunadb-swift/master/LICENSE"><img src="http://img.shields.io/badge/license-Mozilla Public License 2.0-blue.svg?style=flat" alt="License: Mozilla Public License 2.0" /></a>
</p>

By [Fauna, Inc](http://faunadb.com).

## WIP

***Please, note that this driver is being developed. Changes will happen until we have an official release.***

[FaunaDB](https://faunadb.com/) driver for Swift language.

## Requirements

* iOS 8.4+ | OSX 10.9+ | tvOS 9.2+ | watchOS 2.2+
* Xcode 7.3.1+
* Swift 2.2

## Getting started

1. If you haven’t already, [sign up for an account](https://faunadb.com/#signup-modal) to start using FaunaDB.

2. Driver installation. The Swift FaunaDB Driver is distributed via [Carthage](https://github.com/Carthage/Carthage) and [CocoaPods](https://cocoapods.org/). Go to [Installation](#installation) section for further details.

3. From here, FaunaDB [tutorials](https://faunadb.com/tutorials) provide a task-oriented introduction to the features of FaunaDB to get you up and running quickly.

## Basic Usage

Once you have installed the driver you should import the FaunaDB framework and its dependencies.

```swift
import Foundation
import Result
import FaunaDB
```

Then we should instantiate a FaunaDB client,  a `Client` instance, which allows us to communicate with FaunaDB.

The simplest way to set up a client is by passing FaunaDB secret as a parameter. It also accepts other configurations such as endpoint, timeout and observers.

```swift
let client = Client(secret: <YOUR_FAUNA_DB_SECRET>)
```

Now we are able to perform queries by using any FaunaDB language query expression.

For example, let's create user class:

```swift
client.query(Create(ref: Ref("classes"),
                 params: Obj(["name": "users"]))) { createClassR in
  // handle FaunaDB response
}
```

And create an user instance.

```swift
client.query(Create(ref: Ref("classes/users"),
                 params: Obj(["email": "swift@example.com"]))) { [weak self] result in
  guard let createR = try? result.dematerialize() else {
      // something went wrong
      return
  }
  // let's update the recently created user instance
  self?.client.query(Update(ref: try! createR.get(field: Field<Ref>("ref")),
                         params: Obj(["data": Obj(["data": Obj(["name": "Martin",
                                                         "profession": "dev"])])]))) { resultUpdate in
  }
}
```

now let's see how to paginate over user instances:

```swift
let match_1 = Match(index: Ref("indexes/users_by_profession"), terms: "dev")
let match_2 = Match(index: Ref("indexes/users_by_profession"), terms: "dentist")
let union = Union(sets: match_1, match_2)
client.query(Paginate(resource: union)) { paginationR in
  switch paginationR {
  case .Failure(let error):
      // handle error
  case .Success(let value):
      // print all users name
      let data: Arr = try! value.get("data")
      for userData in data {
        let name: String? = userData.get("name")
        print(name ?? "User without name")
      }
  }
}
```

#### Client Logger

In order to make development process easier we can attach an observer to the client. We provide [Logger](Sources/ClientObserverType.swift) observer that shows the curl representation of every communication with FaunaDB and also displays the response data.

```swift
let client = Client(secret: <YOUR_FAUNA_DB_SECRET>, observers: [Logger()]))
```

Notice that we can add as many observers as we want since observers parameter type is an array of `ClientObserverType` protocol.

It's not recommended to use `Logger` observer in released apps. We can turn it off in production code by using preprocessor macros as shown below.

```swift
#if DEBUG
let client = Client(secret: <YOUR_FAUNA_DB_SECRET>, observers: [Logger()]))
#else
let client = Client(secret: <YOUR_FAUNA_DB_SECRET>)
#endif
```

### Example project

`FaunaDB.workspace` contains an iOS Example app that shows the basics of how to use the driver and populates an UITableView with FaunaDB data as well as paginate and filter it. It shows how to create a database, create classes, indexes, perform queries and handle queries results.

You can run the `Example` iOS app in the iPhone simulator by following these steps:

1. Clone this repository.
2. Run `carthage update` from the repository root folder.
3. Open `FaunaDB.xcworkspace`.
4. Set up your FaunaDB admin key [here](https://github.com/faunadb/faunadb-swift/blob/master/Example/Example/Helpers/Helpers.swift#L13).
5. Run Example app using Xcode.


### Playground

FaunaDB workspace also contains a swift playground indented to show FaunaDB swift driver basic functionality, syntax and usage.
You can play with it to get familiar quickly with the FaunaDB swift driver API.

## Installation

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

To install FaunaDB, simply add the following line to your Cartfile:

```ogdl
github "faunadb/faunadb-swift" ~> 1.0
```

then run `carthage update`

Carthage will build your dependencies and provide you with binary frameworks.

For additional details take a look at carthage [documentation](https://github.com/Carthage/Carthage#adding-frameworks-to-an- welication).

**You must link `FaunaDB` as well as `Result` framework into your app project.**

#### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install FaunaDB, simply add the following line to your Podfile:

```ruby
pod 'FaunaDB', '~> 1.0'
```

### Dependencies

* [Foundation](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/ObjC_classic/) framework.
* [Result](https://github.com/antitypical/Result).

## Getting involved

Any contribution is very welcomed!! 💪  

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues before submitting an issue**.

Before contribute check the [CONTRIBUTING](https://github.com/faunadb/faunadb-swift/blob/master/CONTRIBUTING.md) file for more info.

If you use **FaunaDB** in your app, we would love to hear about it! Drop us a line on [twitter](https://twitter.com/faunadb).


## Author

* [Fauna, Inc](https://github.com/faunadb) ([@faunadb](https://twitter.com/faunadb))

## License

All projects in this repository are licensed under the [Mozilla Public License](https://github.com/faunadb/faunadb-swift/blob/master/LICENSE).

## Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
