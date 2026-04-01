import Foundation

/// The three rotating challenge types. The day-of-year modulo 3 picks which type to show.
public enum DailyChallengeType: String, CaseIterable, Codable, Sendable {
    case mysteryCountry
    case flagSequence
    case capitalChain

    public var title: String {
        switch self {
        case .mysteryCountry: "Mystery Country"
        case .flagSequence: "Flag Sequence"
        case .capitalChain: "Capital Chain"
        }
    }

    public var subtitle: String {
        switch self {
        case .mysteryCountry: "Guess the country from progressive clues"
        case .flagSequence: "Identify 5 flags as fast as you can"
        case .capitalChain: "Chain capitals across continents"
        }
    }

    public var iconName: String {
        switch self {
        case .mysteryCountry: "magnifyingglass"
        case .flagSequence: "flag.2.crossed"
        case .capitalChain: "link"
        }
    }

    /// Determine today's challenge type using the day-of-year index.
    public static func forDate(_ date: Date = .now) -> DailyChallengeType {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let allCases = DailyChallengeType.allCases
        return allCases[(dayOfYear - 1) % allCases.count]
    }
}
