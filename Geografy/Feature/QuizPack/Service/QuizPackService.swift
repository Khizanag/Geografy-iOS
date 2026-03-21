import Foundation

@Observable
final class QuizPackService {
    private(set) var progressByLevel: [String: QuizPackProgress] = [:]
    private let storageKey = "quiz_pack_progress"

    func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(
                  [String: QuizPackProgress].self,
                  from: data
              ) else {
            return
        }
        progressByLevel = decoded
    }

    func recordCompletion(
        levelID: String,
        accuracy: Double
    ) {
        let stars = QuizPackProgress.starRating(for: accuracy)
        let existing = progressByLevel[levelID]
        let shouldUpdate = existing == nil
            || accuracy > (existing?.bestAccuracy ?? 0)

        guard shouldUpdate else { return }

        progressByLevel[levelID] = QuizPackProgress(
            levelID: levelID,
            stars: stars,
            bestAccuracy: accuracy,
            completedAt: Date()
        )
        saveProgress()
    }

    func progress(for levelID: String) -> QuizPackProgress? {
        progressByLevel[levelID]
    }

    func stars(for levelID: String) -> Int {
        progressByLevel[levelID]?.stars ?? 0
    }

    func completedLevelCount(for pack: QuizPack) -> Int {
        pack.levels.filter { progressByLevel[$0.id] != nil }.count
    }

    func totalStars(for pack: QuizPack) -> Int {
        pack.levels.reduce(0) { $0 + stars(for: $1.id) }
    }

    func maxStars(for pack: QuizPack) -> Int {
        pack.levels.count * 3
    }

    func isPackCompleted(_ pack: QuizPack) -> Bool {
        completedLevelCount(for: pack) == pack.levelCount
    }

    func isPackUnlocked(
        _ pack: QuizPack,
        allPacks: [QuizPack]
    ) -> Bool {
        guard let prerequisiteID = pack.prerequisitePackID else {
            return true
        }
        guard let prerequisite = allPacks.first(
            where: { $0.id == prerequisiteID }
        ) else {
            return true
        }
        return isPackCompleted(prerequisite)
    }
}

// MARK: - Persistence

private extension QuizPackService {
    func saveProgress() {
        guard let encoded = try? JSONEncoder().encode(
            progressByLevel
        ) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

// MARK: - Pack Catalog

extension QuizPackService {
    static func makeAllPacks(
        countries: [Country]
    ) -> [QuizPack] {
        var packs: [QuizPack] = []
        packs.append(contentsOf: makeCapitalsPacks(countries: countries))
        packs.append(contentsOf: makeFlagPacks(countries: countries))
        packs.append(contentsOf: makePopulationPacks(countries: countries))
        packs.append(contentsOf: makeGeographyPacks(countries: countries))
        packs.append(contentsOf: makeCurrencyPacks(countries: countries))
        packs.append(contentsOf: makeGovernmentPacks(countries: countries))
        packs.append(contentsOf: makeOrganizationPacks(countries: countries))
        return packs
    }
}

// MARK: - Capitals Packs

private extension QuizPackService {
    static func makeCapitalsPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let continents: [(Country.Continent, String, Int)] = [
            (.europe, "europe", 0),
            (.asia, "asia", 1),
            (.africa, "africa", 2),
            (.northAmerica, "north_america", 3),
            (.southAmerica, "south_america", 4),
            (.oceania, "oceania", 5),
        ]

        return continents.enumerated().map { index, entry in
            let (continent, slug, _) = entry
            let filtered = countries.filter {
                $0.continent == continent
            }
            let levels = makeLevels(
                packSlug: "capitals_\(slug)",
                countries: filtered,
                questionsPerLevel: 10
            )
            let previousID: String? = index > 0
                ? "capitals_\(continents[index - 1].1)"
                : nil

            return QuizPack(
                id: "capitals_\(slug)",
                name: "\(continent.displayName) Capitals",
                description: "Master all capitals in \(continent.displayName)",
                icon: "building.columns.fill",
                category: .capitals,
                levels: levels,
                gradientColors: QuizPackCategory.capitals.gradientColors,
                isPremium: index >= 2,
                prerequisitePackID: previousID
            )
        }
    }
}

// MARK: - Flag Packs

private extension QuizPackService {
    static func makeFlagPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let easyCountryCodes = Set([
            "US", "GB", "JP", "CA", "BR", "AU", "DE", "FR",
            "IT", "ES", "MX", "IN", "CN", "RU", "KR", "ZA",
            "TR", "SE", "NO", "DK", "FI", "NZ", "AR", "CL",
            "EG", "GR", "NL", "PT", "CH", "AT",
        ])
        let easyCountries = countries.filter {
            easyCountryCodes.contains($0.code)
        }
        let hardCountries = countries.filter {
            !easyCountryCodes.contains($0.code)
        }

        return [
            QuizPack(
                id: "flags_easy",
                name: "Distinctive Flags",
                description: "Well-known flags from around the world",
                icon: "flag.fill",
                category: .flags,
                levels: makeLevels(
                    packSlug: "flags_easy",
                    countries: easyCountries,
                    questionsPerLevel: 10
                ),
                gradientColors: QuizPackCategory.flags.gradientColors,
                isPremium: false,
                prerequisitePackID: nil
            ),
            QuizPack(
                id: "flags_hard",
                name: "Tricky Flags",
                description: "Similar-looking flags that test your eye",
                icon: "flag.2.crossed.fill",
                category: .flags,
                levels: makeLevels(
                    packSlug: "flags_hard",
                    countries: hardCountries,
                    questionsPerLevel: 10
                ),
                gradientColors: (
                    Color(hex: "880E4F"),
                    Color(hex: "C2185B")
                ),
                isPremium: true,
                prerequisitePackID: "flags_easy"
            ),
        ]
    }
}

// MARK: - Population Packs

private extension QuizPackService {
    static func makePopulationPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let sorted = countries.sorted { $0.population > $1.population }
        return [
            QuizPack(
                id: "population_top",
                name: "Most Populated",
                description: "Countries with the largest populations",
                icon: "person.3.fill",
                category: .population,
                levels: makeLevels(
                    packSlug: "population_top",
                    countries: Array(sorted.prefix(60)),
                    questionsPerLevel: 10
                ),
                gradientColors: QuizPackCategory.population.gradientColors,
                isPremium: false,
                prerequisitePackID: nil
            ),
            QuizPack(
                id: "population_bottom",
                name: "Least Populated",
                description: "Countries with the smallest populations",
                icon: "person.fill",
                category: .population,
                levels: makeLevels(
                    packSlug: "population_bottom",
                    countries: Array(sorted.suffix(60)),
                    questionsPerLevel: 10
                ),
                gradientColors: (
                    Color(hex: "006064"),
                    Color(hex: "00838F")
                ),
                isPremium: true,
                prerequisitePackID: "population_top"
            ),
        ]
    }
}

// MARK: - Geography Packs

private extension QuizPackService {
    static func makeGeographyPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let bySizeDesc = countries.sorted { $0.area > $1.area }
        let largest = Array(bySizeDesc.prefix(50))
        let smallest = Array(bySizeDesc.suffix(50))
        let landlocked = countries.filter {
            $0.area < 1_000_000 && $0.population > 100_000
        }

        return [
            QuizPack(
                id: "geo_largest",
                name: "Largest Countries",
                description: "The biggest countries by land area",
                icon: "arrow.up.left.and.arrow.down.right",
                category: .geography,
                levels: makeLevels(
                    packSlug: "geo_largest",
                    countries: largest,
                    questionsPerLevel: 10
                ),
                gradientColors: QuizPackCategory.geography.gradientColors,
                isPremium: false,
                prerequisitePackID: nil
            ),
            QuizPack(
                id: "geo_smallest",
                name: "Smallest Countries",
                description: "The tiniest countries by land area",
                icon: "arrow.down.right.and.arrow.up.left",
                category: .geography,
                levels: makeLevels(
                    packSlug: "geo_smallest",
                    countries: smallest,
                    questionsPerLevel: 10
                ),
                gradientColors: (
                    Color(hex: "33691E"),
                    Color(hex: "558B2F")
                ),
                isPremium: true,
                prerequisitePackID: "geo_largest"
            ),
            QuizPack(
                id: "geo_misc",
                name: "Geography Mix",
                description: "Mixed geography challenges",
                icon: "globe.europe.africa",
                category: .geography,
                levels: makeLevels(
                    packSlug: "geo_misc",
                    countries: landlocked,
                    questionsPerLevel: 10
                ),
                gradientColors: (
                    Color(hex: "2E7D32"),
                    Color(hex: "43A047")
                ),
                isPremium: true,
                prerequisitePackID: "geo_smallest"
            ),
        ]
    }
}

// MARK: - Currency Packs

private extension QuizPackService {
    static func makeCurrencyPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let withCurrency = countries.filter {
            !$0.currency.name.isEmpty
        }
        return [
            QuizPack(
                id: "currency_match",
                name: "Currency Match",
                description: "Match currencies to their countries",
                icon: "banknote.fill",
                category: .currency,
                levels: makeLevels(
                    packSlug: "currency_match",
                    countries: withCurrency,
                    questionsPerLevel: 10
                ),
                gradientColors: QuizPackCategory.currency.gradientColors,
                isPremium: true,
                prerequisitePackID: nil
            ),
        ]
    }
}

// MARK: - Government Packs

private extension QuizPackService {
    static func makeGovernmentPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let withGov = countries.filter {
            !$0.formOfGovernment.isEmpty
        }
        return [
            QuizPack(
                id: "government_types",
                name: "Government Types",
                description: "Identify government systems worldwide",
                icon: "scroll.fill",
                category: .government,
                levels: makeLevels(
                    packSlug: "government_types",
                    countries: withGov,
                    questionsPerLevel: 10
                ),
                gradientColors: QuizPackCategory.government.gradientColors,
                isPremium: true,
                prerequisitePackID: nil
            ),
        ]
    }
}

// MARK: - Organization Packs

private extension QuizPackService {
    static func makeOrganizationPacks(
        countries: [Country]
    ) -> [QuizPack] {
        let orgSlugs: [(String, String, String)] = [
            ("UN", "United Nations", "globe"),
            ("EU", "European Union", "star.fill"),
            ("NATO", "NATO", "shield.fill"),
        ]

        return orgSlugs.map { code, name, icon in
            let members = countries.filter {
                $0.organizations.contains(code)
            }
            return QuizPack(
                id: "org_\(code.lowercased())",
                name: "\(name) Members",
                description: "Which countries belong to the \(name)?",
                icon: icon,
                category: .organizations,
                levels: makeLevels(
                    packSlug: "org_\(code.lowercased())",
                    countries: members,
                    questionsPerLevel: 10
                ),
                gradientColors: QuizPackCategory.organizations.gradientColors,
                isPremium: true,
                prerequisitePackID: nil
            )
        }
    }
}

// MARK: - Level Builder

private extension QuizPackService {
    static func makeLevels(
        packSlug: String,
        countries: [Country],
        questionsPerLevel: Int
    ) -> [QuizPackLevel] {
        let chunks = countries.chunked(into: questionsPerLevel)
        return chunks.enumerated().map { index, chunk in
            QuizPackLevel(
                id: "\(packSlug)_level_\(index + 1)",
                name: "Level \(index + 1)",
                questionCount: chunk.count,
                countryCodes: chunk.map(\.code)
            )
        }
    }
}

// MARK: - Array Chunking

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
