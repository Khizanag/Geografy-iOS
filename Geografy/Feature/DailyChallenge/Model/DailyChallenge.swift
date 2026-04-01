import Foundation
import Geografy_Core_Common

/// Represents a single daily challenge instance with its content and date.
struct DailyChallenge: Identifiable {
    let id: String
    let date: Date
    let type: DailyChallengeType
    let content: ChallengeContent

    /// Deterministic seed based on year and day-of-year.
    var seed: UInt64 {
        let year = Calendar.current.component(.year, from: date)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return UInt64(year) &* 2_654_435_761 &+ UInt64(dayOfYear) &* 40_503
    }
}

// MARK: - Challenge Content
extension DailyChallenge {
    enum ChallengeContent {
        case mysteryCountry(MysteryCountryContent)
        case flagSequence(FlagSequenceContent)
        case capitalChain(CapitalChainContent)
    }

    struct MysteryCountryContent {
        let targetCountry: Country
        let clues: [MysteryClue]
    }

    struct FlagSequenceContent {
        let countries: [Country]
    }

    struct CapitalChainContent {
        let startingCapital: String
        let startingCountry: Country
        let chainSteps: [ChainStep]
    }
}

// MARK: - Mystery Clue
extension DailyChallenge {
    struct MysteryClue: Identifiable {
        let id: Int
        let label: String
        let value: String
        let iconName: String
        let pointCost: Int
    }
}

// MARK: - Chain Step
extension DailyChallenge {
    struct ChainStep: Identifiable {
        let id: Int
        let continent: Country.Continent
        let expectedCountry: Country
        let options: [Country]
    }
}
