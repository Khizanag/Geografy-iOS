import SwiftUI

enum Destination: Hashable {
    case countryDetail(Country)
    case organizationDetail(Organization)
    case challengeResult(ChallengeRoom)
}

// MARK: - Content

@MainActor
extension Destination {
    @ViewBuilder
    var content: some View {
        switch self {
        case .countryDetail(let country):
            CountryDetailScreen(country: country)

        case .organizationDetail(let organization):
            OrganizationDetailScreen(organization: organization)

        case .challengeResult(let room):
            ChallengeResultScreen(room: room)
        }
    }
}
