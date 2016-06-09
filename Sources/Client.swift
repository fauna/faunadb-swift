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
        headers[ClientHeaders.PrettyPrintJSONResponses.rawValue] = true
        sessionConfig.HTTPAdditionalHeaders = headers
        delegate = ClientDelegate()
        session =  NSURLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: .mainQueue())
    }

}


extension Client {
    
    public func query(expr: ExprType, completionHandler: (Result<ValueType, FaunaDB.Error> -> Void)? = nil)  {
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(expr.toAnyObjectJSON()!, options: [])
        postJSON(jsonData) { [weak self] (data, response, error) in
            do {
                guard let mySelf = self else { return }
                try mySelf.handleNetworkingErrors(response, error: error)
                let jsonData =  try mySelf.handleQueryErrors(response, data: data)
                let result = mySelf.valueTypeForObject(jsonData!)
                completionHandler?(Result.Success(result))
            }
            catch {
                guard let faunaError = error as? FaunaDB.Error else {
                    completionHandler?(.Failure(FaunaDB.Error.UnknownException(response: response, errors: [], msg: (error as NSError).description)))
                    return
                }
                completionHandler?(.Failure(faunaError))
            }
        }
    }
    
    public func query(expression: (()-> ExprType), completionHandler: (Result<ValueType, FaunaDB.Error> -> Void)? = nil) {
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
    
    
    func handleNetworkingErrors(response: NSURLResponse?, error: NSError?) throws {
        guard let error = error else { return }
        throw FaunaDB.Error.NetworkingException(response: response, error: error, msg: error.description)
    }
    
    func handleQueryErrors(response: NSURLResponse?, data: NSData?) throws -> AnyObject? {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            throw FaunaDB.Error.NetworkingException(response: response, error: nil, msg: "Cannot cast NSURLResponse to NSHTTPURLResponse")
        }
        
        if httpResponse.statusCode >= 300 {
            do {
                let jsonData: [AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [AnyObject]
                let errors = jsonData.map { $0 as! [String: AnyObject] }.map { ErrorResponse(json: $0)! }
                switch httpResponse.statusCode {
                case 400:
                    throw Error.BadRequestException(response: response, errors: errors, msg: nil)
                case 401:
                    throw Error.UnauthorizedException(response: response, errors: errors, msg: nil)
                case 404:
                    throw Error.NotFoundException(response: response, errors: errors, msg: nil)
                case 500:
                    throw Error.InternalException(response: response, errors: errors, msg: nil)
                case 503:
                    throw Error.UnavailableException(response: response, errors: errors, msg: nil)
                default:
                    throw Error.UnknownException(response: response, errors: errors, msg: nil)
                }
            }
            catch {
                if httpResponse.statusCode == 503 {
                    throw Error.UnknownException(response: response, errors: [], msg: "Service Unavailable: Unparseable response.")
                }
                throw Error.UnknownException(response: response, errors: [], msg: "Unparsable service \(httpResponse.statusCode) response.")
            }
        }
        if let data = data {
            let jsonData: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return jsonData.objectForKey("resource")
        }
        return nil
    }
}


extension Client {
    
    private static func authHeaderValue(token: String) -> String {
        return "Basic " + "\(token):".dataUsingEncoding(NSASCIIStringEncoding)!.base64EncodedStringWithOptions([]) //  NSUTF8StringEncoding
    }
    
    private func valueTypeForObject(object: AnyObject) -> ValueType {
        if let dicValue = object as? [String: AnyObject] {
            let result: ValueType = Obj(json: dicValue) ?? Null()
            return result
        }
        return Null()
    }
}



internal class ClientDelegate: NSObject, NSURLSessionDataDelegate {
    
}
