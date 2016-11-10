//
//  Date.swift
//  FaunaDB
//
//  Copyright © 2016 Fauna, Inc. All rights reserved.
//

import Foundation

public typealias Date = DateComponents

extension Date: ScalarValue {

    public init(day: Int, month: Int, year: Int){
        self.init()
        self.day = day
        self.month = month
        self.year = year
    }

    public init?(iso8601: String){
        guard let date = dateFormatter.date(from: iso8601) else { return nil }
        let dateComponents = Calendar.current.dateComponents(in: TimeZone(secondsFromGMT:0)!, from: date)
        self.init()
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
    }

    init?(json: [String: AnyObject]){
        guard let date = json["@date"] as? String, json.count == 1 else { return nil }
        self.init(iso8601:date)
    }
}

extension Date: Encodable {

    //MARK: Encodable

    func toJSON() -> AnyObject {
        let monthStr = month! < 9 ? "0\(month)" : String(describing: month)
        let dayStr = day! < 9 ? "0\(day)" : String(describing: day)
        return ["@date": "\(year)-\(monthStr)-\(dayStr)"] as AnyObject
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT:0)
    return dateFormatter
}()
