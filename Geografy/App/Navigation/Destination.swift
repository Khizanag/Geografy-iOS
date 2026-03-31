import SwiftUI
import GeografyCore

enum Destination: Hashable {
    case countryDetail(Country)
    case organizationDetail(Organization)
    case continentOverview(Country.Continent)
    case challengeResult(ChallengeRoom)
    case dailyChallengeResult(score: Int, maxScore: Int, challengeType: DailyChallengeType, timeSpent: TimeInterval, streak: Int)
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

        case .continentOverview(let continent):
            ContinentOverviewScreen(continent: continent)

        case .challengeResult(let room):
            ChallengeResultScreen(room: room, onPlayAgain: nil)

        case .dailyChallengeResult(let score, let maxScore, let challengeType, let timeSpent, let streak):
            DailyChallengeResultView(
                score: score,
                maxScore: maxScore,
                challengeType: challengeType,
                timeSpent: timeSpent,
                streak: streak
            )
        }
    }
}
