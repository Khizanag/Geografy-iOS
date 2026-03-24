import SwiftUI

enum CoverFactory {
    @ViewBuilder
    static func view(for cover: Cover) -> some View {
        switch cover {
        case .map(let continentFilter):
            NavigatorView(canBeDismissed: false) {
                MapScreen(continentFilter: continentFilter)
            }

        case .quizSession(let configuration):
            QuizSessionScreen(configuration: configuration)

        case .flashcardSession(let deck, let cards):
            FlashcardSessionScreen(deck: deck, cards: cards)

        case .dailyChallengeSession:
            EmptyView()

        case .multiplayerMatch:
            EmptyView()

        case .exploreGameSession:
            EmptyView()

        case .travelMap(let filter):
            TravelMapScreen(filter: filter)

        case .historicalMap(let initialYear):
            HistoricalMapScreen(initialYear: initialYear)

        case .speedRunSession(let region):
            SpeedRunSessionScreen(region: region)
        }
    }
}
