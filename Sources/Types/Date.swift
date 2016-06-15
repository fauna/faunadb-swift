//
//  Date.swift
//  FaunaDB
//
//  Created by Martin Barreto on 6/8/16.
//
//

import Foundation

public typealias Date = NSDateComponents

extension Date: ScalarType {
    
    public convenience init(day: Int, month: Int, year: Int){
        self.init()
        self.day = day
        self.month = month
        self.year = year
    }
    
    public convenience init?(iso8601: String){
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT:0)
        let calendar = NSCalendar.currentCalendar()
        guard let date = dateFormatter.dateFromString(iso8601) else { return nil }
        let dateComponents = calendar.componentsInTimeZone(NSTimeZone(forSecondsFromGMT:0), fromDate: date)
        self.init()
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
    }
    
    public convenience init?(json: [String: AnyObject]){
        guard let date = json["@date"] as? String where json.count == 1 else { return nil }
        self.init(iso8601:date)
    }
}

extension Date: Encodable {
    
    public func toJSON() -> AnyObject {
        let monthStr = month < 9 ? "0\(month)" : String(month)
        let dayStr = day < 9 ? "0\(day)" : String(day)
        return ["@date": "\(year)-\(monthStr)-\(dayStr)"]
    }
}


