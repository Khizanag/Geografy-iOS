import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

extension UserScopedTests {
    @MainActor
    @Suite("Game answers in reviews", .serialized)
    struct FlashcardGameAnswerTests {
        private static let cardID = FlashcardItem.id(countryCode: "FR", type: .flagToCountry)

        @Test("A missed answer puts the card into review")
        func missStartsReview() throws {
            let service = FlashcardTestFixtures.makeService(userID: UUID().uuidString)

            service.recordGameAnswer(countryCode: "FR", type: .flagToCountry, isCorrect: false)

            let card = try #require(service.spacedRepetitionStore[Self.cardID])
            #expect(card.totalReviews == 1)
            #expect(card.correctReviews == 0)
        }

        @Test("A right answer counts for a new card")
        func rightAnswerCountsWhenNew() throws {
            let service = FlashcardTestFixtures.makeService(userID: UUID().uuidString)

            service.recordGameAnswer(countryCode: "FR", type: .flagToCountry, isCorrect: true)

            #expect(try #require(service.spacedRepetitionStore[Self.cardID]).correctReviews == 1)
        }

        @Test("Replaying doesn't push a card that isn't due yet further out")
        func rightAnswerWaitsUntilDue() throws {
            let service = FlashcardTestFixtures.makeService(userID: UUID().uuidString)
            service.recordGameAnswer(countryCode: "FR", type: .flagToCountry, isCorrect: true)
            let scheduled = try #require(service.spacedRepetitionStore[Self.cardID]).nextReviewDate

            service.recordGameAnswer(countryCode: "FR", type: .flagToCountry, isCorrect: true)

            let card = try #require(service.spacedRepetitionStore[Self.cardID])
            #expect(card.totalReviews == 1)
            #expect(card.nextReviewDate == scheduled)
        }

        @Test("Only quiz types with a matching card count toward reviews")
        func quizTypeMapping() {
            #expect(FlashcardType(quizType: .flagQuiz) == .flagToCountry)
            #expect(FlashcardType(quizType: .reverseCapital) == .capitalToCountry)
            #expect(FlashcardType(quizType: .neighbors) == nil)
        }
    }
}
