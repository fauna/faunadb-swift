// swift-tools-version:4.2.0
import PackageDescription

let package = Package(
   name: "FaunaDB",
   products: [
     .library(name: "FaunaDB", targets: ["FaunaDB"])
   ],
   targets: [
     .target(
        name: "FaunaDB",
        dependencies: []
     ),
     .testTarget(
         name: "FaunaDBTests",
         dependencies: ["FaunaDB"]
     )
   ]
)

