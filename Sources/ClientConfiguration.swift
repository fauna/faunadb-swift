//
//  ClientConfiguration.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public struct ClientConfiguration {
    public var timeoutIntervalForRequest: NSTimeInterval = 60
    public var faunaRoot: NSURL = NSURL(string: "https://rest.faunadb.com:403")!
    public var secret: String
    
    
    public init(secret:String, faunaRoot: NSURL = NSURL(string: "https://rest.faunadb.com")!, timeoutIntervalForRequest: NSTimeInterval = 60) {
        self.secret = secret
        self.faunaRoot = faunaRoot
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
    }
}
