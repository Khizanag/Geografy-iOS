import Geografy_Core_DesignSystem
import SwiftUI

public enum FlashcardReviewResult: String, CaseIterable, Identifiable {
    case again
    case hard
    case good
    case easy

    public var id: String { rawValue }
}

// MARK: - Display
extension FlashcardReviewResult {
    public var displayName: String {
        switch self {
        case .again: "Wrong"
        case .hard: "Struggled"
        case .good: "Correct"
        case .easy: "Knew It"
        }
    }

    public var icon: String {
        switch self {
        case .again: "xmark.circle.fill"
        case .hard: "exclamationmark.triangle.fill"
        case .good: "checkmark.circle.fill"
        case .easy: "bolt.circle.fill"
        }
    }

    public var color: Color {
        switch self {
        case .again: DesignSystem.Color.error
        case .hard: DesignSystem.Color.warning
        case .good: DesignSystem.Color.success
        case .easy: DesignSystem.Color.accent
        }
    }

    public var quality: Int {
        switch self {
        case .again: 1
        case .hard: 2
        case .good: 4
        case .easy: 5
        }
    }
}
