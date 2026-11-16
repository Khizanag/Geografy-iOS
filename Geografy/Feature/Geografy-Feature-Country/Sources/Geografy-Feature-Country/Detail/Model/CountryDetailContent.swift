import Geografy_Core_Common

// Built lazily once per screen so body re-runs reuse the lookups instead of repeating them.
@MainActor
final class CountryDetailContent {
    let country: Country

    private var memberCounts: [String: Int]?

    init(country: Country) {
        self.country = country
    }

    lazy var profile: CountryProfile? = CountryProfileService().profile(for: country.code)

    lazy var memberOrganizations: [Organization] = country.organizations.compactMap { Organization.find($0) }

    lazy var funFacts: [String] = {
        let curated = CountryFunFacts.data[country.code] ?? []
        let curatedSet = Set(curated)
        let profileFacts = profile?.funFacts.map(\.text) ?? []
        return curated + profileFacts.filter { !curatedSet.contains($0) }
    }()

    lazy var unescoSites: [UNESCOSite] = (UNESCOData.data[country.code] ?? []).sorted(by: \.yearInscribed)

    lazy var officialLanguages: [LanguageProfile] = LanguageProfiles.official(in: country.code)

    func memberCount(of organization: Organization, among countries: [Country]) -> Int {
        if let memberCounts {
            return memberCounts[organization.id] ?? 0
        }
        let organizationIDs = Set(memberOrganizations.map(\.id))
        var counts: [String: Int] = [:]
        for member in countries {
            for organizationID in Set(member.organizations) where organizationIDs.contains(organizationID) {
                counts[organizationID, default: 0] += 1
            }
        }
        if !countries.isEmpty {
            memberCounts = counts
        }
        return counts[organization.id] ?? 0
    }
}
