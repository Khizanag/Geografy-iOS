import Foundation
import GeografyCore

struct WordSearchPuzzle: Identifiable {
    let id: UUID
    let theme: WordSearchTheme
    let grid: [[Character]]
    let words: [WordSearchWord]
}

struct WordSearchWord: Identifiable {
    let id: UUID
    let word: String
    let startRow: Int
    let startCol: Int
    let direction: WordSearchDirection
    var isFound: Bool
}

enum WordSearchTheme: String, CaseIterable {
    case capitals = "World Capitals"
    case countries = "Country Names"
    case continents = "Continents & Oceans"
    case animals = "National Animals"

    var icon: String {
        switch self {
        case .capitals: "building.columns.fill"
        case .countries: "globe"
        case .continents: "water.waves"
        case .animals: "pawprint.fill"
        }
    }

    var words: [String] {
        switch self {
        case .capitals:
            ["PARIS", "LONDON", "BERLIN", "TOKYO", "CAIRO", "ROME", "OSLO", "LIMA", "BAKU", "RIGA"]
        case .countries:
            ["FRANCE", "JAPAN", "BRAZIL", "INDIA", "CHINA", "SPAIN", "ITALY", "EGYPT", "GHANA", "PERU"]
        case .continents:
            ["AFRICA", "EUROPE", "ASIA", "OCEANIA", "ARCTIC", "ATLANTIC", "PACIFIC", "INDIAN"]
        case .animals:
            ["EAGLE", "LION", "TIGER", "BEAR", "WOLF", "CRANE", "BULL", "DEER", "OWL", "FALCON"]
        }
    }
}

enum WordSearchDirection: CaseIterable {
    case horizontal
    case vertical
    case diagonalDown
    case diagonalUp
    case horizontalReverse
    case verticalReverse
}
