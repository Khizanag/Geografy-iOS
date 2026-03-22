import Foundation

enum Cover: Identifiable {
    case map(continentFilter: String?)
    case quizSession(QuizConfiguration)
    case flashcardSession(deck: FlashcardDeck, cards: [FlashcardItem])
    case dailyChallengeSession
    case multiplayerMatch
    case exploreGameSession
    case travelMap(TravelMapFilter)
    case historicalMap(initialYear: Int)

    var id: String {
        switch self {
        case .map(let filter): "map-\(filter ?? "world")"
        case .quizSession: "quizSession"
        case .flashcardSession: "flashcardSession"
        case .dailyChallengeSession: "dailyChallengeSession"
        case .multiplayerMatch: "multiplayerMatch"
        case .exploreGameSession: "exploreGameSession"
        case .travelMap: "travelMap"
        case .historicalMap(let year): "historicalMap-\(year)"
        }
    }
}
