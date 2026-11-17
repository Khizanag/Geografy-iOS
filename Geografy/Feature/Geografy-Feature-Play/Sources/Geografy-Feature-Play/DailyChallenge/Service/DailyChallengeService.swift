import Foundation
import Geografy_Core_Common
import Geografy_Core_Service
import Observation

@Observable
@MainActor
public final class DailyChallengeService {
    public private(set) var todayChallenge: DailyChallenge?
    public private(set) var todayResult: DailyChallengeResult?
    public private(set) var streak: Int = 0
    public private(set) var history: [DailyChallengeResult] = []
    private(set) var streakSummary = DailyChallengeStreak(dateKeys: [String]())
    private(set) var sortedHistory: [DailyChallengeResult] = []

    public var hasCompletedToday: Bool { todayResult != nil }

    public let userID: String

    private let countryDataService: CountryDataService
    @ObservationIgnored private var loadedDateKey: String?
    @ObservationIgnored private var loadedResultIDs: [String] = []

    // Shared by every instance, so screens opened later skip the disk read and the challenge build.
    private static var cachedResults: [DailyChallengeResult]?
    private static var cachedChallenge: DailyChallenge?

    public init(countryDataService: CountryDataService, userID: String) {
        self.countryDataService = countryDataService
        self.userID = userID
    }

    /// `existing` while it still belongs to `userID`, otherwise a new service for them.
    public static func service(
        reusing existing: DailyChallengeService?,
        countryDataService: CountryDataService,
        userID: String
    ) -> DailyChallengeService {
        if let existing, existing.userID == userID {
            return existing
        }
        return DailyChallengeService(countryDataService: countryDataService, userID: userID)
    }

    /// Cheap to call on every appearance: it rebuilds only when the day or the saved results change.
    public func loadChallenge() async {
        await countryDataService.loadCountries()
        let dateKey = DailyChallengeResult.dateKey()
        let allResults = await Self.allResults()
        if todayChallenge?.id != dateKey {
            todayChallenge = challenge(forDateKey: dateKey)
        }
        apply(history: Self.results(for: userID, in: allResults), dateKey: dateKey)
    }

    public func saveResult(score: Int, timeSpent: Double) {
        let result = DailyChallengeResult(
            userID: userID,
            dateKey: DailyChallengeResult.dateKey(),
            challengeType: DailyChallengeType.forDate().rawValue,
            score: score,
            timeSpentSeconds: timeSpent
        )

        var allResults = Self.cachedResults ?? Self.readResults(from: Self.storageURL)
        allResults.insert(result, at: 0)
        Self.persistResults(allResults)

        apply(history: Self.results(for: userID, in: allResults), dateKey: result.dateKey)
    }

    /// One file holds every account's results on this device, so history and streaks keep only the signed-in user's.
    nonisolated static func results(for userID: String, in results: [DailyChallengeResult]) -> [DailyChallengeResult] {
        results.filter { $0.userID == userID }
    }

    nonisolated static func newestFirst(_ results: [DailyChallengeResult]) -> [DailyChallengeResult] {
        results.sorted { lhs, rhs in
            lhs.dateKey == rhs.dateKey ? lhs.completedAt > rhs.completedAt : lhs.dateKey > rhs.dateKey
        }
    }
}

// MARK: - State
private extension DailyChallengeService {
    /// Nil while the countries haven't loaded, so an empty challenge is never kept for the day.
    func challenge(forDateKey dateKey: String) -> DailyChallenge? {
        if let cached = Self.cachedChallenge, cached.id == dateKey {
            return cached
        }
        let challenge = generateChallenge(for: .now)
        Self.cachedChallenge = challenge
        return challenge
    }

    func apply(history newHistory: [DailyChallengeResult], dateKey: String) {
        let resultIDs = newHistory.map(\.id)
        guard resultIDs != loadedResultIDs || dateKey != loadedDateKey else { return }
        loadedResultIDs = resultIDs
        loadedDateKey = dateKey

        let summary = DailyChallengeStreak(dateKeys: newHistory.map(\.dateKey))
        history = newHistory
        todayResult = newHistory.first { $0.dateKey == dateKey }
        streakSummary = summary
        streak = summary.current
        sortedHistory = Self.newestFirst(newHistory)
    }
}

// MARK: - Challenge Generation
private extension DailyChallengeService {
    func generateChallenge(for date: Date) -> DailyChallenge? {
        let type = DailyChallengeType.forDate(date)
        let seed = makeSeed(for: date)
        let dateKey = DailyChallengeResult.dateKey(for: date)

        let countries = countryDataService.countries
            .filter { $0.continent != .antarctica }
            .sorted(by: \.code)
        let shuffled = countries.seededShuffle(seed: seed)
        guard let first = shuffled.first else { return nil }

        let content: DailyChallenge.ChallengeContent = switch type {
        case .mysteryCountry:
            .mysteryCountry(generateMysteryCountry(target: first, in: shuffled))
        case .flagSequence:
            .flagSequence(generateFlagSequence(from: shuffled))
        case .capitalChain:
            .capitalChain(generateCapitalChain(starter: first, from: shuffled, seed: seed))
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
        target: Country,
        in shuffled: [Country]
    ) -> DailyChallenge.MysteryCountryContent {
        let clues = buildClues(for: target, in: shuffled)
        return DailyChallenge.MysteryCountryContent(
            targetCountry: target,
            clues: clues
        )
    }

    func buildClues(
        for country: Country,
        in countries: [Country]
    ) -> [DailyChallenge.MysteryClue] {
        let neighborCodes = Set(CountryNeighbors.neighbors(for: country.code))
        let neighborNames = countries
            .filter { neighborCodes.contains($0.code) }
            .map(\.name)
            .sorted()
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
        starter: Country,
        from shuffled: [Country],
        seed: UInt64
    ) -> DailyChallenge.CapitalChainContent {
        var usedContinents: Set<Country.Continent> = [starter.continent]
        var chainSteps: [DailyChallenge.ChainStep] = []

        let remaining = shuffled.filter { $0.code != starter.code }
        var stepIndex = 0

        for continent in Country.Continent.allCases
            where !usedContinents.contains(continent) {
            guard continent != .antarctica else { continue }
            let candidates = remaining.filter { $0.continent == continent }
            guard let target = candidates.first else { continue }
            let distractors = remaining
                .filter {
                    $0.continent == continent && $0.code != target.code
                }
                .prefix(3)

            var options = [target] + Array(distractors)
            options = options.seededShuffle(
                seed: seed &+ UInt64(stepIndex) &* 7_919
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
    nonisolated static var storageURL: URL {
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return directory.appendingPathComponent(
            "daily_challenge_results.json"
        )
    }

    static func allResults() async -> [DailyChallengeResult] {
        if let cachedResults {
            return cachedResults
        }
        let loaded = await readResultsInBackground(from: storageURL)
        // A save may have landed while the file was being read; its list is newer.
        if let cachedResults {
            return cachedResults
        }
        cachedResults = loaded
        return loaded
    }

    @concurrent
    nonisolated static func readResultsInBackground(from url: URL) async -> [DailyChallengeResult] {
        readResults(from: url)
    }

    nonisolated static func readResults(from url: URL) -> [DailyChallengeResult] {
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(
            [DailyChallengeResult].self,
            from: data
        )) ?? []
    }

    static func persistResults(_ results: [DailyChallengeResult]) {
        cachedResults = results
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(results) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }
}
