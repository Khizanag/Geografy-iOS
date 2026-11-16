import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

extension UserScopedTests {
    @MainActor
    @Suite("FlashcardService persistence", .serialized)
    struct FlashcardServicePersistenceTests {
        @Test("A review waits for the save delay before it's written")
        func reviewIsNotWrittenRightAway() {
            let userID = Self.makeUserID()
            let service = FlashcardTestFixtures.makeService(userID: userID)

            service.recordReview(cardID: Self.cardID, result: .good)

            #expect(Self.storedCardIDs(for: userID).isEmpty)
        }

        @Test("Pending reviews are written when asked")
        func persistPendingWrites() {
            let userID = Self.makeUserID()
            let service = FlashcardTestFixtures.makeService(userID: userID)

            service.recordReview(cardID: Self.cardID, result: .good)
            service.persistPendingChanges()

            #expect(Self.storedCardIDs(for: userID) == [Self.cardID])
        }

        @Test("Reviews are written once the save delay passes")
        func delayedSaveWrites() async throws {
            let userID = Self.makeUserID()
            UserScope.activate(userID)
            let service = FlashcardService(saveDelay: .milliseconds(10))
            service.loadData()

            service.recordReview(cardID: Self.cardID, result: .good)
            try await Task.sleep(for: .milliseconds(300))

            #expect(Self.storedCardIDs(for: userID) == [Self.cardID])
        }

        @Test("Switching users saves the previous user's pending reviews under their own key")
        func userSwitchKeepsReviewsWithTheirOwner() {
            let firstUser = Self.makeUserID()
            let secondUser = Self.makeUserID()
            let service = FlashcardTestFixtures.makeService(userID: firstUser)
            service.recordReview(cardID: Self.cardID, result: .good)

            UserScope.activate(secondUser)
            service.loadData()

            #expect(Self.storedCardIDs(for: firstUser) == [Self.cardID])
            #expect(Self.storedCardIDs(for: secondUser).isEmpty)
            #expect(service.reviewedTodayCount() == 0)
        }

        @Test("Today's review count and streak follow new reviews")
        func todayCountsFollowReviews() {
            let service = FlashcardTestFixtures.makeService(userID: Self.makeUserID())
            #expect(service.reviewedTodayCount() == 0)
            #expect(service.currentStreak() == 0)

            service.recordReview(cardID: Self.cardID, result: .good)
            service.recordReview(cardID: "DE_countryToCapital", result: .again)

            #expect(service.reviewedTodayCount() == 2)
            #expect(service.currentStreak() == 1)
        }
    }
}

// MARK: - Fixtures
private extension UserScopedTests.FlashcardServicePersistenceTests {
    static let cardID = "FR_countryToCapital"

    static func makeUserID() -> String {
        "flashcard-tests-\(UUID().uuidString)"
    }

    static func storedCardIDs(for userID: String) -> [String] {
        let key = "flashcard_spaced_repetition_data.user.\(userID)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let store = try? JSONDecoder().decode([String: SpacedRepetitionData].self, from: data) else {
            return []
        }
        return store.keys.sorted()
    }
}
