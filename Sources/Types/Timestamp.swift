//
//  Timestamp.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public typealias Timestamp = NSDate

extension Timestamp: ScalarValue {}

extension Timestamp {

    public convenience init?(iso8601: String){
        if let date = timestampFirstFormatter.dateFromString(iso8601) {
            self.init(timeInterval: 0, sinceDate: date)
            return
        }
        if let date = timestampSecondFormatter.dateFromString(iso8601) {
            self.init(timeInterval: 0, sinceDate: date)
            return
        }
        return nil
    }

    convenience init?(json: [String: AnyObject]){
        guard let date = json["@ts"] as? String where json.count == 1 else { return nil }
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

    private var ISO8601: String {
        return encodeTimestampFormatter.stringFromDate(self)
    }
}

private let timestampFirstFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    return dateFormatter
}()

private let timestampSecondFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    return dateFormatter
}()

private let encodeTimestampFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.locale = enUSPosixLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT:0)
    return dateFormatter
}()
