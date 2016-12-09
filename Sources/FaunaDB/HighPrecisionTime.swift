import Foundation

fileprivate let timeFormatter = ISO8601Formatter(with: "yyyy-MM-dd'T'HH:mm:ss")

fileprivate let millisInASecond = 1_000
fileprivate let microsInASecond = 1_000_000
fileprivate let nanosInASecond  = 1_000_000_000
fileprivate let nanosInAMicro   = 1_000
fileprivate let nanosInAMilli   = 1_000_000

/// Represents a high precision time starting from UNIX epoch: "1970-01-01".
public struct HighPrecisionTime {

    /// Current date represented in seconds passed since January 1st, 1970.
    public let secondsSince1970: Int

    /// Nanoseconds offset added to the current date.
    public let nanosecondsOffset: Int

    /**
        - Parameters:
            - secondsSince1970:  Number of seconds passed January 1st, 1970
            - nanosecondsOffset: Nanoseconds to be added to the initial date
    */
    public init(secondsSince1970: Int, nanosecondsOffset: Int = 0) {
        self.init(
            secondsSince1970: secondsSince1970,
            adjust: nanosecondsOffset,
            overflowWith: nanosInASecond
        )
    }

    fileprivate init(secondsSince1970: Int, adjust: Int, overflowWith limit: Int, multiplyBy factor: Int = 1) {
        self.secondsSince1970 = secondsSince1970 + (adjust / limit)
        self.nanosecondsOffset = (adjust % limit) * factor
    }

    /// Converts to a `Foundation.Date`.
    /// - Note: Ignores the nanoseconds precision.
    public func toDate() -> Date {
        return Date(timeIntervalSince1970: Double(secondsSince1970))
    }

}

extension HighPrecisionTime {

    /// Converts a `Foundation.Date` into an instance of `HighPrecisionTime`.
    /// - Note: Ignores anything lower than seconds precision.
    public init(date: Date) {
        self.init(secondsSince1970: Int(date.timeIntervalSince1970))
    }

    /**
        - Parameters:
            - secondsSince1970:   Number of seconds passed January 1st, 1970
            - millisecondsOffset: Milliseconds to be added to the initial date
    */
    public init(secondsSince1970: Int, millisecondsOffset: Int) {
        self.init(
            secondsSince1970: secondsSince1970,
            adjust: millisecondsOffset,
            overflowWith: millisInASecond,
            multiplyBy: nanosInAMilli
        )
    }

    /**
        - Parameters:
            - secondsSince1970:   Number of seconds passed January 1st, 1970
            - microsecondsOffset: Microseconds to be added to the initial date
    */
    public init(secondsSince1970: Int, microsecondsOffset: Int) {
        self.init(
            secondsSince1970: secondsSince1970,
            adjust: microsecondsOffset,
            overflowWith: microsInASecond,
            multiplyBy: nanosInAMicro
        )
    }

}

extension HighPrecisionTime {

    init?(parse string: String) {
        let parts = string
            .replacingOccurrences(of: "Z", with: "")
            .components(separatedBy: ".")

        guard
            1 ... 2 ~= parts.count,
            let time = timeFormatter.parse(from: parts[0])
            else { return nil }

        if parts.count == 2 {
            guard
                let nanos = Int(parts[1].padding(toLength: 9, withPad: "0", startingAt: 0))
                else { return nil }

            self.init(secondsSince1970: Int(time.timeIntervalSince1970), nanosecondsOffset: nanos)
            return
        }

        self.init(secondsSince1970: Int(time.timeIntervalSince1970))
    }

}

extension HighPrecisionTime: CustomStringConvertible {
    public var description: String {
        return timeFormatter.string(for: toDate())
            + ".\(String(format: "%09d", nanosecondsOffset))Z"
    }
}

extension HighPrecisionTime: Equatable {
    public static func == (left: HighPrecisionTime, right: HighPrecisionTime) -> Bool {
        return
            left.secondsSince1970 == right.secondsSince1970 &&
            left.nanosecondsOffset == right.nanosecondsOffset
    }
}
