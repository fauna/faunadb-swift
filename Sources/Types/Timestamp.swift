//
//  Timestamp.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/8/16.
//
//

import Foundation
import Gloss

extension NSDate: ScalarType {}

extension NSDate: FaunaEncodable, Encodable {
    
    public func toJSON() -> JSON? {
        return "@ts" ~~> ISO8601
    }
    
    public convenience init(iso8601: String){
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let date = dateFormatter.dateFromString(iso8601)!
        self.init(timeInterval: 0, sinceDate: date)
    }
}

extension NSDate {
    
    private var ISO8601: String {
        let dateFormatter = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT:0)
        return dateFormatter.stringFromDate(self)
    }
}

public typealias Timestamp = NSDate
