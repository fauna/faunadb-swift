//
//  Client.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
import Result

public final class Client {
    
    private enum ClientHeaders: String {
        case PrettyPrintJSONResponses = "X-FaunaDB-Formatted-JSON" // true
        case Authorization = "Authorization"
    }
    var session: NSURLSession
    var delegate: ClientDelegate
    var faunaRoot: NSURL
    var secret: String
    var authHeader: String
    public var observers = [ClientObserverType]()
    
    public init (configuration: ClientConfiguration){
        faunaRoot = configuration.faunaRoot
        secret = configuration.secret
        authHeader = Client.authHeaderValue(secret)
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutIntervalForRequest
        var headers = sessionConfig.HTTPAdditionalHeaders ?? [NSObject: AnyObject]()
        headers[ClientHeaders.Authorization.rawValue] = authHeader
        headers[ClientHeaders.PrettyPrintJSONResponses.rawValue] = false
        sessionConfig.HTTPAdditionalHeaders = headers
        delegate = ClientDelegate()
        session =  NSURLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: NSOperationQueue.mainQueue())
    }

}


extension Client {
    
    
    
    public func query(expr: ExprType, completionHandler: (Result<ValueType, FaunaDB.Error> -> Void)? = nil)  {
        let json = expr.toAnyObjectJSON()
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(json!, options: .PrettyPrinted)
        postJSON(jsonData) { (data, response, error) in
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
            print(jsonString)
        }
    }
    
    func query(expression: (()-> ExprType), completionHandler: (Result<ValueType, FaunaDB.Error> -> Void)? = nil) {
        query(expression(), completionHandler: completionHandler)
    }
    
}

extension Client {
    
    private func postJSON(data: NSData, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)){
        let request = NSMutableURLRequest(URL: faunaRoot)
        request.HTTPBody = data
        request.HTTPMethod = "POST"
        var headers = request.allHTTPHeaderFields ?? [String: String]()
        headers["Content-Type"] = "application/json; charset=utf-8"
        request.allHTTPHeaderFields = headers
        performRequest(request, completionHandler: completionHandler);
    }
    
    private func performRequest(request: NSURLRequest, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)){
        
        let dataTask = session.dataTaskWithRequest(request) { [weak self] data, response, error  in
            self?.observers.forEach { $0.didReceiveResponse(response, data: data, error: error, request: request) }
            completionHandler(data, response, error)
        }
        observers.forEach { $0.willSendRequest(dataTask.currentRequest ?? dataTask.originalRequest ?? request, session: session) }
        dataTask.resume()
    }
    
}


extension Client {
    
    private static func authHeaderValue(token: String) -> String {
        return "Basic " + "\(token):".dataUsingEncoding(NSASCIIStringEncoding)!.base64EncodedStringWithOptions([]) //  NSUTF8StringEncoding
    }
}



internal class ClientDelegate: NSObject, NSURLSessionDataDelegate {
    
}
