import Foundation

/// A fixed calendar and time zone, so date tests read the same on every machine.
enum TestCalendar {
    static let gregorian: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tbilisi") ?? .gmt
        return calendar
    }()

    /// A date from "yyyy-MM-dd" and an optional "HH:mm:ss", such as `date("2026-11-13", "21:39")`.
    static func date(_ day: String, _ time: String = "00:00:00") -> Date {
        let dayParts = day.split(separator: "-").compactMap { Int($0) }
        let timeParts = time.split(separator: ":").compactMap { Int($0) } + [0, 0, 0]
        guard dayParts.count == 3 else { return .distantPast }
        let components = DateComponents(
            year: dayParts[0],
            month: dayParts[1],
            day: dayParts[2],
            hour: timeParts[0],
            minute: timeParts[1],
            second: timeParts[2]
        )
        return gregorian.date(from: components) ?? .distantPast
    }
}
