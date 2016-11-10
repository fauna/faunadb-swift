//
//  Error.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public enum FaunaError: Error {
    case unavailableException(response: URLResponse?, errors:[ErrorResponse])
    case badRequestException(response: URLResponse?, errors:[ErrorResponse])
    case notFoundException(response: URLResponse?, errors:[ErrorResponse])
    case unauthorizedException(response: URLResponse?, errors:[ErrorResponse])
    case unknownException(response: URLResponse?, errors:[ErrorResponse], msg: String?)
    case internalException(response: URLResponse?, errors:[ErrorResponse], msg: String?)
    case networkException(response: URLResponse?, error: NSError?, msg: String?)
    case driverException(data: Any?, msg: String?)
    case unparsedDataException(data: AnyObject, msg: String?)
}


extension FaunaError: CustomDebugStringConvertible, CustomStringConvertible {

    public var description: String {
        switch self {
        case .unavailableException(let response, let errors):
            return getDesc(response, errors: errors)
        case .badRequestException(let response, let errors):
            return getDesc(response, errors: errors)
        case .notFoundException(let response, let errors):
            return getDesc(response, errors: errors)
        case .unauthorizedException(let response, let errors):
            return getDesc(response, errors: errors)
        case .unknownException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .internalException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .networkException(let response, let error, let msg):
            return getDesc(response, msg: msg, error: error)
        case .driverException(_, let msg):
            return getDesc(nil, msg: msg)
        case .unparsedDataException(let data, let msg):
            return getDesc(nil, msg: msg.map { "\($0): /n\(data)" } ?? "\(data)", error: nil)
        }

    }

    public var debugDescription: String {
        return description
    }

    fileprivate func getDesc(_ response: URLResponse?, errors: [ErrorResponse] = [], msg: String? = nil, error: NSError? = nil) -> String{
        var result = [String]()
        _ = msg.map { result.append("Error: \($0)") }
        _ = response.map { result.append("Response: " + $0.description) }
        if !errors.isEmpty {
            result.append("Errors:")
            errors.forEach { result.append( $0.description ) }
        }
        _ = error.map { result.append("Error: \($0.description)") }
        return result.joined(separator: "\n")
    }

    public var responseErrors: [ErrorResponse]{
        switch self {
        case .unavailableException(_, let errors):
            return errors
        case .badRequestException(_, let errors):
            return errors
        case .notFoundException(_, let errors):
            return errors
        case .unauthorizedException(_, let errors):
            return errors
        case .unknownException(_, let errors, _):
            return errors
        case .internalException(_, let errors, _):
            return errors
        default: return []
        }
    }
}


public struct ErrorFailure {
    let field: [String]
    let desc: String
    let code: String

    init(json: [String: AnyObject]){
        self.code = json["code"] as! String
        self.desc = json["description"] as! String
        self.field = json["field"] as? [String] ?? []
    }
}

public struct ErrorResponse {
    let code: String
    let desc: String
    let position: [String]?
    let failures: [ErrorFailure]


    public init?(json: [String: AnyObject]){
        self.code = json["code"] as! String
        self.desc = json["description"] as! String
        self.position = json["position"] as? [String]
        let failuresArr = json["failures"] as? NSArray ?? []
        self.failures = failuresArr
            .flatMap { $0 as? [String : AnyObject] }
            .map { ErrorFailure(json: $0) }
    }
}

extension ErrorResponse: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return "ErrorResponse - Code: \(code) - description: \(desc)"
    }

    public var debugDescription: String {
        return description
    }
}
