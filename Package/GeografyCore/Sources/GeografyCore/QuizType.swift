import Foundation

public enum QuizType: String, CaseIterable, Identifiable, Codable, Sendable {
    case flagQuiz
    case capitalQuiz
    case reverseFlag
    case reverseCapital
    case worldRankings
    case nationalSymbols

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
    ]

    static let icons: [QuizType: String] = [
        .flagQuiz: "flag.fill",
        .capitalQuiz: "building.columns.fill",
        .reverseFlag: "flag.2.crossed.fill",
        .reverseCapital: "building.2.fill",
        .worldRankings: "chart.bar.fill",
        .nationalSymbols: "leaf.fill",
    ]

    static let emojis: [QuizType: String] = [
        .flagQuiz: "🚩",
        .capitalQuiz: "🏛️",
        .reverseFlag: "🏴",
        .reverseCapital: "🏙️",
        .worldRankings: "📊",
        .nationalSymbols: "🦅",
    ]

    static let descriptions: [QuizType: String] = [
        .flagQuiz: "Identify the country by its flag",
        .capitalQuiz: "Guess the capital of a given country",
        .reverseFlag: "Pick the correct flag for a country",
        .reverseCapital: "Identify the country by its capital",
        .worldRankings: "Pick the biggest or smallest by metric",
        .nationalSymbols: "Animals, flowers, sports & mottos of nations",
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

    public var isPremium: Bool {
        switch self {
        case .reverseFlag, .reverseCapital: true
        default: false
        }
    }

    public var supportedAnswerModes: [QuizAnswerMode] {
        switch self {
        case .flagQuiz, .capitalQuiz, .reverseCapital:
            [.multipleChoice, .typing, .spellingBee]
        case .reverseFlag, .nationalSymbols, .worldRankings:
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
