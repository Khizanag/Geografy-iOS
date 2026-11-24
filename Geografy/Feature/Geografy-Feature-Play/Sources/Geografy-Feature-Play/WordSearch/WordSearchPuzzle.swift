import Foundation
import Geografy_Core_Common

public struct WordSearchPuzzle: Identifiable, Codable, Sendable {
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

// MARK: - Codable
/// Sent to the other phone in a multiplayer match; each row of letters travels as one string.
extension WordSearchPuzzle {
    private enum CodingKeys: String, CodingKey {
        case id
        case theme
        case rows
        case words
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        theme = try container.decode(WordSearchTheme.self, forKey: .theme)
        grid = try container.decode([String].self, forKey: .rows).map(Array.init)
        words = try container.decode([WordSearchWord].self, forKey: .words)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(theme, forKey: .theme)
        try container.encode(grid.map { String($0) }, forKey: .rows)
        try container.encode(words, forKey: .words)
    }
}

public struct WordSearchWord: Identifiable, Codable, Sendable {
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

public enum WordSearchTheme: String, CaseIterable, Codable, Identifiable, Sendable {
    public var id: String { rawValue }

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

public enum WordSearchDirection: String, CaseIterable, Codable, Sendable {
    case horizontal
    case vertical
    case diagonalDown
    case diagonalUp
    case horizontalReverse
    case verticalReverse
}
