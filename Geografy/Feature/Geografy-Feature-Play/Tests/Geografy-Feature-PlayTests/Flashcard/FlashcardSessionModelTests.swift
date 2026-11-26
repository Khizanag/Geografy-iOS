import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

@Suite("Flashcard session model")
struct FlashcardSessionModelTests {
    @Test(
        "An interval reads as days, then weeks, then months",
        arguments: [
            (0.2, "1d"),
            (1.0, "1d"),
            (13.0, "13d"),
            (14.0, "2w"),
            (59.0, "8w"),
            (60.0, "2mo"),
            (365.0, "12mo"),
        ]
    )
    func intervalLabel(days: Double, expected: String) {
        #expect(FlashcardInterval.short(days: days) == expected)
    }

    @Test("A session size caps the cards, and All Due takes every one")
    func sessionSizeLimit() {
        #expect(FlashcardSessionSize.ten.limit == 10)
        #expect(FlashcardSessionSize.twenty.limit == 20)
        #expect(FlashcardSessionSize.all.limit == nil)
    }

    @Test("Review and missed decks ask the card type they're made for")
    func decksKeepCardType() {
        let review = FlashcardDeck.review(cardType: .flagToCountry, region: .world)
        let missed = FlashcardDeck.missed(cardType: .capitalToCountry)

        #expect(review.cardType == .flagToCountry)
        #expect(missed.cardType == .capitalToCountry)
        #expect(review.id != FlashcardDeck.review(cardType: .countryToFlag, region: .world).id)
    }

    @Test("A swipe throws a card toward its own side")
    func throwSign() {
        #expect(FlashcardThrow.right.sign == 1)
        #expect(FlashcardThrow.left.sign == -1)
    }
}
