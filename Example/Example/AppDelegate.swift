import UIKit
import FaunaDB

var faunaClient: FaunaDB.Client!

fileprivate let secret: String = {
    guard let key = environmentVariable("FAUNA_ROOT_KEY") else {
        fatalError(
            "Environment variable FAUNA_ROOT_KEY not defined. " +
            "Check your scheme run configuration. " +
            "Tip: You can also set FAUNA_ENDPOINT if you want to run " +
            "this example app against a different Fauna instance. Fauna Cloud is used by default."
        )
    }
    return key
}()

fileprivate let endpoint = environmentVariable("FAUNA_ENDPOINT")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        do {
            // In general, await should be avoided in production code.
            // `map` and `flatMap` are preferable.
            faunaClient = try
                setupDatabase(rootKey: secret, endpoint: endpoint)
                .await(timeout: .now() + 5)
        } catch let error {
            fatalError("Error while setting up the database: \(error)")
        }
    }
}

fileprivate func environmentVariable(_ name: String) -> String? {
    return ProcessInfo
        .processInfo
        .environment[name]?
        .trim()
}
