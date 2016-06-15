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

    public func query(@autoclosure expr: (()-> Expr), completion: (Result<Value, FaunaDB.Error> -> Void)? = nil) -> NSURLSessionDataTask {
        let jsonData = try! toData(expr().toJSON()) ?? NSData()
        return postJSON(jsonData) { [weak self] (data, response, error) in
            do {
                guard let mySelf = self else { return }
                try mySelf.handleNetworkingErrors(response, error: error)
                let jsonData =  try mySelf.handleQueryErrors(response, data: data)
                let result = try! Mapper.fromData(jsonData ?? NSNull())
                completion?(Result.Success(result))
            }
            catch {
                guard let faunaError = error as? FaunaDB.Error else {
                    completion?(.Failure(.UnknownException(response: response, errors: [], msg: (error as NSError).description)))
                    return
                }
                completion?(.Failure(faunaError))
            }
        }
    }
}

extension Client {

    private func postJSON(data: NSData, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)) -> NSURLSessionDataTask{
        let request = NSMutableURLRequest(URL: faunaRoot)
        request.HTTPBody = data
        request.HTTPMethod = "POST"
        var headers = request.allHTTPHeaderFields ?? [String: String]()
        headers["Content-Type"] = "application/json; charset=utf-8"
        request.allHTTPHeaderFields = headers
        return performRequest(request, completion: completion);
    }

    private func performRequest(request: NSURLRequest, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)) -> NSURLSessionDataTask {

        let dataTask = session.dataTaskWithRequest(request) { [weak self] data, response, error  in
            self?.observers.forEach { $0.didReceiveResponse(response, data: data, error: error, request: request) }
            completion(data, response, error)
        }
        observers.forEach { $0.willSendRequest(dataTask.currentRequest ?? dataTask.originalRequest ?? request, session: session) }
        dataTask.resume()
        return dataTask
    }

}

extension Client {


    func handleNetworkingErrors(response: NSURLResponse?, error: NSError?) throws {
        guard let error = error else { return }
        throw Error.NetworkException(response: response, error: error, msg: error.description)
    }

    func handleQueryErrors(response: NSURLResponse?, data: NSData?) throws -> AnyObject? {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            throw Error.NetworkException(response: response, error: nil, msg: "Cannot cast NSURLResponse to NSHTTPURLResponse")
        }

        if httpResponse.statusCode >= 300 {
            var errors = [ErrorResponse]()
            do {
                let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                let array = json.objectForKey("errors") as! [[String: AnyObject]]
                errors = array.map { ErrorResponse(json: $0)! }
            }
            catch {
                    if httpResponse.statusCode == 503 {
                        throw Error.UnavailableException(response: response, errors: [], msg: "Service Unavailable: Unparseable response.")
                    }
                    throw Error.UnknownException(response: response, errors: [], msg: "Unparsable service \(httpResponse.statusCode) response.")
            }    
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
        if let data = data {
            let str = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
            print (str)
            let jsonData: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            return jsonData.objectForKey("resource")
        }
        return nil
    }
}


extension Client {

    private static func authHeaderValue(token: String) -> String {
        return "Basic " + "\(token):".dataUsingEncoding(NSASCIIStringEncoding)!.base64EncodedStringWithOptions([])
    }
    
    private func toData(object: AnyObject?) throws -> NSData? {
        guard let object = object else { return nil }
        if object is [AnyObject] || object is [String: AnyObject] {
            return try NSJSONSerialization.dataWithJSONObject(object, options: [])
        }
        else if let str = object as? String, let data = str.dataUsingEncoding(NSUTF8StringEncoding) {
            return data
        }
        return nil
    }

}



internal class ClientDelegate: NSObject, NSURLSessionDataDelegate {

}
