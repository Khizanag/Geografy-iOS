import Foundation

enum QuizDifficulty: String, CaseIterable, Identifiable {
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
        switch self {
        case .easy: "No timer · 4 options"
        case .medium: "15s timer · 4 options"
        case .hard: "8s timer · 4 options"
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
