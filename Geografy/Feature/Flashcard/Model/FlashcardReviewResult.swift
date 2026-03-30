import SwiftUI

enum FlashcardReviewResult: String, CaseIterable, Identifiable {
    case again
    case hard
    case good
    case easy

    var id: String { rawValue }
}

// MARK: - Display
extension FlashcardReviewResult {
    var displayName: String {
        switch self {
        case .again: "Wrong"
        case .hard: "Struggled"
        case .good: "Correct"
        case .easy: "Knew It"
        }
    }

    var icon: String {
        switch self {
        case .again: "xmark.circle.fill"
        case .hard: "exclamationmark.triangle.fill"
        case .good: "checkmark.circle.fill"
        case .easy: "bolt.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .again: DesignSystem.Color.error
        case .hard: DesignSystem.Color.warning
        case .good: DesignSystem.Color.success
        case .easy: DesignSystem.Color.accent
        }
    }

    var quality: Int {
        switch self {
        case .again: 1
        case .hard: 2
        case .good: 4
        case .easy: 5
        }
    }
}
