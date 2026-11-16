import Geografy_Core_Common

/// Which countries belong to which organization, worked out in one pass over the countries.
enum OrganizationMembership {
    static func memberCounts(in countries: [Country]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for country in countries {
            for organizationID in Set(country.organizations) {
                counts[organizationID, default: 0] += 1
            }
        }
        return counts
    }

    static func members(of organizationID: String, in countries: [Country]) -> [Country] {
        countries
            .filter { $0.organizations.contains(organizationID) }
            .sorted(by: \.name)
    }
}
