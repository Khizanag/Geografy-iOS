import Foundation

enum QuestionGenerator {
    static func generate(
        type: QuizType,
        countries: [Country],
        count: Int,
        optionCount: Int
    ) -> [QuizQuestion] {
        guard !countries.isEmpty else { return [] }

        let selectedCountries = Array(countries.shuffled().prefix(count))

        return selectedCountries.compactMap { country in
            makeQuestion(type: type, country: country, allCountries: countries, optionCount: optionCount)
        }
    }
}

// MARK: - Question Builders

private extension QuestionGenerator {
    static func makeQuestion(
        type: QuizType,
        country: Country,
        allCountries: [Country],
        optionCount: Int
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
        case .populationOrder:
            makePopulationOrderQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
        case .areaOrder:
            makeAreaOrderQuestion(country: country, allCountries: allCountries, optionCount: optionCount)
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
            promptText: "What is the capital of \(country.name)?",
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
            promptText: "Which flag belongs to \(country.name)?",
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
            promptText: "\(country.capital) is the capital of which country?",
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    static func makePopulationOrderQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: country.name, flagCode: nil)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .filter { $0.population < country.population }

        let distractorOptions = distractors.map { QuizOption(id: UUID(), text: $0.name, flagCode: nil) }
        let options = ([correctOption] + distractorOptions).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: "Which country has the largest population?",
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }

    static func makeAreaOrderQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion {
        let correctID = UUID()
        let correctOption = QuizOption(id: correctID, text: country.name, flagCode: nil)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .filter { $0.area < country.area }

        let distractorOptions = distractors.map { QuizOption(id: UUID(), text: $0.name, flagCode: nil) }
        let options = ([correctOption] + distractorOptions).shuffled()

        return QuizQuestion(
            id: UUID(),
            promptText: "Which country has the largest area?",
            promptFlag: nil,
            options: options,
            correctOptionID: correctID,
            correctCountry: country,
        )
    }
}

// MARK: - Distractor Selection

private extension QuestionGenerator {
    static func selectDistractors(for country: Country, from allCountries: [Country], count: Int) -> [Country] {
        let sameContinentCountries = allCountries.filter { $0.code != country.code && $0.continent == country.continent }
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
