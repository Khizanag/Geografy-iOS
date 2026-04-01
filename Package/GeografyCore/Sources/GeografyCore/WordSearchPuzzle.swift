import Foundation

public struct WordSearchPuzzle: Identifiable, Sendable {
    public let id: UUID
    public let theme: WordSearchTheme
    public let grid: [[Character]]
    public let words: [WordSearchWord]

    public init(
        id: UUID,
        theme: WordSearchTheme,
        grid: [[Character]],
        words: [WordSearchWord]
    ) {
        self.id = id
        self.theme = theme
        self.grid = grid
        self.words = words
    }
}

public struct WordSearchWord: Identifiable, Sendable {
    public let id: UUID
    public let word: String
    public let startRow: Int
    public let startCol: Int
    public let direction: WordSearchDirection
    public var isFound: Bool

    public init(
        id: UUID,
        word: String,
        startRow: Int,
        startCol: Int,
        direction: WordSearchDirection,
        isFound: Bool
    ) {
        self.id = id
        self.word = word
        self.startRow = startRow
        self.startCol = startCol
        self.direction = direction
        self.isFound = isFound
    }
}

public enum WordSearchTheme: String, CaseIterable, Sendable {
    case capitals = "World Capitals"
    case countries = "Country Names"
    case continents = "Continents & Oceans"
    case animals = "National Animals"

    public var icon: String {
        switch self {
        case .capitals: "building.columns.fill"
        case .countries: "globe"
        case .continents: "water.waves"
        case .animals: "pawprint.fill"
        }
    }

    public var words: [String] {
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

public enum WordSearchDirection: CaseIterable, Sendable {
    case horizontal
    case vertical
    case diagonalDown
    case diagonalUp
    case horizontalReverse
    case verticalReverse
}
