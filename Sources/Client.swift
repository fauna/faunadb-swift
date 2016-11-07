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
    let session: URLSession
    let endpoint: URL
    let secret: String

    fileprivate let observers: [ClientObserverType]
    fileprivate var authHeader: String

    public init(secret:String,
                endpoint: URL = URL(string: "https://rest.faunadb.com")!,
                timeout: TimeInterval = 60, observers: [ClientObserverType] = []){
        self.endpoint = endpoint
        self.secret = secret
        self.observers = observers
        authHeader = Client.authHeaderValue(secret)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = timeout
        var headers = sessionConfig.httpAdditionalHeaders ?? [AnyHashable: Any]()
        headers[ClientHeaders.Authorization.rawValue] = authHeader
        sessionConfig.httpAdditionalHeaders = headers
        session =  URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
    }

}


extension Client {

    public func query(_ expr: @autoclosure () -> Expr, completion: @escaping ((Result<Value, FaunaError>) -> Void)) -> URLSessionDataTask {
        let jsonData = try! Client.toData(expr().toJSON())
        return postJSON(jsonData) { [weak self] (data, response, error) in
            do {
                guard let mySelf = self else {
                    completion(.failure(.unknownException(response: response, errors: [], msg: "Client has been released")))
                    return
                }
                try mySelf.handleNetworkingErrors(response, error: error)
                guard let data = data else {
                    throw FaunaError.unknownException(response: response, errors: [], msg: "Empty server response")
                }
                try mySelf.handleQueryErrors(response, data: data)
                let result = try Mapper.fromFaunaResponseData(data)
                completion(Result.success(result))
            }
            catch {
                guard let faunaError = error as? FaunaError else {
                    completion(.failure(.unknownException(response: response, errors: [], msg: (error as NSError).description)))
                    return
                }
                completion(.failure(faunaError))
            }
        }
    }
}

extension Client {

    fileprivate func postJSON(_ data: Data, completion: @escaping ((Data?, URLResponse?, NSError?) -> Void)) -> URLSessionDataTask{
        let request = NSMutableURLRequest(url: endpoint)
        request.httpBody = data
        request.httpMethod = "POST"
        var headers = request.allHTTPHeaderFields ?? [String: String]()
        headers["Content-Type"] = "application/json; charset=utf-8"
        request.allHTTPHeaderFields = headers
        return performRequest(request as URLRequest, completion: completion);
    }

    fileprivate func performRequest(_ request: URLRequest, completion: @escaping ((Data?, URLResponse?, NSError?) -> Void)) -> URLSessionDataTask {

        let dataTask = session.dataTask(with: request, completionHandler: { [weak self] data, response, error  in
            self?.observers.forEach { $0.didReceiveResponse(response, data: data, error: error as NSError?, request: request) }
            completion(data, response, error as NSError?)
        }) 
        observers.forEach { $0.willSendRequest(dataTask.currentRequest ?? dataTask.originalRequest ?? request, session: session) }
        dataTask.resume()
        return dataTask
    }

}

extension Client {


    fileprivate func handleNetworkingErrors(_ response: URLResponse?, error: NSError?) throws {
        guard let error = error else { return }
        throw FaunaError.networkException(response: response, error: error, msg: error.description)
    }

    fileprivate func handleQueryErrors(_ response: URLResponse?, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FaunaError.networkException(response: response, error: nil, msg: "Fail to parse network response. Invalid response type.")
        }

        if httpResponse.statusCode >= 300 {
            var errors = [ErrorResponse]()
            do {
                let json: AnyObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                let array = json.object(forKey: "errors") as! [[String: AnyObject]]
                errors = array.map { ErrorResponse(json: $0)! }
            }
            catch {
                if httpResponse.statusCode == 503 {
                    throw FaunaError.unavailableException(response: response, errors: [])
                }
                throw FaunaError.unknownException(response: response, errors: [], msg: "Unparsable service \(httpResponse.statusCode) response.")
            }
            switch httpResponse.statusCode {
            case 400:
                throw FaunaError.badRequestException(response: response, errors: errors)
            case 401:
                throw FaunaError.unauthorizedException(response: response, errors: errors)
            case 404:
                throw FaunaError.notFoundException(response: response, errors: errors)
            case 500:
                throw FaunaError.internalException(response: response, errors: errors, msg: nil)
            case 503:
                throw FaunaError.unavailableException(response: response, errors: errors)
            default:
                throw FaunaError.unknownException(response: response, errors: errors, msg: nil)
            }
        }
    }
}


extension Client {

    fileprivate static func authHeaderValue(_ token: String) -> String {
        return "Basic " + "\(token):".data(using: String.Encoding.ascii)!.base64EncodedString(options: [])
    }

    static func toData(_ object: AnyObject) throws -> Data {
        if object is [AnyObject] || object is [String: AnyObject] {
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
        else if let str = object as? String, let data = "\"\(str)\"".data(using: String.Encoding.utf8) {
            return data
        }
        throw FaunaError.driverException(data: object, msg: "Unsupported JSON type: \(type(of: object))")
    }

}
