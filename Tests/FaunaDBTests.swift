import XCTest
import FaunaDB

fileprivate class Config {

    private static let configFile: [String: String] = {
        guard
            let testConfig = Bundle(for: Config.self).path(forResource: "TestConfig", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: testConfig)
            else { return [:] }

        var res = [String: String]()

        config.forEach { key, value in
            guard
                let key = key as? String,
                let value = value as? String
                else { return }

            res[key] = value
        }

        return res
    }()

    private static let envVariables: [String: String] = ProcessInfo.processInfo.environment

    static func get(_ config: String) -> String? {
        if let fromEnvVariable = envVariables[config] {
            return fromEnvVariable
        }

        return configFile[config]
    }
}

extension QueryResult {

    @discardableResult
    func await() throws -> T {
        #if DEBUG
            return try await(timeout: DispatchTime.now() + 120)
        #else
            return try await(timeout: DispatchTime.now() + 5)
        #endif
    }

}

class FaunaDBTests: XCTestCase {

    private static let dbName = "faunadb-swift-test-\(arc4random())"
    private static let secret = Config.get("FAUNA_ROOT_KEY")
    private static let endpoint = Config.get("FAUNA_ENDPOINT")

    static var adminClient: Client = {
        guard let secret = secret else {
            fatalError("No secret found to run tests. Check you environment configuration.")
        }

        guard let endpoint = endpoint else { return Client(secret: secret) }
        return Client(secret: secret, endpoint: URL(string: endpoint)!)
    }()

    static var client: Client = {
        return try!
            adminClient.query(
                CreateDatabase(Obj("name" => dbName))
            )
            .flatMap {
                adminClient.query(
                    CreateKey(Obj(
                        "database" => try $0.get("ref"),
                        "role" => "server"
                    ))
                )
            }
            .map {
                adminClient.newSessionClient(
                    secret: try $0.get("secret")!
                )
            }
            .await()
    }()

    var client: Client {
        return FaunaDBTests.client
    }

    override class func tearDown() {
        super.tearDown()
        try! adminClient
            .query(Delete(ref: Database(dbName)))
            .await()
    }

}
