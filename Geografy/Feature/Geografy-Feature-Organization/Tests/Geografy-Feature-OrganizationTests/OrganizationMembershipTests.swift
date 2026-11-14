import Geografy_Core_Common
@testable import Geografy_Feature_Organization
import Testing

@Suite("OrganizationMembership")
struct OrganizationMembershipTests {
    @Test("Counts each country once per organization it belongs to")
    func memberCounts() {
        let counts = OrganizationMembership.memberCounts(in: Self.countries)

        #expect(counts == ["UN": 3, "EU": 2, "NATO": 1])
    }

    @Test("Lists an organization's members by name")
    func membersSortedByName() {
        let members = OrganizationMembership.members(of: "EU", in: Self.countries)

        #expect(members.map(\.name) == ["France", "Germany"])
    }

    @Test("An organization nobody belongs to has no members")
    func noMembers() {
        #expect(OrganizationMembership.members(of: "ASEAN", in: Self.countries).isEmpty)
        #expect(OrganizationMembership.memberCounts(in: Self.countries)["ASEAN"] == nil)
    }
}

// MARK: - Fixtures
private extension OrganizationMembershipTests {
    static let countries = [
        makeCountry(code: "DE", name: "Germany", organizations: ["UN", "EU"]),
        makeCountry(code: "FR", name: "France", organizations: ["UN", "EU", "NATO", "UN"]),
        makeCountry(code: "GE", name: "Georgia", organizations: ["UN"]),
    ]

    static func makeCountry(code: String, name: String, organizations: [String]) -> Country {
        Country(
            code: code,
            name: name,
            capital: "",
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
            organizations: organizations
        )
    }
}
