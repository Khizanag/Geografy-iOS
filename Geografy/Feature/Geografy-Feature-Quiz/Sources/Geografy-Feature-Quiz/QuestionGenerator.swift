import Foundation
import Geografy_Core_Common
import Geografy_Feature_NationalSymbols

public enum QuestionGenerator {
    #if !os(tvOS)
    nonisolated(unsafe) private static let symbolsService = NationalSymbolsService()
    #endif

    public static func generate(
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
            makeWorldRankingsQuestion(
                country: country,
                allCountries: allCountries,
                optionCount: optionCount,
                metric: comparisonMetric
            )
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
        let distractors = selectDistractors(
            for: country,
            from: allCountries,
            count: optionCount - 1,
            uniqueBy: \.capital,
            excluding: country.capital
        )
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
        let others = allCountries.filter {
            $0.code != country.code && metric.value(for: $0) > 0
        }
        let smallerCountries = others
            .filter { metric.value(for: $0) < correctValue }
            .shuffled()
        let largerCountries = others
            .filter { metric.value(for: $0) >= correctValue }
            .shuffled()
        var distractors = Array(smallerCountries.prefix(optionCount - 1))
        if distractors.count < optionCount - 1 {
            let remaining = optionCount - 1 - distractors.count
            distractors += Array(largerCountries.prefix(remaining))
        }
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
            var seenValues: Set<String> = [value.lowercased()]
            var distractorValues: [String] = []
            for (_, symbol) in countriesWithSymbols.shuffled() {
                let distractorValue: String = switch typeName {
                case "animal": symbol.animal
                case "flower": symbol.flower
                case "sport": symbol.sport
                default: symbol.animal
                }
                let key = distractorValue.lowercased()
                guard !distractorValue.isEmpty, !seenValues.contains(key) else { continue }
                seenValues.insert(key)
                distractorValues.append(distractorValue)
                if distractorValues.count >= optionCount - 1 { break }
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
    static func selectDistractors(
        for country: Country,
        from allCountries: [Country],
        count: Int,
        uniqueBy keyPath: KeyPath<Country, String>? = nil,
        excluding correctValue: String? = nil
    ) -> [Country] {
        let candidates = allCountries.filter { $0.code != country.code }
        let sameContinentCandidates = candidates
            .filter { $0.continent == country.continent }
            .shuffled()
        let otherCandidates = candidates
            .filter { $0.continent != country.continent }
            .shuffled()

        var distractors: [Country] = []
        var seenValues: Set<String> = []
        if let correctValue {
            seenValues.insert(correctValue.lowercased())
        }

        for candidate in sameContinentCandidates + otherCandidates {
            if let keyPath {
                let value = candidate[keyPath: keyPath].lowercased()
                guard !value.isEmpty, !seenValues.contains(value) else { continue }
                seenValues.insert(value)
            }
            distractors.append(candidate)
            if distractors.count >= count { break }
        }

        return distractors
    }
}
