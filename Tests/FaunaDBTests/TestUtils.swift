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
            res.append("\(Int(arc4random()) % 10)")
        }

        return res
    }

}

internal extension QueryResult {

    @discardableResult
    func await() throws -> T {
        #if DEBUG
            return try await(timeout: DispatchTime.now() + 120)
        #else
            return try await(timeout: DispatchTime.now() + 5)
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
