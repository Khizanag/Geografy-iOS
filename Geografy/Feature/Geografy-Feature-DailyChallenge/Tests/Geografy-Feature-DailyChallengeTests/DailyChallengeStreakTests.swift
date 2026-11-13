import Foundation
@testable import Geografy_Feature_DailyChallenge
import Testing

@Suite("DailyChallengeStreak")
struct DailyChallengeStreakTests {
    private let calendar = TestCalendar.gregorian
    private let today = TestCalendar.date("2026-11-13", "15:00")

    @Test("No results start nothing")
    func noResults() {
        let streak = DailyChallengeStreak(dateKeys: [], today: today, calendar: calendar)

        #expect(streak.current == 0)
        #expect(streak.best == 0)
        #expect(streak.completedCount == 0)
        #expect(streak.status == .notStarted)
        #expect(streak.lastWeek.map(\.state) == [.missed, .missed, .missed, .missed, .missed, .missed, .pending])
    }

    @Test("Playing today extends the run through today")
    func playedToday() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2026-11-11", "2026-11-12", "2026-11-13"],
            today: today,
            calendar: calendar
        )

        #expect(streak.current == 3)
        #expect(streak.isTodayDone)
        #expect(streak.status == .extended(days: 3))
        #expect(streak.lastWeek.suffix(3).map(\.state) == [.done, .done, .done])
    }

    @Test("A run through yesterday is still alive but at risk")
    func playedThroughYesterday() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2026-11-10", "2026-11-11", "2026-11-12"],
            today: today,
            calendar: calendar
        )

        #expect(streak.current == 3)
        #expect(streak.status == .atRisk(days: 3))
        #expect(streak.lastWeek.last?.state == .pending)
    }

    @Test("A missed day yesterday ends the run")
    func missedYesterday() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2026-11-10", "2026-11-11"],
            today: today,
            calendar: calendar
        )

        #expect(streak.current == 0)
        #expect(streak.best == 2)
        #expect(streak.status == .notStarted)
    }

    @Test("Best streak finds the longest run anywhere in history")
    func bestStreak() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2026-10-01", "2026-10-02", "2026-10-03", "2026-10-04", "2026-11-12", "2026-11-13"],
            today: today,
            calendar: calendar
        )

        #expect(streak.current == 2)
        #expect(streak.best == 4)
        #expect(streak.completedCount == 6)
    }

    @Test("Runs cross month and year ends")
    func runAcrossYearEnd() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2025-12-30", "2025-12-31", "2026-01-01"],
            today: TestCalendar.date("2026-01-01"),
            calendar: calendar
        )

        #expect(streak.current == 3)
        #expect(streak.best == 3)
    }

    @Test("Duplicate and malformed keys are ignored")
    func duplicatesAndMalformedKeys() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2026-11-13", "2026-11-13", "not-a-date", "2026-13-01", "2026-02-30"],
            today: today,
            calendar: calendar
        )

        #expect(streak.current == 1)
        #expect(streak.completedCount == 1)
    }

    @Test("The last week runs oldest to newest and ends today")
    func lastWeekOrder() {
        let streak = DailyChallengeStreak(
            dateKeys: ["2026-11-07", "2026-11-09"],
            today: today,
            calendar: calendar
        )

        #expect(streak.lastWeek.count == DailyChallengeStreak.weekLength)
        #expect(streak.lastWeek.first?.date == TestCalendar.date("2026-11-07"))
        #expect(streak.lastWeek.last?.date == TestCalendar.date("2026-11-13"))
        #expect(streak.lastWeek.map(\.state) == [.done, .missed, .done, .missed, .missed, .missed, .pending])
    }
}

@Suite("DailyChallengeResult date keys")
struct DailyChallengeResultDateKeyTests {
    private let calendar = TestCalendar.gregorian

    @Test("A key round-trips through its date")
    func roundTrip() {
        let date = TestCalendar.date("2026-03-07", "22:00")

        let key = DailyChallengeResult.dateKey(for: date, calendar: calendar)

        #expect(key == "2026-03-07")
        #expect(DailyChallengeResult.date(forKey: key, calendar: calendar) == TestCalendar.date("2026-03-07"))
    }

    @Test(
        "Keys that don't name a real day give no date",
        arguments: ["", "2026-11", "2026-00-10", "2026-02-30", "a-b-c"]
    )
    func invalidKeys(key: String) {
        #expect(DailyChallengeResult.date(forKey: key, calendar: calendar) == nil)
    }
}
