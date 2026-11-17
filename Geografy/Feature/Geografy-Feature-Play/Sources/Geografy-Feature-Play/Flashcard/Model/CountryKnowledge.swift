import Geografy_Core_DesignSystem
import SwiftUI

/// How well someone knows a country, from their best flashcard for it across every game that asks about it.
public enum CountryKnowledge: Int, CaseIterable, Comparable, Sendable {
    case unseen
    case learning
    case familiar
    case known

    /// Right answers in a row, on its best card, that each level needs.
    static let familiarStreak = 2
    static let knownStreak = 4

    init(repetitions: Int?) {
        guard let repetitions else {
            self = .unseen
            return
        }
        switch repetitions {
        case Self.knownStreak...: self = .known
        case Self.familiarStreak...: self = .familiar
        default: self = .learning
        }
    }

    public static func < (lhs: CountryKnowledge, rhs: CountryKnowledge) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var title: LocalizedStringKey {
        switch self {
        case .unseen: "Not Seen"
        case .learning: "Learning"
        case .familiar: "Familiar"
        case .known: "Mastered"
        }
    }

    public var color: Color {
        switch self {
        case .unseen: DesignSystem.Color.textTertiary.opacity(DesignSystem.Opacity.soft)
        case .learning: DesignSystem.Color.orange
        case .familiar: DesignSystem.Color.blue
        case .known: DesignSystem.Color.success
        }
    }
}
