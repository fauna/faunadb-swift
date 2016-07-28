//
//  Error.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public enum Error: ErrorType {
    case UnavailableException(response: NSURLResponse?, errors:[ErrorResponse])
    case BadRequestException(response: NSURLResponse?, errors:[ErrorResponse])
    case NotFoundException(response: NSURLResponse?, errors:[ErrorResponse])
    case UnauthorizedException(response: NSURLResponse?, errors:[ErrorResponse])
    case UnknownException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case InternalException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case NetworkException(response: NSURLResponse?, error: NSError?, msg: String?)
    case DriverException(data: Any?, msg: String?)
    case UnparsedDataException(data: AnyObject, msg: String?)
}


extension Error: CustomDebugStringConvertible, CustomStringConvertible {

    public var description: String {
        switch self {
        case .UnavailableException(let response, let errors):
            return getDesc(response, errors: errors)
        case .BadRequestException(let response, let errors):
            return getDesc(response, errors: errors)
        case .NotFoundException(let response, let errors):
            return getDesc(response, errors: errors)
        case .UnauthorizedException(let response, let errors):
            return getDesc(response, errors: errors)
        case .UnknownException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .InternalException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .NetworkException(let response, let error, let msg):
            return getDesc(response, msg: msg, error: error)
        case .DriverException(_, let msg):
            return getDesc(nil, msg: msg)
        case .UnparsedDataException(let data, let msg):
            return getDesc(nil, msg: msg.map { "\($0): /n\(data)" } ?? "\(data)", error: nil)
        }

    }

    public var debugDescription: String {
        return description
    }

    private func getDesc(response: NSURLResponse?, errors: [ErrorResponse] = [], msg: String? = nil, error: NSError? = nil) -> String{
        var result = [String]()
        _ = msg.map { result.append("Error: \($0)") }
        _ = response.map { result.append("Response: " + $0.description) }
        if errors.count > 0 {
            result.append("Errors:")
            errors.forEach { result.append( $0.description ) }
        }
        _ = error.map { result.append("Error: \($0.description)") }
        return result.joinWithSeparator("\n")
    }

    public var responseErrors: [ErrorResponse]{
        switch self {
        case .UnavailableException(_, let errors):
            return errors
        case .BadRequestException(_, let errors):
            return errors
        case .NotFoundException(_, let errors):
            return errors
        case .UnauthorizedException(_, let errors):
            return errors
        case .UnknownException(_, let errors, _):
            return errors
        case .InternalException(_, let errors, _):
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
        var failures = [ErrorFailure]()
        for obj in failuresArr{
            if let obj = obj as? [String : AnyObject]{
                failures.append(ErrorFailure(json: obj))
            }
        }
        self.failures = failures
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
