@testable import Geografy_Feature_DailyChallenge
import Testing

@Suite("Daily challenge results per user")
struct DailyChallengeOwnershipTests {
    @Test("History keeps only the signed-in user's results")
    func keepsOnlyOwnResults() {
        let results = [
            Self.makeResult(userID: "me", dateKey: "2026-11-13"),
            Self.makeResult(userID: "someone-else", dateKey: "2026-11-13"),
            Self.makeResult(userID: "me", dateKey: "2026-11-12"),
        ]

        let mine = DailyChallengeService.results(for: "me", in: results)

        #expect(mine.map(\.dateKey) == ["2026-11-13", "2026-11-12"])
        #expect(mine.allSatisfy { $0.userID == "me" })
    }

    @Test("A user with no results gets an empty history")
    func newUserStartsEmpty() {
        let results = [Self.makeResult(userID: "someone-else", dateKey: "2026-11-13")]

        #expect(DailyChallengeService.results(for: "me", in: results).isEmpty)
    }
}

// MARK: - Fixtures
private extension DailyChallengeOwnershipTests {
    static func makeResult(userID: String, dateKey: String) -> DailyChallengeResult {
        DailyChallengeResult(
            userID: userID,
            dateKey: dateKey,
            challengeType: "flagSequence",
            score: 800,
            timeSpentSeconds: 60
        )
    }
}
