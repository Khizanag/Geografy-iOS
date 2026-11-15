import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public enum QuizPackCategory: String, CaseIterable, Identifiable {
    case capitals
    case flags
    case population
    case geography
    case currency
    case government
    case organizations

    public var id: String { rawValue }
}

// MARK: - Display
extension QuizPackCategory {
    public var displayName: String {
        switch self {
        case .capitals: "Capitals"
        case .flags: "Flags"
        case .population: "Population"
        case .geography: "Geography"
        case .currency: "Currency"
        case .government: "Government"
        case .organizations: "Organizations"
        }
    }

    public var icon: String {
        switch self {
        case .capitals: "building.columns.fill"
        case .flags: "flag.fill"
        case .population: "person.3.fill"
        case .geography: "map.fill"
        case .currency: "banknote.fill"
        case .government: "scroll.fill"
        case .organizations: "globe"
        }
    }

    public var quizType: QuizType {
        switch self {
        case .capitals: .capitalQuiz
        case .flags: .flagQuiz
        case .population: .worldRankings
        case .geography: .worldRankings
        case .currency: .capitalQuiz
        case .government: .capitalQuiz
        case .organizations: .capitalQuiz
        }
    }

    /// The category's color from the design system, so packs read in the same palette as the rest of the app.
    public var color: Color {
        switch self {
        case .capitals: DesignSystem.Color.indigo
        case .flags: DesignSystem.Color.error
        case .population: DesignSystem.Color.blue
        case .geography: DesignSystem.Color.accent
        case .currency: DesignSystem.Color.orange
        case .government: DesignSystem.Color.purple
        case .organizations: DesignSystem.Color.warning
        }
    }
}
