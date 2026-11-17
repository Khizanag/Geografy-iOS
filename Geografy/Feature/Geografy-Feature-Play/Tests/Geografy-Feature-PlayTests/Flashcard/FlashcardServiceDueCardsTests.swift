import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

@MainActor
@Suite("FlashcardService due cards", .serialized)
struct FlashcardServiceDueCardsTests {
    @Test("Every card is due for someone who has never reviewed")
    func allDueAtFirst() {
        let service = FlashcardTestFixtures.makeService()

        #expect(service.dueCount(of: .countryToCapital, in: Self.countries) == Self.countries.count)
    }

    @Test("A reviewed card leaves the due list")
    func reviewedCardLeaves() {
        let service = FlashcardTestFixtures.makeService()
        _ = service.dueCards(of: .countryToCapital, in: Self.countries)

        service.recordReview(cardID: Self.cardID("FR"), result: .good)

        let due = service.dueCards(of: .countryToCapital, in: Self.countries)
        #expect(due.map(\.countryCode) == ["DE", "ES"])
        #expect(service.dueCount(of: .countryToCapital, in: Self.countries) == 2)
    }

    @Test("Due cards match the item-based filter")
    func matchesItemFilter() {
        let service = FlashcardTestFixtures.makeService()
        service.recordReview(cardID: Self.cardID("DE"), result: .easy)
        let items = Self.countries.map { FlashcardItem.make(from: $0, type: .countryToCapital) }

        #expect(service.dueCards(of: .countryToCapital, in: Self.countries) == service.dueCards(from: items))
    }

    @Test("Cards of another type are counted on their own")
    func typesAreSeparate() {
        let service = FlashcardTestFixtures.makeService()
        service.recordReview(cardID: Self.cardID("FR"), result: .good)

        #expect(service.dueCount(of: .countryToCapital, in: Self.countries) == 2)
        #expect(service.dueCount(of: .flagToCountry, in: Self.countries) == 3)
    }
}

// MARK: - New Cards a Day
extension FlashcardServiceDueCardsTests {
    @Test("Someone who has never reviewed starts with a day's worth of new cards, not every country")
    func newCardsAreCapped() {
        let service = FlashcardTestFixtures.makeService()

        #expect(service.dueCount(of: .countryToCapital, in: Self.manyCountries) == FlashcardService.newCardsPerDay)
    }

    @Test("Cards started today use up the day's new cards")
    func startedTodayCountAgainstTheCap() {
        let service = FlashcardTestFixtures.makeService()
        for code in Self.manyCountries.prefix(4).map(\.code) {
            service.recordReview(cardID: Self.cardID(code), result: .good)
        }

        #expect(service.dueCount(of: .countryToCapital, in: Self.manyCountries) == FlashcardService.newCardsPerDay - 4)
    }
}

// MARK: - Fixtures
private extension FlashcardServiceDueCardsTests {
    static let countries = ["FR", "DE", "ES"].map(FlashcardTestFixtures.makeCountry)
    static let manyCountries = (0..<15).map { FlashcardTestFixtures.makeCountry(code: "C\($0)") }

    static func cardID(_ code: String) -> String {
        "\(code)_\(FlashcardType.countryToCapital.rawValue)"
    }
}
