import Foundation

/// When the next daily challenge starts, and how the hub writes the durations around it.
enum DailyChallengeClock {
    static func nextChallengeDate(after now: Date, calendar: Calendar = .current) -> Date {
        let today = calendar.startOfDay(for: now)
        return calendar.date(byAdding: .day, value: 1, to: today) ?? now.addingTimeInterval(86_400)
    }

    /// Time left until the next challenge, such as "2h 21m". Rounds up to the minute, so the last
    /// minute reads "1m", never "0m".
    static func countdown(from now: Date, calendar: Calendar = .current, locale: Locale = .current) -> String {
        let seconds = max(0, nextChallengeDate(after: now, calendar: calendar).timeIntervalSince(now))
        let minutes = Int((seconds / 60).rounded(.up))
        return Duration.seconds(minutes * 60).formatted(
            .units(allowed: [.hours, .minutes], width: .narrow).locale(locale)
        )
    }

    /// How long a challenge took, such as "1m 12s".
    static func elapsed(_ seconds: Double, locale: Locale = .current) -> String {
        let wholeSeconds = Int(max(0, seconds).rounded(.down))
        return Duration.seconds(wholeSeconds).formatted(
            .units(allowed: [.hours, .minutes, .seconds], width: .narrow, maximumUnitCount: 2).locale(locale)
        )
    }
}
