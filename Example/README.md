# FaunaDB Driver Example Project

This is a simple CRUD project we made in order to show how to use the Swift
driver along with a iOS project.

## Requirements

- [CocoaPods](https://cocoapods.org/)

## Running the example

- Run `pod install` to setup the project
- Using XCode 8+, open the workspace `Example.xcworkspace`
- Edit (or duplicate) the scheme "Example" setting your key's secret at the
  environment variable "FAUNA_ROOT_KEY"

## Implementation

This demo is a simple blog post manager. It has a basic model called `Post` that
must have a title and optionally have a body.

Most of Fauna's related code is located at [Posts.swift](https://github.com/faunadb/faunadb-swift/blob/master/Example/Example/Post.swift)
file. It contains our base model `Post` as well as the code needed to save,
update, delete, and show posts saved at FaunaDB.

There is a file called [Database.swift](https://github.com/faunadb/faunadb-swift/blob/master/Example/Example/Database.swift)
in which we added the database setup for this demo. In a real life application,
that code would live somewhere else (like in a provision script) but, for the
purpose of this example we thought it would be easier to just let application
setup the database for you once you launch the demo.

The rest of the files are UI related code to present the views that we use to
create, update, delete, and show the blog posts.

## Demo

![](https://github.com/faunadb/faunadb-swift/blob/readme-example/Example/demo.gif)
