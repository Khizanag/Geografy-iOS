import Foundation

enum QuestionGenerator {
    #if !os(tvOS)
    nonisolated(unsafe) private static let symbolsService = NationalSymbolsService()
    #endif

    static func generate(
        type: QuizType,
        countries: [Country],
        count: Int,
        optionCount: Int,
        comparisonMetric: ComparisonMetric = .population
    ) -> [QuizQuestion] {
        guard !countries.isEmpty else { return [] }

        let pool = filteredPool(type: type, countries: countries, comparisonMetric: comparisonMetric)

        let selectedCountries = Array(pool.shuffled().prefix(count))

        return selectedCountries.compactMap { country in
            makeQuestion(
                type: type,
                country: country,
                allCountries: countries,
                optionCount: optionCount,
                comparisonMetric: comparisonMetric
            )
        }
    }
}

// MARK: - Pool Filtering
private extension QuestionGenerator {
    static func filteredPool(
        type: QuizType,
        countries: [Country],
        comparisonMetric: ComparisonMetric
    ) -> [Country] {
        #if !os(tvOS)
        if type == .nationalSymbols {
            return countries.filter { symbolsService.symbol(for: $0.code) != nil }
        }
        #endif
        if type == .worldRankings {
            return countries.filter { comparisonMetric.value(for: $0) > 0 }
        }
        return countries
    }
}

// MARK: - Question Builders
private extension QuestionGenerator {
    static func makeQuestion(
        type: QuizType,
        country: Country,
        allCountries: [Country],
        optionCount: Int,
        comparisonMetric: ComparisonMetric = .population
    ) -> QuizQuestion? {
        switch type {
        case .flagQuiz:
            makeFlagQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
        case .capitalQuiz:
            makeCapitalQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
        case .reverseFlag:
            makeReverseFlagQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
        case .reverseCapital:
            makeReverseCapitalQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
        case .worldRankings:
            makeWorldRankingsQuestion(country: country, allCountries: allCountries, optionCount: optionCount, metric: comparisonMetric)
        case .nationalSymbols:
            #if os(tvOS)
            nil
            #else
            makeNationalSymbolsQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
            #endif
        }
    }

    static func makeFlagQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: country.name, flagCode: nil)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .map { QuizOption(id: UUID(), text: $0.name, flagCode: nil) }
        let options = ([correctOption] + distractors).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: "What country has this flag?",
            promptSubject: nil,
            promptFlag: country.code,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    static func makeCapitalQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: country.capital, flagCode: nil)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .map { QuizOption(id: UUID(), text: $0.capital, flagCode: nil) }
        let options = ([correctOption] + distractors).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: "What is the capital of",
            promptSubject: country.name,
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    static func makeReverseFlagQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: nil, flagCode: country.code)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .map { QuizOption(id: UUID(), text: nil, flagCode: $0.code) }
        let options = ([correctOption] + distractors).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: "Which flag belongs to",
            promptSubject: country.name,
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    static func makeReverseCapitalQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: country.name, flagCode: nil)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .map { QuizOption(id: UUID(), text: $0.name, flagCode: nil) }
        let options = ([correctOption] + distractors).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: "is the capital of which country?",
            promptSubject: country.capital,
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    static func makeWorldRankingsQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int,
        metric: ComparisonMetric
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: country.name, flagCode: nil)
        let correctValue = metric.value(for: country)
        let smallerCountries = allCountries.filter {
            $0.code != country.code && metric.value(for: $0) < correctValue && metric.value(for: $0) > 0
        }
        let distractors = Array(smallerCountries.shuffled().prefix(optionCount - 1))
        let distractorOptions = distractors.map { QuizOption(id: UUID(), text: $0.name, flagCode: nil) }
        let options = ([correctOption] + distractorOptions).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: metric.questionText,
            promptSubject: nil,
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    #if !os(tvOS)
    static func makeNationalSymbolsQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion? {
        guard let symbol = symbolsService.symbol(for: country.code) else { return nil }

        let symbolTypes: [(String, String)] = [
            ("animal", symbol.animal),
            ("flower", symbol.flower),
            ("sport", symbol.sport),
        ]
            .filter { !$0.1.isEmpty }

        guard let (typeName, value) = symbolTypes.randomElement() else { return nil }

        let countriesWithSymbols = allCountries.compactMap { candidate -> (Country, NationalSymbol)? in
            guard candidate.code != country.code,
                  let symbol = symbolsService.symbol(for: candidate.code) else { return nil }
            return (candidate, symbol)
        }

        let askCountryFromSymbol = Bool.random()

        if askCountryFromSymbol {
            let correctID = UUID()
            let correctOption = QuizOption(id: correctID, text: country.name, flagCode: country.code)
            let distractors = Array(countriesWithSymbols.shuffled().prefix(optionCount - 1))
                .map { QuizOption(id: UUID(), text: $0.0.name, flagCode: $0.0.code) }
            let options = ([correctOption] + distractors).shuffled()

            return QuizQuestion(
                id: UUID(),
                promptText: "Which country's national \(typeName) is",
                promptSubject: value,
                promptFlag: nil,
                options: options,
                correctOptionID: correctID,
                correctCountry: country,
            )
        } else {
            let correctID = UUID()
            let correctOption = QuizOption(id: correctID, text: value, flagCode: nil)
            let distractorValues = countriesWithSymbols.shuffled().prefix(optionCount - 1).map { _, symbol in
                switch typeName {
                case "animal": symbol.animal
                case "flower": symbol.flower
                case "sport": symbol.sport
                default: symbol.animal
                }
            }
            let distractorOptions = distractorValues.map { QuizOption(id: UUID(), text: $0, flagCode: nil) }
            let options = ([correctOption] + distractorOptions).shuffled()

            return QuizQuestion(
                id: UUID(),
                promptText: "What is \(country.name)'s national \(typeName)?",
                promptSubject: nil,
                promptFlag: country.code,
                options: options,
                correctOptionID: correctID,
                correctCountry: country,
            )
        }
    }
    #endif
}

// MARK: - Distractor Selection
private extension QuestionGenerator {
    static func selectDistractors(for country: Country, from allCountries: [Country], count: Int) -> [Country] {
        let sameContinentCountries = allCountries.filter {
            $0.code != country.code && $0.continent == country.continent
        }
        let otherCountries = allCountries.filter { $0.code != country.code && $0.continent != country.continent }

        var distractors: [Country] = []

        let shuffledSameContinent = sameContinentCountries.shuffled()
        distractors.append(contentsOf: shuffledSameContinent.prefix(count))

        if distractors.count < count {
            let remaining = count - distractors.count
            let shuffledOther = otherCountries.shuffled()
            distractors.append(contentsOf: shuffledOther.prefix(remaining))
        }

        return Array(distractors.prefix(count))
    }
}
