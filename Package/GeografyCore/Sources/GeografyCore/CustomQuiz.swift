import Foundation

public struct CustomQuiz: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var icon: String
    public var countryCodes: [String]
    public var questionTypes: [QuizType]
    public var difficulty: QuizDifficulty
    public let createdAt: Date

    public init(
        id: UUID,
        name: String,
        icon: String,
        countryCodes: [String],
        questionTypes: [QuizType],
        difficulty: QuizDifficulty,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.countryCodes = countryCodes
        self.questionTypes = questionTypes
        self.difficulty = difficulty
        self.createdAt = createdAt
    }

    public static func makeNew(
        name: String,
        icon: String,
        countryCodes: [String],
        questionTypes: [QuizType],
        difficulty: QuizDifficulty
    ) -> Self {
        Self(
            id: UUID(),
            name: name,
            icon: icon,
            countryCodes: countryCodes,
            questionTypes: questionTypes,
            difficulty: difficulty,
            createdAt: Date(),
        )
    }
}

// MARK: - Shareable
public extension CustomQuiz {
    var shareableJSON: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

// MARK: - Available Icons
public extension CustomQuiz {
    static let availableIcons: [String] = [
        "globe.americas.fill",
        "globe.europe.africa.fill",
        "globe.asia.australia.fill",
        "map.fill",
        "flag.fill",
        "star.fill",
        "heart.fill",
        "bolt.fill",
        "flame.fill",
        "trophy.fill",
        "graduationcap.fill",
        "book.fill",
    ]
}
