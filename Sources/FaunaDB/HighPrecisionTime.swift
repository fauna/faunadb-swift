import Foundation

fileprivate let timeFormatter = ISO8601Formatter(with: "yyyy-MM-dd'T'HH:mm:ss")

fileprivate let millisInASecond = 1_000
fileprivate let microsInASecond = 1_000_000
fileprivate let nanosInASecond  = 1_000_000_000
fileprivate let nanosInAMicro   = 1_000
fileprivate let nanosInAMilli   = 1_000_000

public struct HighPrecisionTime {

    public let secondsSince1970: Int
    public let nanosecondsOffset: Int

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

    public func toDate() -> Date {
        return Date(timeIntervalSince1970: Double(secondsSince1970))
    }

}

extension HighPrecisionTime {

    public init(date: Date) {
        self.init(secondsSince1970: Int(date.timeIntervalSince1970))
    }

    public init(secondsSince1970: Int, millisecondsOffset: Int) {
        self.init(
            secondsSince1970: secondsSince1970,
            adjust: millisecondsOffset,
            overflowWith: millisInASecond,
            multiplyBy: nanosInAMilli
        )
    }

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
