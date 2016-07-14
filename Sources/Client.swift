//
//  Client.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation
import Result

enum ClientHeaders: String {
    case PrettyPrintJSONResponses = "X-FaunaDB-Formatted-JSON"
    case Authorization = "Authorization"
}

public final class Client {
    public let session: NSURLSession
    public let endpoint: NSURL
    public let secret: String
    
    private let observers: [ClientObserverType]
    private var authHeader: String
    
    public init(secret:String,
                endpoint: NSURL = NSURL(string: "https://rest.faunadb.com")!,
                timeout: NSTimeInterval = 60, observers: [ClientObserverType] = []){
        self.endpoint = endpoint
        self.secret = secret
        self.observers = observers
        authHeader = Client.authHeaderValue(secret)
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = timeout
        var headers = sessionConfig.HTTPAdditionalHeaders ?? [NSObject: AnyObject]()
        headers[ClientHeaders.Authorization.rawValue] = authHeader
        sessionConfig.HTTPAdditionalHeaders = headers
        session =  NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .mainQueue())
    }

}


extension Client {

    public func query(@autoclosure expr: (()-> ValueConvertible), completion: (Result<Value, FaunaDB.Error> -> Void)) -> NSURLSessionDataTask {
        let jsonData = try! toData(expr().toJSON())
        return postJSON(jsonData) { [weak self] (data, response, error) in
            do {
                guard let mySelf = self else { return }
                try mySelf.handleNetworkingErrors(response, error: error)
                guard let data = data else {
                    throw Error.UnknownException(response: response, errors: [], msg: "Empty server response")
                }
                try mySelf.handleQueryErrors(response, data: data)
                let result = try Mapper.fromFaunaResponseData(data)
                completion(Result.Success(result))
            }
            catch {
                guard let faunaError = error as? FaunaDB.Error else {
                    completion(.Failure(.UnknownException(response: response, errors: [], msg: (error as NSError).description)))
                    return
                }
                completion(.Failure(faunaError))
            }
        }
    }
}

extension Client {

    private func postJSON(data: NSData, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)) -> NSURLSessionDataTask{
        let request = NSMutableURLRequest(URL: endpoint)
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


    private func handleNetworkingErrors(response: NSURLResponse?, error: NSError?) throws {
        guard let error = error else { return }
        throw Error.NetworkException(response: response, error: error, msg: error.description)
    }

    private func handleQueryErrors(response: NSURLResponse?, data: NSData) throws {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            throw Error.NetworkException(response: response, error: nil, msg: "Fail to parse network response. Invalid response type.")
        }

        if httpResponse.statusCode >= 300 {
            var errors = [ErrorResponse]()
            do {
                let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                let array = json.objectForKey("errors") as! [[String: AnyObject]]
                errors = array.map { ErrorResponse(json: $0)! }
            }
            catch {
                if httpResponse.statusCode == 503 {
                    throw Error.UnavailableException(response: response, errors: [])
                }
                throw Error.UnknownException(response: response, errors: [], msg: "Unparsable service \(httpResponse.statusCode) response.")
            }
            switch httpResponse.statusCode {
            case 400:
                throw Error.BadRequestException(response: response, errors: errors)
            case 401:
                throw Error.UnauthorizedException(response: response, errors: errors)
            case 404:
                throw Error.NotFoundException(response: response, errors: errors)
            case 500:
                throw Error.InternalException(response: response, errors: errors, msg: nil)
            case 503:
                throw Error.UnavailableException(response: response, errors: errors)
            default:
                throw Error.UnknownException(response: response, errors: errors, msg: nil)
            }
        }
    }
}


extension Client {

    private static func authHeaderValue(token: String) -> String {
        return "Basic " + "\(token):".dataUsingEncoding(NSASCIIStringEncoding)!.base64EncodedStringWithOptions([])
    }
    
    private func toData(object: AnyObject) throws -> NSData {
        if object is [AnyObject] || object is [String: AnyObject] {
            return try NSJSONSerialization.dataWithJSONObject(object, options: [])
        }
        else if let str = object as? String, let data = "\"\(str)\"".dataUsingEncoding(NSUTF8StringEncoding) {
            return data
        }
        throw Error.DriverException(data: object, msg: "Unsupported JSON type: \(object.dynamicType)")
    }

}
