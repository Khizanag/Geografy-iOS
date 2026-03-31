import Foundation
import GeografyCore

/// Manages Explore Game sessions: daily game selection and practice mode.
@Observable
final class ExploreGameService {
    private(set) var statistics = Statistics()

    private let countryDataService: CountryDataService

    init(countryDataService: CountryDataService = CountryDataService()) {
        self.countryDataService = countryDataService
        countryDataService.loadCountries()
        loadStatistics()
    }
}

// MARK: - Statistics
extension ExploreGameService {
    struct Statistics: Codable {
        var gamesPlayed: Int = 0
        var totalScore: Int = 0
        var bestStreak: Int = 0
        var currentStreak: Int = 0

        var averageScore: Double {
            guard gamesPlayed > 0 else { return 0 }
            return Double(totalScore) / Double(gamesPlayed)
        }
    }
}

// MARK: - Game Creation
extension ExploreGameService {
    func makeDailyGame() -> ExploreGameState? {
        let countries = countryDataService.countries
        guard !countries.isEmpty else { return nil }

        let today = Calendar.current.startOfDay(for: Date())
        let seed = UInt64(today.timeIntervalSince1970)
        let shuffled = countries.seededShuffle(seed: seed)

        guard let country = shuffled.first else { return nil }
        let clues = ClueGenerator.generateClues(for: country)

        return ExploreGameState(
            targetCountry: country,
            clues: clues
        )
    }

    func makePracticeGame() -> ExploreGameState? {
        let countries = countryDataService.countries
        guard !countries.isEmpty else { return nil }

        let country = countries.randomElement()!
        let clues = ClueGenerator.generateClues(for: country)

        return ExploreGameState(
            targetCountry: country,
            clues: clues
        )
    }
}

// MARK: - Country Search
extension ExploreGameService {
    func searchCountries(query: String) -> [Country] {
        guard !query.isEmpty else { return [] }

        let lowered = query.lowercased()
        return countryDataService.countries
            .filter { $0.name.lowercased().contains(lowered) }
            .sorted { lhs, rhs in
                let lhsStarts = lhs.name.lowercased()
                    .hasPrefix(lowered)
                let rhsStarts = rhs.name.lowercased()
                    .hasPrefix(lowered)
                if lhsStarts != rhsStarts {
                    return lhsStarts
                }
                return lhs.name < rhs.name
            }
    }
}

// MARK: - Statistics Management
extension ExploreGameService {
    func recordResult(_ result: ExploreGameResult) {
        statistics.gamesPlayed += 1
        statistics.totalScore += result.score

        if result.score > 0 {
            statistics.currentStreak += 1
            statistics.bestStreak = max(
                statistics.bestStreak,
                statistics.currentStreak
            )
        } else {
            statistics.currentStreak = 0
        }

        saveStatistics()
    }
}

// MARK: - Persistence
private extension ExploreGameService {
    static let statisticsKey = "ExploreGameStatistics"

    func loadStatistics() {
        guard let data = UserDefaults.standard.data(
            forKey: Self.statisticsKey
        ) else {
            return
        }
        if let decoded = try? JSONDecoder().decode(
            Statistics.self,
            from: data
        ) {
            statistics = decoded
        }
    }

    func saveStatistics() {
        if let data = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(
                data,
                forKey: Self.statisticsKey
            )
        }
    }
}
