//
//  ClientObserverType.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public protocol ClientObserverType {
    
    func willSendRequest(request: NSURLRequest, session: NSURLSession)
    func didReceiveResponse(response: NSURLResponse?, data: NSData?, error: NSError?, request: NSURLRequest?)
}


public struct Logger: ClientObserverType {
    
    public init() {}
    
    public func willSendRequest(request: NSURLRequest, session: NSURLSession){
        print(request.cURLRepresentation(session))
    }
    
    public func didReceiveResponse(response: NSURLResponse?, data: NSData?, error: NSError?, request: NSURLRequest?) {
        if let error = error {
            print("\nRESPONSE ERROR: \(error)")
        }
        print("\nRESPONSE STATUS: \((response as! NSHTTPURLResponse).statusCode)")
        if let data = data {
            print("\nRESPONSE DATA:")
            let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            print("\n\(jsonData)")
        }
        else {
            print("\nNO RESPONSE DATA")
        }
    }
}

extension NSURLRequest {
    
    func cURLRepresentation(session: NSURLSession) -> String {
        var components = ["\n$ curl -i"]
        
        guard let
            URL = URL,
            host = URL.host
            else {
                return "$ curl command could not be created"
        }
        
        if let HTTPMethod = HTTPMethod where HTTPMethod != "GET" {
            components.append("-X \(HTTPMethod)")
        }
        
        if let credentialStorage =  session.configuration.URLCredentialStorage {
            let protectionSpace = NSURLProtectionSpace(
                host: host,
                port: URL.port?.integerValue ?? 0,
                protocol: URL.scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )
            
            if let credentials = credentialStorage.credentialsForProtectionSpace(protectionSpace)?.values {
                for credential in credentials {
                    components.append("-u \(credential.user!):\(credential.password!)")
                }
            }
        }
        
        if session.configuration.HTTPShouldSetCookies {
            if let
                cookieStorage = session.configuration.HTTPCookieStorage,
                cookies = cookieStorage.cookiesForURL(URL) where !cookies.isEmpty
            {
                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value ?? String());" }
                components.append("-b \"\(string.substringToIndex(string.endIndex.predecessor()))\"")
            }
        }
        
        var headers: [NSObject: AnyObject] = [:]
        
        if let additionalHeaders = session.configuration.HTTPAdditionalHeaders {
            for (field, value) in additionalHeaders where field != "Cookie" {
                headers[field] = value
            }
        }
        
        if let headerFields = allHTTPHeaderFields {
            for (field, value) in headerFields where field != "Cookie" {
                headers[field] = value
            }
        }
        
        for (field, value) in headers {
            components.append("-H \"\(field): \(ClientHeaders.Authorization.rawValue != field ? value : "Basic <hidden>")\"")
        }
        
        if let
            HTTPBodyData = HTTPBody,
            HTTPBody = String(data: HTTPBodyData, encoding: NSUTF8StringEncoding)
        {
            var escapedBody = HTTPBody.stringByReplacingOccurrencesOfString("\\\"", withString: "\\\\\"")
            escapedBody = escapedBody.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
            
            components.append("-d \"\(escapedBody)\"")
        }
        
        components.append("\"\(URL.absoluteString)\"")
        
        return components.joinWithSeparator(" \\\n\t")
    }

}