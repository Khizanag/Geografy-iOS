import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

@Suite("Flashcard session model")
struct FlashcardSessionModelTests {
    @Test("Wrong is Wrong, however fast it came")
    func wrongIsAgain() {
        #expect(FlashcardRecall.result(knewIt: false, isFlipped: false, thinkingTime: nil) == .again)
        #expect(FlashcardRecall.result(knewIt: false, isFlipped: true, thinkingTime: 1) == .again)
    }

    @Test("Got It before turning the card means it was known at once")
    func knownBeforeFlipIsEasy() {
        #expect(FlashcardRecall.result(knewIt: true, isFlipped: false, thinkingTime: nil) == .easy)
    }

    @Test(
        "Got It after turning reads the think time",
        arguments: [
            (1.0, false),
            (9.9, false),
            (10.0, true),
            (30.0, true),
        ]
    )
    func thinkTimeSetsRecall(seconds: Double, isStruggle: Bool) {
        let result = FlashcardRecall.result(knewIt: true, isFlipped: true, thinkingTime: seconds)
        #expect(result == (isStruggle ? .hard : .good))
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
