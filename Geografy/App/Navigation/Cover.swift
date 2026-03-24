import Foundation

enum Cover: Identifiable {
    case map(continentFilter: String?)
    case quizSession(QuizConfiguration)
    case flashcardSession(deck: FlashcardDeck, cards: [FlashcardItem])
    case travelMap(TravelMapFilter)
    case historicalMap(initialYear: Int)
    case speedRunSession(region: QuizRegion)

    var id: String {
        switch self {
        case .map(let filter): "map-\(filter ?? "world")"
        case .quizSession: "quizSession"
        case .flashcardSession: "flashcardSession"
        case .travelMap: "travelMap"
        case .historicalMap(let year): "historicalMap-\(String(year))"
        case .speedRunSession(let region): "speedRunSession-\(region.rawValue)"
        }
    }
}
