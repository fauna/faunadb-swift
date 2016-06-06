//
//  ClientError.swift
//  FaunaDB
//
//  Created by Martin Barreto on 5/31/16.
//
//

import Foundation

public enum Error: ErrorType {
    case UnavailableException(response: NSURLResponse?, msg: String?)
    case BadRequestException(response: NSURLResponse?, msg: String?)
    case NotFoundException(response: NSURLResponse?, msg: String)
    case UnauthorizedException(response: NSURLResponse?, msg: String)
    case UnknownException(response: NSURLResponse?, msg: String?)
    case NetworkingException(response: NSURLResponse?, msg: String?, error: NSError?)
    case InternalException(response: NSURLResponse?, msg: String?)
}