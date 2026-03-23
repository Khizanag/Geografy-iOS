import Foundation

enum QuizDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case medium
    case hard

    var id: String { rawValue }
}

// MARK: - Properties

extension QuizDifficulty {
    var displayName: String {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }

    var subtitle: String {
        subtitle(for: .multipleChoice)
    }

    func subtitle(for answerMode: QuizAnswerMode) -> String {
        let modeLabel = answerMode == .typing ? "Type answer" : "4 options"
        return switch self {
        case .easy: "No timer · \(modeLabel)"
        case .medium: "15s timer · \(modeLabel)"
        case .hard: "8s timer · \(modeLabel)"
        }
    }

    var icon: String {
        switch self {
        case .easy: "tortoise.fill"
        case .medium: "hare.fill"
        case .hard: "bolt.fill"
        }
    }

    var optionCount: Int {
        switch self {
        case .easy: 4
        case .medium: 4
        case .hard: 0
        }
    }

    var hasTimer: Bool {
        switch self {
        case .easy: false
        case .medium, .hard: true
        }
    }

    var timerDuration: TimeInterval {
        switch self {
        case .easy: 0
        case .medium: 15
        case .hard: 8
        }
    }
}
