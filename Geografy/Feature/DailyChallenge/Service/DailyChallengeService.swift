import Foundation
import GeografyCore
import Observation

@Observable
@MainActor
final class DailyChallengeService {
    private(set) var todayChallenge: DailyChallenge?
    private(set) var todayResult: DailyChallengeResult?
    private(set) var streak: Int = 0
    private(set) var history: [DailyChallengeResult] = []

    var hasCompletedToday: Bool { todayResult != nil }

    private let countryDataService: CountryDataService
    private let userID: String

    init(countryDataService: CountryDataService, userID: String) {
        self.countryDataService = countryDataService
        self.userID = userID
    }

    func loadChallenge() {
        countryDataService.loadCountries()
        let today = Date.now
        todayChallenge = generateChallenge(for: today)
        history = loadAllResults()
        todayResult = history.first {
            $0.dateKey == DailyChallengeResult.dateKey()
        }
        computeStreak()
    }

    func saveResult(score: Int, timeSpent: Double) {
        let result = DailyChallengeResult(
            userID: userID,
            dateKey: DailyChallengeResult.dateKey(),
            challengeType: DailyChallengeType.forDate().rawValue,
            score: score,
            timeSpentSeconds: timeSpent
        )

        var allResults = loadAllResults()
        allResults.insert(result, at: 0)
        persistResults(allResults)

        todayResult = result
        history = allResults
        computeStreak()
    }
}

// MARK: - Challenge Generation
private extension DailyChallengeService {
    func generateChallenge(for date: Date) -> DailyChallenge {
        let type = DailyChallengeType.forDate(date)
        let seed = makeSeed(for: date)
        let dateKey = DailyChallengeResult.dateKey(for: date)

        let countries = countryDataService.countries
            .filter { $0.continent != .antarctica }
            .sorted { $0.code < $1.code }
        let shuffled = countries.seededShuffle(seed: seed)

        let content: DailyChallenge.ChallengeContent = switch type {
        case .mysteryCountry:
            .mysteryCountry(generateMysteryCountry(from: shuffled))
        case .flagSequence:
            .flagSequence(generateFlagSequence(from: shuffled))
        case .capitalChain:
            .capitalChain(generateCapitalChain(from: shuffled, seed: seed))
        }

        return DailyChallenge(
            id: dateKey,
            date: date,
            type: type,
            content: content
        )
    }

    func makeSeed(for date: Date) -> UInt64 {
        let year = Calendar.current.component(.year, from: date)
        let dayOfYear = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: date
        ) ?? 1
        return UInt64(year) &* 2_654_435_761 &+ UInt64(dayOfYear) &* 40_503
    }

    func generateMysteryCountry(
        from shuffled: [Country]
    ) -> DailyChallenge.MysteryCountryContent {
        let target = shuffled[0]
        let clues = buildClues(for: target)
        return DailyChallenge.MysteryCountryContent(
            targetCountry: target,
            clues: clues
        )
    }

    func buildClues(
        for country: Country
    ) -> [DailyChallenge.MysteryClue] {
        let neighborNames = ClueGenerator.borderCountryNames(
            for: country.code
        )
        let neighborsValue = neighborNames.isEmpty
            ? "Island nation"
            : neighborNames.joined(separator: ", ")

        return [
            DailyChallenge.MysteryClue(
                id: 0,
                label: "Continent",
                value: country.continent.displayName,
                iconName: "globe",
                pointCost: 0
            ),
            DailyChallenge.MysteryClue(
                id: 1,
                label: "Population",
                value: populationRange(for: country.population),
                iconName: "person.3",
                pointCost: 200
            ),
            DailyChallenge.MysteryClue(
                id: 2,
                label: "Capital Hint",
                value: capitalHint(for: country.capital),
                iconName: "building.columns",
                pointCost: 200
            ),
            DailyChallenge.MysteryClue(
                id: 3,
                label: "Flag",
                value: country.code,
                iconName: "flag.fill",
                pointCost: 200
            ),
            DailyChallenge.MysteryClue(
                id: 4,
                label: "Neighbors",
                value: neighborsValue,
                iconName: "map.fill",
                pointCost: 200
            ),
        ]
    }

    func populationRange(for population: Int) -> String {
        switch population {
        case ..<100_000: "Under 100K"
        case ..<1_000_000: "100K – 1M"
        case ..<10_000_000: "1M – 10M"
        case ..<50_000_000: "10M – 50M"
        case ..<100_000_000: "50M – 100M"
        default: "Over 100M"
        }
    }

    func capitalHint(for capital: String) -> String {
        guard !capital.isEmpty else { return "Unknown" }
        let firstLetter = String(capital.prefix(1))
        let length = capital.count
        return "Starts with '\(firstLetter)', \(length) letters"
    }

    func generateFlagSequence(
        from shuffled: [Country]
    ) -> DailyChallenge.FlagSequenceContent {
        let selected = Array(shuffled.prefix(5))
        return DailyChallenge.FlagSequenceContent(countries: selected)
    }

    func generateCapitalChain(
        from shuffled: [Country],
        seed: UInt64
    ) -> DailyChallenge.CapitalChainContent {
        let starter = shuffled[0]
        var usedContinents: Set<Country.Continent> = [starter.continent]
        var chainSteps: [DailyChallenge.ChainStep] = []

        let remaining = shuffled.filter { $0.code != starter.code }
        var stepIndex = 0

        for continent in Country.Continent.allCases
            where !usedContinents.contains(continent) {
            guard continent != .antarctica else { continue }
            let candidates = remaining.filter { $0.continent == continent }
            guard !candidates.isEmpty else { continue }

            let target = candidates[0]
            let distractors = remaining
                .filter {
                    $0.continent == continent && $0.code != target.code
                }
                .prefix(3)

            var options = [target] + Array(distractors)
            options = options.seededShuffle(
                seed: seed &+ UInt64(stepIndex) &* 7919
            )

            chainSteps.append(DailyChallenge.ChainStep(
                id: stepIndex,
                continent: continent,
                expectedCountry: target,
                options: options
            ))

            usedContinents.insert(continent)
            stepIndex += 1

            if chainSteps.count >= 4 { break }
        }

        return DailyChallenge.CapitalChainContent(
            startingCapital: starter.capital,
            startingCountry: starter,
            chainSteps: chainSteps
        )
    }
}

// MARK: - File-Based Persistence
private extension DailyChallengeService {
    var storageURL: URL {
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return directory.appendingPathComponent(
            "daily_challenge_results.json"
        )
    }

    func loadAllResults() -> [DailyChallengeResult] {
        guard let data = try? Data(contentsOf: storageURL) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(
            [DailyChallengeResult].self,
            from: data
        )) ?? []
    }

    func persistResults(_ results: [DailyChallengeResult]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(results) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }

    func computeStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let sortedDates = history
            .compactMap { dateFromKey($0.dateKey) }
            .sorted(by: >)

        guard let first = sortedDates.first,
              calendar.isDate(first, inSameDayAs: today) ||
              calendar.isDate(
                  first,
                  inSameDayAs: calendar.date(
                      byAdding: .day,
                      value: -1,
                      to: today
                  )!
              )
        else {
            streak = 0
            return
        }

        var count = 1
        for index in 1..<sortedDates.count {
            let expected = calendar.date(
                byAdding: .day,
                value: -1,
                to: sortedDates[index - 1]
            )!
            if calendar.isDate(sortedDates[index], inSameDayAs: expected) {
                count += 1
            } else {
                break
            }
        }
        streak = count
    }

    func dateFromKey(_ key: String) -> Date? {
        let parts = key.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2])
        else { return nil }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }
}
