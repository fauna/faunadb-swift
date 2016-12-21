# WIP

***Please, note that this driver is being developed. Changes will happen until we have an official release.***

# FaunaDB Swift Driver

[![Build Status](https://travis-ci.org/faunadb/faunadb-swift.svg?branch=master)](https://travis-ci.org/faunadb/faunadb-swift)
[![Coverage Status](https://codecov.io/gh/faunadb/faunadb-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/faunadb/faunadb-swift)
[![License](https://img.shields.io/badge/license-MPL_2.0-blue.svg?maxAge=2592000)](https://raw.githubusercontent.com/faunadb/faunadb-swift/master/LICENSE)

A Swift driver for [FaunaDB](https://fauna.com)

## Supported Platforms

* iOS 9.0+ | OSX 10.10+ | tvOS 9.0+ | watchOS 2.0+
* Xcode 8
* Swift 3

## Documentation

Check out the Swift-specific [reference documentation](http://faunadb.github.io/faunadb-swift/).

You can find more information in the FaunaDB [documentation](https://fauna.com/documentation)
and in our [example project](https://github.com/faunadb/faunadb-swift/tree/master/Example).

## Using the Driver

### Installing

CocoaPods:

```
pod 'FaunaDB', '~> 1.0'
```

Carthage:

```
github 'faunadb/faunadb-swift'
```

SwiftPM:

```swift
.Package(
    url: "https://github.com/faunadb/faunadb-swift.git",
    majorVersion: 1,
    minorVersion: 0
)
```

### Basic Usage

```swift
import FaunaDB

struct Post {
    let title: String
    let body: String?
}

extension Post: FaunaDB.Encodable {
    func encode() -> Expr {
        return Obj(
            "title" => title,
            "body" => body
        )
    }
}

extension Post: FaunaDB.Decodable {
    init?(value: Value) throws {
        try self.init(
            title: value.get("title") ?? "Untitled",
            body: value.get("body")
        )
    }
}

let client = FaunaDB.Client(secret: "your-key-secret-here")

// Creating a new post
try! client.query(
    Create(
        at: Class("posts")
        Obj("data" => Post("My swift app", nil))
    )
).await(timeout: .now() + 5)

// Retrieve a saved post
let getPost = client.query(Get(Ref(class: Class("posts"), id: "42")))
let post: Post = try! getPost.map { dbEntry in dbEntry.get("data") }
    .await(timeout: .now() + 5)
```

For more examples, check our online [documentation](https://fauna.com/documentation)
and our [example project](https://github.com/faunadb/faunadb-swift/tree/master/Example).

## Contributing

GitHub pull requests are very welcome.

### Driver Development

You can compile and run the test with the following command:

```
FAUNA_ROOT_KEY=your-keys-secret-here swift test
```

## LICENSE

Copyright 2016 [Fauna, Inc.](https://fauna.com/)

Licensed under the Mozilla Public License, Version 2.0 (the
"License"); you may not use this software except in compliance with
the License. You may obtain a copy of the License at

[http://mozilla.org/MPL/2.0/](http://mozilla.org/MPL/2.0/)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
