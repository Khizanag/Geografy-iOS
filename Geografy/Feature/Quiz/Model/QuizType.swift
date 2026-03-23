import Foundation

enum QuizType: String, CaseIterable, Identifiable, Codable {
    case flagQuiz
    case capitalQuiz
    case reverseFlag
    case reverseCapital
    case populationOrder
    case areaOrder

    var id: String { rawValue }
}

// MARK: - Display

private extension QuizType {
    static let displayNames: [QuizType: String] = [
        .flagQuiz: "Flag Quiz",
        .capitalQuiz: "Capital Quiz",
        .reverseFlag: "Reverse Flag",
        .reverseCapital: "Reverse Capital",
        .populationOrder: "Population Order",
        .areaOrder: "Area Order",
    ]

    static let icons: [QuizType: String] = [
        .flagQuiz: "flag.fill",
        .capitalQuiz: "building.columns.fill",
        .reverseFlag: "flag.2.crossed.fill",
        .reverseCapital: "building.2.fill",
        .populationOrder: "person.3.fill",
        .areaOrder: "map.fill",
    ]

    static let emojis: [QuizType: String] = [
        .flagQuiz: "🚩",
        .capitalQuiz: "🏛️",
        .reverseFlag: "🏴",
        .reverseCapital: "🏙️",
        .populationOrder: "👥",
        .areaOrder: "🗺️",
    ]

    static let descriptions: [QuizType: String] = [
        .flagQuiz: "Identify the country by its flag",
        .capitalQuiz: "Guess the capital of a given country",
        .reverseFlag: "Pick the correct flag for a country",
        .reverseCapital: "Identify the country by its capital",
        .populationOrder: "Identify the country with the largest or smallest population",
        .areaOrder: "Identify the country with the largest or smallest area",
    ]
}

// MARK: - Computed Properties

extension QuizType: SelectableType {
    var displayName: String {
        Self.displayNames[self] ?? rawValue
    }

    var icon: String {
        Self.icons[self] ?? "questionmark.circle"
    }

    var emoji: String {
        Self.emojis[self] ?? "❓"
    }

    var description: String {
        Self.descriptions[self] ?? ""
    }

    var isPremium: Bool {
        switch self {
        case .reverseFlag, .reverseCapital, .populationOrder: true
        default: false
        }
    }

    var supportsTypingMode: Bool {
        self != .reverseFlag
    }
}
