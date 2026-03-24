import SwiftUI

enum Destination: Hashable {
    case countryDetail(Country)
    case organizationDetail(Organization)
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
