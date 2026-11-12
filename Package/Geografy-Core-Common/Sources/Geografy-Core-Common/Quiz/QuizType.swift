import Foundation

public enum QuizType: String, CaseIterable, Identifiable, Codable, Sendable {
    case flagQuiz
    case capitalQuiz
    case reverseFlag
    case reverseCapital
    case worldRankings
    case nationalSymbols
    case landmarks
    case nicknames
    case trueOrFalse
    case neighbors
    case mysteryCountry

    public var id: String { rawValue }
}

// MARK: - Display
private extension QuizType {
    static let displayNames: [QuizType: String] = [
        .flagQuiz: "Flag Quiz",
        .capitalQuiz: "Capital Quiz",
        .reverseFlag: "Reverse Flag",
        .reverseCapital: "Reverse Capital",
        .worldRankings: "World Rankings",
        .nationalSymbols: "National Symbols",
        .landmarks: "Landmarks",
        .nicknames: "Nicknames",
        .trueOrFalse: "True or False",
        .neighbors: "Neighbors",
        .mysteryCountry: "Mystery Country",
    ]

    static let icons: [QuizType: String] = [
        .flagQuiz: "flag.fill",
        .capitalQuiz: "building.columns.fill",
        .reverseFlag: "flag.2.crossed.fill",
        .reverseCapital: "building.2.fill",
        .worldRankings: "chart.bar.fill",
        .nationalSymbols: "leaf.fill",
        .landmarks: "photo.fill",
        .nicknames: "tag.fill",
        .trueOrFalse: "questionmark.bubble.fill",
        .neighbors: "square.dashed",
        .mysteryCountry: "magnifyingglass",
    ]

    static let emojis: [QuizType: String] = [
        .flagQuiz: "🚩",
        .capitalQuiz: "🏛️",
        .reverseFlag: "🏴",
        .reverseCapital: "🏙️",
        .worldRankings: "📊",
        .nationalSymbols: "🦅",
        .landmarks: "🗽",
        .nicknames: "🏷️",
        .trueOrFalse: "✅",
        .neighbors: "🧭",
        .mysteryCountry: "🔍",
    ]

    static let descriptions: [QuizType: String] = [
        .flagQuiz: "Identify the country by its flag",
        .capitalQuiz: "Guess the capital of a given country",
        .reverseFlag: "Pick the correct flag for a country",
        .reverseCapital: "Identify the country by its capital",
        .worldRankings: "Pick the biggest or smallest by metric",
        .nationalSymbols: "Animals, flowers, sports & mottos of nations",
        .landmarks: "Name the country behind a famous landmark",
        .nicknames: "Match informal nicknames to countries",
        .trueOrFalse: "Decide whether a geography statement is true",
        .neighbors: "Pick the country that shares a border",
        .mysteryCountry: "Name the country from a set of clues",
    ]
}

// MARK: - Computed Properties
extension QuizType: SelectableType {
    public var displayName: String {
        Self.displayNames[self] ?? rawValue
    }

    public var icon: String {
        Self.icons[self] ?? "questionmark.circle"
    }

    public var emoji: String {
        Self.emojis[self] ?? "❓"
    }

    public var description: String {
        Self.descriptions[self] ?? ""
    }

    public var supportedAnswerModes: [QuizAnswerMode] {
        switch self {
        case .flagQuiz, .capitalQuiz, .reverseCapital:
            [.multipleChoice, .typing, .spellingBee]
        case .reverseFlag, .nationalSymbols, .worldRankings, .landmarks, .nicknames, .trueOrFalse, .neighbors,
             .mysteryCountry:
            [.multipleChoice]
        }
    }

    public var supportsTypingMode: Bool {
        supportedAnswerModes.contains(.typing)
    }

    public var hasComparisonMetric: Bool {
        self == .worldRankings
    }
}
