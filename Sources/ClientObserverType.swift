//
//  ClientObserverType.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public protocol ClientObserverType {

    func willSendRequest(_ request: URLRequest, session: URLSession)
    func didReceiveResponse(_ response: URLResponse?, data: Data?, error: NSError?, request: URLRequest?)
}


public struct Logger: ClientObserverType {

    public init() {}

    public func willSendRequest(_ request: URLRequest, session: URLSession){
        print(request.cURLRepresentation(session))
    }

    public func didReceiveResponse(_ response: URLResponse?, data: Data?, error: NSError?, request: URLRequest?) {
        if let error = error {
            print("\nRESPONSE ERROR: \(error)")
        }
        if let response = response as? HTTPURLResponse {
            print("\nRESPONSE STATUS: \(response.statusCode)")
        }
        if let data = data {
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), JSONSerialization.isValidJSONObject(jsonData){
                print("\nRESPONSE DATA:")
                print("\n\(prettyJSON(jsonData as AnyObject))")
            }
            else {
                print("\nRESPONSE RAW DATA (NOT A VALID JSON):")
                print("\n\(String(data: data, encoding: String.Encoding.utf8))")

            }
        }
        else {
            print("\nNO RESPONSE DATA")
        }
    }


    fileprivate func prettyJSON(_ value: AnyObject, prettyPrinted: Bool = true) -> String {
        guard let prettyData = try? JSONSerialization.data(withJSONObject: value, options: prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : []), let string = NSString(data: prettyData, encoding: String.Encoding.utf8.rawValue) else{
            return String()
        }
        return string as String
    }
}

extension URLRequest {

    func cURLRepresentation(_ session: URLSession) -> String {
        var components = ["\n$ curl -i"]

        guard let
            URL = url,
            let host = URL.host
            else {
                return "$ curl command could not be created"
        }

        if let HTTPMethod = httpMethod, HTTPMethod != "GET" {
            components.append("-X \(HTTPMethod)")
        }

        if let credentialStorage =  session.configuration.urlCredentialStorage {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: (URL as NSURL).port?.intValue ?? 0,
                protocol: URL.scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )

            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    components.append("-u \(credential.user!):\(credential.password!)")
                }
            }
        }

        if session.configuration.httpShouldSetCookies {
            if let
                cookieStorage = session.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: URL), !cookies.isEmpty
            {
                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value ?? String());" }
                components.append("-b \"\(string.substring(to: string.characters.index(before: string.endIndex)))\"")
            }
        }

        var headers: [AnyHashable: Any] = [:]

        if let additionalHeaders = session.configuration.httpAdditionalHeaders {
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
            HTTPBodyData = httpBody,
            let HTTPBody = String(data: HTTPBodyData, encoding: String.Encoding.utf8)
        {
            var escapedBody = HTTPBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(URL.absoluteString)\"")

        return components.joined(separator: " \\\n\t")
    }

}
