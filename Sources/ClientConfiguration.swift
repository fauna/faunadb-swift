//
//  ClientConfiguration.swift
//  FaunaDB
//
//  Created by Martin Barreto on 5/31/16.
//
//

import Foundation

public struct ClientConfiguration {
    public var timeoutIntervalForRequest: NSTimeInterval = 60
    public var faunaRoot: NSURL = NSURL(string: "https://rest.faunadb.com:403")!
    public var secret: String
    
    
    public init(secret:String, faunaRoot: NSURL = NSURL(string: "https://rest.faunadb.com")!, timeoutIntervalForRequest: NSTimeInterval = 60) { //NSURL(string: "https://rest.faunadb.com:403")!
        self.secret = secret
        self.faunaRoot = faunaRoot
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
    }
}
