import Geografy_Core_Common

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

    public var emoji: String {
        switch self {
        case .capitals: "🏛️"
        case .flags: "🚩"
        case .population: "👥"
        case .geography: "🗺️"
        case .currency: "💰"
        case .government: "⚖️"
        case .organizations: "🌐"
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

    public var gradientHex: (String, String) {
        switch self {
        case .capitals: ("1A237E", "3949AB")
        case .flags: ("B71C1C", "D32F2F")
        case .population: ("004D40", "00695C")
        case .geography: ("1B5E20", "388E3C")
        case .currency: ("E65100", "FF8F00")
        case .government: ("4A148C", "7B1FA2")
        case .organizations: ("01579B", "0277BD")
        }
    }
}
