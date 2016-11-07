//
//  Timestamp.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public typealias Timestamp = Foundation.Date

extension Timestamp: ScalarValue {}

extension Timestamp {

    public init?(iso8601: String){
        if let date = timestampFirstFormatter.date(from: iso8601) {
            self.init(timeInterval: 0, since: date)
            return
        }
        if let date = timestampSecondFormatter.date(from: iso8601) {
            self.init(timeInterval: 0, since: date)
            return
        }
        return nil
    }

    init?(json: [String: AnyObject]){
        guard let date = json["@ts"] as? String, json.count == 1 else { return nil }
        self.init(iso8601:date)
    }

}

extension Timestamp: Encodable {

    //MARK: Encodable

    func toJSON() -> AnyObject {
        return ["@ts": ISO8601]
    }
}

extension Timestamp {

    fileprivate var ISO8601: String {
        return encodeTimestampFormatter.string(from: self)
    }
}

private let timestampFirstFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    return dateFormatter
}()

private let timestampSecondFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    return dateFormatter
}()

private let encodeTimestampFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPosixLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    dateFormatter.timeZone = TimeZone(secondsFromGMT:0)
    return dateFormatter
}()
