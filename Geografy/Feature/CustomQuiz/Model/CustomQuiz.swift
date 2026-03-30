import Foundation

struct CustomQuiz: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var countryCodes: [String]
    var questionTypes: [QuizType]
    var difficulty: QuizDifficulty
    let createdAt: Date

    static func makeNew(
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
extension CustomQuiz {
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
extension CustomQuiz {
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
