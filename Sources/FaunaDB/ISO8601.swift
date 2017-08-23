import Foundation

private let ISOCalendar: Calendar = {
    var calendar = Calendar(identifier: .iso8601)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

internal struct ISO8601Formatter {

    private let formatter: DateFormatter

    init(with format: String) {
        let formatter = DateFormatter()
        formatter.calendar = ISOCalendar
        formatter.locale = ISOCalendar.locale
        formatter.timeZone = ISOCalendar.timeZone
        formatter.dateFormat = format

        self.formatter = formatter
    }

    func string(for date: Date) -> String {
        return formatter.string(from: date)
    }

    func parse(from string: String) -> Date? {
        return formatter.date(from: string)
    }

}
