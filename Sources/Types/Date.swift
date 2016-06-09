//
//  Date.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/8/16.
//
//

import Foundation
import Gloss

extension NSDateComponents: ScalarType {
    
    public convenience init(day: Int, month: Int, year: Int){
        self.init()
        self.day = day
        self.month = month
        self.year = year
    }
    
    public convenience init(iso8601: String){
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT:0)
        let calendar = NSCalendar.currentCalendar()
        let date = dateFormatter.dateFromString(iso8601)!
        let dateComponents = calendar.componentsInTimeZone(NSTimeZone(forSecondsFromGMT:0), fromDate: date)
        self.init()
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
    }
}

extension NSDateComponents: Encodable {
    
    public func toJSON() -> JSON? {
        let monthStr = month < 9 ? "0\(month)" : String(month)
        let dayStr = day < 9 ? "0\(day)" : String(day)
        return "@date" ~~> "\(year)-\(monthStr)-\(dayStr)"
    }
}

public typealias Date = NSDateComponents
