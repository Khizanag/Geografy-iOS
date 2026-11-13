import Foundation
@testable import Geografy_Feature_DailyChallenge
import Testing

@Suite("DailyChallengeClock")
struct DailyChallengeClockTests {
    private let calendar = TestCalendar.gregorian
    private let locale = Locale(identifier: "en_US")

    @Test("The next challenge starts at the coming midnight")
    func nextChallengeDate() {
        let now = TestCalendar.date("2026-11-13", "21:39")

        let next = DailyChallengeClock.nextChallengeDate(after: now, calendar: calendar)

        #expect(next == TestCalendar.date("2026-11-14"))
    }

    @Test("The countdown reads hours and minutes")
    func countdownHoursAndMinutes() {
        let now = TestCalendar.date("2026-11-13", "21:39")

        #expect(DailyChallengeClock.countdown(from: now, calendar: calendar, locale: locale) == "2h 21m")
    }

    @Test("Part of a minute rounds up, so the last minute never reads zero")
    func countdownRoundsUp() {
        let now = TestCalendar.date("2026-11-13", "23:59:30")

        #expect(DailyChallengeClock.countdown(from: now, calendar: calendar, locale: locale) == "1m")
    }

    @Test("At midnight a full day is left")
    func countdownAtMidnight() {
        let now = TestCalendar.date("2026-11-13")

        #expect(DailyChallengeClock.countdown(from: now, calendar: calendar, locale: locale) == "24h")
    }

    @Test(
        "Elapsed time reads in its two largest units",
        arguments: [
            (0.0, "0s"),
            (9.8, "9s"),
            (72.4, "1m 12s"),
            (3_725.0, "1h 2m"),
        ]
    )
    func elapsed(seconds: Double, expected: String) {
        #expect(DailyChallengeClock.elapsed(seconds, locale: locale) == expected)
    }
}
