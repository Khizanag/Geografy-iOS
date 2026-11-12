import Geografy_Core_Common
@testable import Geografy_Feature_Quiz
import Testing

@Suite("QuestionGenerator")
struct QuestionGeneratorTests {
    static let mergedTypes: [QuizType] = [.landmarks, .nicknames, .trueOrFalse, .neighbors, .mysteryCountry]

    static let countries: [Country] = [
        makeCountry("FR", "France", "Paris", .europe, population: 68_000_000),
        makeCountry("DE", "Germany", "Berlin", .europe, population: 84_000_000),
        makeCountry("IT", "Italy", "Rome", .europe, population: 59_000_000),
        makeCountry("ES", "Spain", "Madrid", .europe, population: 48_000_000),
        makeCountry("PT", "Portugal", "Lisbon", .europe, population: 10_400_000),
        makeCountry("BE", "Belgium", "Brussels", .europe, population: 11_700_000),
        makeCountry("NL", "Netherlands", "Amsterdam", .europe, population: 17_900_000),
        makeCountry("CH", "Switzerland", "Bern", .europe, population: 8_800_000),
        makeCountry("NO", "Norway", "Oslo", .europe, population: 5_500_000),
        makeCountry("SE", "Sweden", "Stockholm", .europe, population: 10_500_000),
        makeCountry("FI", "Finland", "Helsinki", .europe, population: 5_600_000),
        makeCountry("IS", "Iceland", "Reykjavík", .europe, population: 390_000),
        makeCountry("JP", "Japan", "Tokyo", .asia, population: 124_000_000),
    ]

    @Test("Every merged type yields well-formed questions", arguments: mergedTypes)
    func wellFormed(type: QuizType) throws {
        let questions = generate(type)

        try #require(!questions.isEmpty)
        for question in questions {
            let texts = question.options.compactMap(\.text)
            #expect(Set(texts).count == question.options.count)
            #expect(question.options.contains { $0.id == question.correctOptionID })
        }
    }

    @Test("Landmark and nickname pools only use countries with content")
    func contentPools() {
        for question in generate(.landmarks) {
            let hints = LandmarkHints.data[question.correctCountry.code] ?? []
            #expect(hints.contains(question.promptSubject ?? ""))
        }
        for question in generate(.nicknames) {
            #expect(CountryNicknames.data[question.correctCountry.code] != nil)
            #expect(question.explanation != nil)
        }
    }

    @Test("Neighbor questions have exactly one bordering option")
    func neighborOptions() throws {
        for question in generate(.neighbors) {
            let subject = try #require(Self.countries.first { $0.name == question.promptSubject })
            let neighborCodes = Set(CountryNeighbors.neighbors(for: subject.code))
            let borderingOptions = question.options.filter { option in
                Self.countries.contains { $0.name == option.text && neighborCodes.contains($0.code) }
            }
            #expect(borderingOptions.map(\.id) == [question.correctOptionID])
        }
    }

    @Test("Islands never appear in neighbor questions")
    func islandsExcluded() {
        let subjects = generate(.neighbors).compactMap(\.promptSubject)

        #expect(!subjects.contains("Iceland"))
        #expect(!subjects.contains("Japan"))
    }

    @Test("True or false offers two answers and explains the truth")
    func trueOrFalse() {
        for question in generate(.trueOrFalse) {
            #expect(question.options.compactMap(\.text) == ["True", "False"])
            #expect(question.explanation?.isEmpty == false)
        }
    }

    @Test("Mystery clues never name the answer")
    func mysteryClues() {
        for question in generate(.mysteryCountry) {
            #expect(question.promptDetails.first == "Continent: \(question.correctCountry.continent.displayName)")
            #expect(!question.promptDetails.contains { $0.contains(question.correctCountry.name) })
        }
    }

    @Test("Island mystery clue says it has no land borders")
    func islandClue() {
        let iceland = Self.countries[11]

        #expect(QuestionGenerator.bordersClue(for: iceland, in: Self.countries) == "No land borders")
    }
}

// MARK: - Helpers
private extension QuestionGeneratorTests {
    func generate(_ type: QuizType) -> [QuizQuestion] {
        QuestionGenerator.generate(type: type, countries: Self.countries, count: Self.countries.count, optionCount: 4)
    }

    static func makeCountry(
        _ code: String,
        _ name: String,
        _ capital: String,
        _ continent: Country.Continent,
        population: Int
    ) -> Country {
        Country(
            code: code,
            name: name,
            capital: capital,
            flagEmoji: "",
            continent: continent,
            area: 1,
            population: population,
            populationDensity: 1,
            currency: Country.Currency(name: "", code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
    }
}
