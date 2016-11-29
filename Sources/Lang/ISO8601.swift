import Foundation

internal struct ISO8601 {

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        return calendar
    }()

    private static let dateFormatter = ISO8601.formatter(with: "yyyy-MM-dd")
    private static let timeWithMillis = ISO8601.formatter(with: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    private static let timeWithoutMillis = ISO8601.formatter(with: "yyyy-MM-dd'T'HH:mm:ss'Z'")

    static func stringify(time: Date) -> String {
        return timeWithMillis.string(from: time)
    }

    static func stringify(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    static func time(from string: String) -> Date? {
        return formatter(for: string).date(from: string)
    }

    static func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }

    private static func formatter(for string: String) -> DateFormatter {
        if string.contains(".") { return ISO8601.timeWithMillis }
        return ISO8601.timeWithoutMillis
    }

    private static func formatter(with: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = ISO8601.calendar
        formatter.locale = ISO8601.calendar.locale
        formatter.timeZone = ISO8601.calendar.timeZone
        formatter.dateFormat = with

        return formatter
    }
}
