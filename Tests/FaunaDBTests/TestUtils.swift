import Foundation

@testable import FaunaDB

internal func env(_ name: String) -> String? {
    guard
        let variable = ProcessInfo.processInfo.environment[name],
        !variable.isEmpty
        else { return nil }

    return variable
}

internal extension String {

    static func random(startingWith prefix: String = "", size: Int = 10) -> String {
        var res = prefix

        for _ in 1...size {
            // must avoid zero because Ref("classes/any/0123")
            // becomes Ref("classes/any/123") once it goes to the server
            let random = (arc4random() % 9) + 1
            res.append("\(random)")
        }

        return res
    }

}

internal extension QueryResult {

    @discardableResult
    func await() throws -> T {
        #if DEBUG
            return try await(timeout: .distantFuture)
        #else
            return try await(timeout: .now() + .seconds(10))
        #endif
    }
    
}

internal extension JSON {

    static func stringify(expr: Any) -> String {
        return String(data: try! data(value: expr), encoding: .utf8)!
    }

    static func parse(string: String) throws -> Value {
        return try parse(data: string.data(using: .utf8)!)
    }

}
