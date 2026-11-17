import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@MainActor
@Suite("Achievement goals")
struct AchievementGoalTests {
    private let countries = [
        Self.country("FR", .europe),
        Self.country("DE", .europe),
        Self.country("JP", .asia),
        Self.country("US", .northAmerica),
        Self.country("BR", .southAmerica),
        Self.country("KE", .africa),
        Self.country("AU", .oceania),
        Self.country("AQ", .antarctica),
    ]

    @Test("A continent unlocks only once every one of its countries is explored")
    func continentNeedsEveryCountry() {
        let service = Self.makeService()

        service.checkExplorationAchievements(exploredCodes: ["FR"], countries: countries)
        #expect(!service.isUnlocked("continent_europe"))

        service.checkExplorationAchievements(exploredCodes: ["FR", "DE"], countries: countries)
        #expect(service.isUnlocked("continent_europe"))
    }

    @Test("The Americas need both North and South America")
    func americasNeedBoth() {
        let service = Self.makeService()

        service.checkExplorationAchievements(exploredCodes: ["US"], countries: countries)
        #expect(!service.isUnlocked("continent_americas"))

        service.checkExplorationAchievements(exploredCodes: ["US", "BR"], countries: countries)
        #expect(service.isUnlocked("continent_americas"))
    }

    @Test("Global Citizen counts continents with an explored country, leaving out Antarctica")
    func globalCitizenCountsContinents() {
        let service = Self.makeService()

        service.checkExplorationAchievements(exploredCodes: ["FR", "JP", "US", "BR", "KE", "AQ"], countries: countries)
        #expect(service.progress(for: "all_continents").currentValue == 5)
        #expect(!service.isUnlocked("all_continents"))

        service.checkExplorationAchievements(
            exploredCodes: ["FR", "JP", "US", "BR", "KE", "AU"],
            countries: countries
        )
        #expect(service.isUnlocked("all_continents"))
    }

    @Test("Only a World Speed Run that names every country counts")
    func speedRunNeedsWholeWorld() {
        let service = Self.makeService()

        service.checkSpeedRunAchievements(region: .europe, namedEveryCountry: true)
        service.checkSpeedRunAchievements(region: .world, namedEveryCountry: false)
        #expect(!service.isUnlocked("speed_run_world"))

        service.checkSpeedRunAchievements(region: .world, namedEveryCountry: true)
        #expect(service.isUnlocked("speed_run_world"))
    }

    @Test("Org Scholar needs every organization the app knows")
    func orgScholarNeedsEveryOrganization() {
        let service = Self.makeService()

        service.checkKnowledgeAchievements(orgsOpened: Organization.all.count - 1)
        #expect(!service.isUnlocked("org_all"))

        service.checkKnowledgeAchievements(orgsOpened: Organization.all.count)
        #expect(service.isUnlocked("org_all"))
    }
}

// MARK: - Helpers
private extension AchievementGoalTests {
    static func makeService() -> AchievementService {
        let userID = UUID().uuidString
        let database = DatabaseManager(inMemory: true)
        let xpService = XPService(db: database, userID: userID)
        let service = AchievementService(db: database, xpService: xpService, userID: userID)
        service.switchUser(id: userID)
        return service
    }

    static func country(_ code: String, _ continent: Country.Continent) -> Country {
        Country(
            code: code,
            name: code,
            capital: code,
            flagEmoji: "",
            continent: continent,
            area: 1,
            population: 1,
            populationDensity: 1,
            currency: Country.Currency(name: "Test", code: "TST"),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}
