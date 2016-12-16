# FaunaDB Driver Example Project

This is a simple CRUD-style application that shows how to use the Swift driver
in an iOS project.

## Requirements

- [CocoaPods](https://cocoapods.org/)

## Running the example

- Run `pod install` to setup the project
- Using XCode 8+, open the workspace `Example.xcworkspace`
- Edit (or duplicate) the scheme "Example", and set your
  [FaunaDB key's secret](https://fauna.com/documentation#authentication) in the
  environment variable `FAUNA_ROOT_KEY`

## Implementation

This demo is a simple blog post manager. It has a basic model called `Post`
instances of which must have a title and may optionally have a body.

Most of the interaction with FaunaDB is located at
[Posts.swift](https://github.com/faunadb/faunadb-swift/blob/master/Example/Example/Post.swift)
file. It contains the base model `Post` as well as the code needed to store,
update, delete, and show posts saved at FaunaDB.

[Database.swift](https://github.com/faunadb/faunadb-swift/blob/master/Example/Example/Database.swift)
contains the database setup for this demo. In a real life application, that code
would live somewhere else, such as a separated provisioning script. For the
purpose of this example it is easier to let the application setup the database
on launch.

The rest of the files are UI related code to present the views that are used to
create, update, delete, and show the blog posts.

## Demo

![](https://github.com/faunadb/faunadb-swift/blob/readme-example/Example/demo.gif)
