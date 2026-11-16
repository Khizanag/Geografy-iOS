import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play

/// Builders shared by the flashcard tests. Each service gets a fresh user, so tests never see each other's reviews.
@MainActor
enum FlashcardTestFixtures {
    static func makeService(userID: String = "flashcard-tests-\(UUID().uuidString)") -> FlashcardService {
        UserScope.activate(userID)
        let service = FlashcardService()
        service.loadData()
        return service
    }

    nonisolated static func makeCountry(code: String) -> Country {
        Country(
            code: code,
            name: code,
            capital: "\(code) capital",
            flagEmoji: "",
            continent: .europe,
            area: 1,
            population: 1,
            populationDensity: 1,
            currency: Country.Currency(name: "", code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}
