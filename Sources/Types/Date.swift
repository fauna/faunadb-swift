//
//  Date.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/8/16.
//
//

import Foundation
import Gloss

public struct Date: ScalarType {
    let dateComponents: NSDateComponents
    
    public init(day: Int, month: Int, year: Int){
        dateComponents = NSDateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
    }
    
    public init(iso8601: String){
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT:0)
        let calendar = NSCalendar.currentCalendar()
        let date = dateFormatter.dateFromString(iso8601)!
        dateComponents = calendar.componentsInTimeZone(NSTimeZone(forSecondsFromGMT:0), fromDate: date)
    }
}

extension Date: FaunaEncodable, Encodable {
    
    public func toJSON() -> JSON? {
        let monthStr = dateComponents.month < 9 ? "0\(dateComponents.month)" : String(dateComponents.month)
        let dayStr = dateComponents.day < 9 ? "0\(dateComponents.day)" : String(dateComponents.day)
        return "@date" ~~> "\(dateComponents.year)-\(monthStr)-\(dayStr)"
    }
}
