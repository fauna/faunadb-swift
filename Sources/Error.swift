//
//  ClientError.swift
//  FaunaDB
//
//  Created by Martin Barreto on 5/31/16.
//
//

import Foundation

public enum Error: ErrorType {
    case UnavailableException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case BadRequestException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case NotFoundException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case UnauthorizedException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case UnknownException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case InternalException(response: NSURLResponse?, errors:[ErrorResponse], msg: String?)
    case NetworkException(response: NSURLResponse?, error: NSError?, msg: String?)
    case DecodeException(data: AnyObject)
}


extension Error: CustomDebugStringConvertible, CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .UnavailableException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .BadRequestException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .NotFoundException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .UnauthorizedException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .UnknownException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .InternalException(let response, let errors, let msg):
            return getDesc(response, errors: errors, msg: msg)
        case .NetworkException(let response, let error, let msg):
            return getDesc(response, errors: [], msg: msg, error: error)
        case .DecodeException(let data):
            return "Cannot decode json object: \(data)"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
    private func getDesc(response: NSURLResponse?, errors: [ErrorResponse], msg: String?, error: NSError? = nil) -> String{
        var result = [String]()
        _ = response.map { result.append("Response: " + $0.description) }
        _ = msg.map { result.append("Message: \($0)") }
        if errors.count > 0 {
            result.append("Errors:")
            errors.forEach { result.append( $0.description ) }
        }
        _ = error.map { result.append("Error: \($0.description)") }
        return result.joinWithSeparator("\n")
    }
}


public struct ErrorResponse {
    let code: String
    let desc: String
    let position: [String]?
    
    
    public init?(json: [String: AnyObject]){
        self.code = json["code"] as! String
        self.desc = json["description"] as! String
        self.position = json["position"] as? [String]
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

