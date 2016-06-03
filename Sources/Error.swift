//
//  ClientError.swift
//  FaunaDB
//
//  Created by Martin Barreto on 5/31/16.
//
//

import Foundation

public enum Error: ErrorType {
    case UnavailableException(response: NSHTTPURLResponse?, msg: String?)
    case BadRequestException(response: NSHTTPURLResponse?, msg: String?)
    case NotFoundException(response: NSHTTPURLResponse?, msg: String)
    case UnauthorizedException(response: NSHTTPURLResponse?, msg: String)
    case UnknownException(response: NSHTTPURLResponse?, msg: String)
}