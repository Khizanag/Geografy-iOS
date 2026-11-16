import Foundation
@testable import Geografy_Feature_Play
import Testing

@Suite("Daily challenge history order")
struct DailyChallengeHistoryOrderTests {
    @Test("Later days come first")
    func newerDaysFirst() {
        let results = [
            Self.makeResult(id: "old", dateKey: "2026-11-11"),
            Self.makeResult(id: "new", dateKey: "2026-11-13"),
            Self.makeResult(id: "middle", dateKey: "2026-11-12"),
        ]

        let ordered = DailyChallengeService.newestFirst(results)

        #expect(ordered.map(\.id) == ["new", "middle", "old"])
    }

    @Test("On the same day the latest finish comes first")
    func sameDayLatestFirst() {
        let morning = TestCalendar.date("2026-11-13", "08:00")
        let evening = TestCalendar.date("2026-11-13", "20:00")
        let results = [
            Self.makeResult(id: "morning", dateKey: "2026-11-13", completedAt: morning),
            Self.makeResult(id: "evening", dateKey: "2026-11-13", completedAt: evening),
        ]

        let ordered = DailyChallengeService.newestFirst(results)

        #expect(ordered.map(\.id) == ["evening", "morning"])
    }
}

// MARK: - Fixtures
private extension DailyChallengeHistoryOrderTests {
    static func makeResult(id: String, dateKey: String, completedAt: Date = .now) -> DailyChallengeResult {
        DailyChallengeResult(
            id: id,
            userID: "me",
            dateKey: dateKey,
            challengeType: "flagSequence",
            score: 800,
            completedAt: completedAt,
            timeSpentSeconds: 60
        )
    }
}
