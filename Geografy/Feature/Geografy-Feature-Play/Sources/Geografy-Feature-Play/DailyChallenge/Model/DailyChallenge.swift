import Foundation
import Geografy_Core_Common

/// Represents a single daily challenge instance with its content and date.
public struct DailyChallenge: Identifiable {
    public let id: String
    public let date: Date
    public let type: DailyChallengeType
    public let content: ChallengeContent

    /// Deterministic seed based on year and day-of-year.
    public var seed: UInt64 {
        let year = Calendar.current.component(.year, from: date)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return UInt64(year) &* 2_654_435_761 &+ UInt64(dayOfYear) &* 40_503
    }
}

// MARK: - Challenge Content
extension DailyChallenge {
    public enum ChallengeContent {
        case mysteryCountry(MysteryCountryContent)
        case flagSequence(FlagSequenceContent)
        case capitalChain(CapitalChainContent)
    }

    public struct MysteryCountryContent {
        public let targetCountry: Country
        public let clues: [MysteryClue]
    }

    public struct FlagSequenceContent {
        public let countries: [Country]
    }

    public struct CapitalChainContent {
        public let startingCapital: String
        public let startingCountry: Country
        public let chainSteps: [ChainStep]
    }
}

// MARK: - Mystery Clue
extension DailyChallenge {
    public struct MysteryClue: Identifiable {
        public let id: Int
        public let label: String
        public let value: String
        public let iconName: String
        public let pointCost: Int
    }
}

// MARK: - Chain Step
extension DailyChallenge {
    public struct ChainStep: Identifiable {
        public let id: Int
        public let continent: Country.Continent
        public let expectedCountry: Country
        public let options: [Country]
    }
}
