import Foundation
import Geografy_Core_Common

public struct CountryWithZone: Identifiable {
    public let country: Country
    public let timeZone: TimeZone

    public init(country: Country, timeZone: TimeZone) {
        self.country = country
        self.timeZone = timeZone
    }

    public var id: String { country.code }

    public var currentTime: Date { Date() }

    public var utcOffsetHours: Double {
        Double(timeZone.secondsFromGMT(for: Date())) / 3_600
    }

    public var utcOffsetLabel: String {
        Self.utcOffsetLabel(forHours: utcOffsetHours)
    }

    /// "UTC+4", or "UTC+5:30" for a zone off the hour.
    public static func utcOffsetLabel(forHours hours: Double) -> String {
        let sign = hours >= 0 ? "+" : ""
        if hours == Double(Int(hours)) {
            return "UTC\(sign)\(Int(hours))"
        }
        let absHours = abs(hours)
        let wholeHours = Int(absHours)
        let minutes = Int((absHours - Double(wholeHours)) * 60)
        return "UTC\(sign)\(wholeHours):\(String(format: "%02d", minutes))"
    }
}
