import Foundation
import Geografy_Core_Common

// MARK: - Landmarks and Nicknames
extension QuestionGenerator {
    static func makeLandmarkQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion? {
        guard let hint = LandmarkHints.data[country.code]?.randomElement() else { return nil }
        return makeCountryChoiceQuestion(
            promptText: "Which country is this?",
            promptSubject: hint,
            country: country,
            allCountries: allCountries,
            optionCount: optionCount
        )
    }

    static func makeNicknameQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion? {
        guard let nickname = CountryNicknames.data[country.code]?.randomElement() else { return nil }
        return makeCountryChoiceQuestion(
            promptText: "Which country is nicknamed",
            promptSubject: "“\(nickname.nickname)”",
            country: country,
            allCountries: allCountries,
            optionCount: optionCount,
            explanation: nickname.reason
        )
    }
}

// MARK: - Neighbors
extension QuestionGenerator {
    static func makeNeighborQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion? {
        let neighborCodes = Set(CountryNeighbors.neighbors(for: country.code))
        guard let neighbor = allCountries.filter({ neighborCodes.contains($0.code) }).randomElement() else {
            return nil
        }
        let correctOption = QuizOption(text: neighbor.name)
        let distractors = selectDistractors(
            for: country,
            from: allCountries,
            count: optionCount - 1,
            excludingCodes: neighborCodes
        )
            .map { QuizOption(text: $0.name) }

        return QuizQuestion(
            promptText: "Which country borders",
            promptSubject: country.name,
            options: ([correctOption] + distractors).shuffled(),
            correctOptionID: correctOption.id,
            correctCountry: neighbor
        )
    }
}

// MARK: - Mystery Country
extension QuestionGenerator {
    static func makeMysteryCountryQuestion(
        country: Country,
        allCountries: [Country],
        optionCount: Int
    ) -> QuizQuestion? {
        var details = [
            "Continent: \(country.continent.displayName)",
            "Population: \(populationRange(for: country.population))",
        ]
        if let initial = country.capital.first {
            details.append("Capital starts with “\(initial)”")
        }
        if let borders = bordersClue(for: country, in: allCountries) {
            details.append(borders)
        }
        return makeCountryChoiceQuestion(
            promptText: "Which country is this?",
            promptSubject: nil,
            promptDetails: details,
            country: country,
            allCountries: allCountries,
            optionCount: optionCount
        )
    }

    static func populationRange(for population: Int) -> String {
        switch population {
        case ..<1_000_000: "under 1 million"
        case ..<10_000_000: "1–10 million"
        case ..<50_000_000: "10–50 million"
        case ..<100_000_000: "50–100 million"
        default: "over 100 million"
        }
    }

    static func bordersClue(for country: Country, in allCountries: [Country]) -> String? {
        let neighborCodes = CountryNeighbors.neighbors(for: country.code)
        guard !neighborCodes.isEmpty else { return "No land borders" }
        let names = allCountries
            .filter { neighborCodes.contains($0.code) }
            .map(\.name)
            .shuffled()
            .prefix(3)
        guard !names.isEmpty else { return nil }
        return "Borders \(names.sorted().joined(separator: ", "))"
    }
}

// MARK: - True or False
extension QuestionGenerator {
    struct FactStatement {
        let text: String
        let isTrue: Bool
        let explanation: String
    }

    static func makeTrueOrFalseQuestion(
        country: Country,
        allCountries: [Country]
    ) -> QuizQuestion? {
        let statements = [
            capitalStatement(for: country, allCountries: allCountries),
            continentStatement(for: country),
            borderStatement(for: country, allCountries: allCountries),
        ]
            .compactMap(\.self)
        guard let statement = statements.randomElement() else { return nil }

        let trueOption = QuizOption(text: "True")
        let falseOption = QuizOption(text: "False")
        return QuizQuestion(
            promptText: "True or false?",
            promptSubject: statement.text,
            options: [trueOption, falseOption],
            correctOptionID: statement.isTrue ? trueOption.id : falseOption.id,
            correctCountry: country,
            explanation: statement.explanation
        )
    }

    static func capitalStatement(for country: Country, allCountries: [Country]) -> FactStatement? {
        guard !country.capital.isEmpty else { return nil }
        let truth = "The capital of \(country.name) is \(country.capital)."
        guard Bool.random(),
              let other = selectDistractors(
                  for: country,
                  from: allCountries,
                  count: 1,
                  uniqueBy: \.capital,
                  excluding: country.capital
              ).first
        else {
            return FactStatement(text: truth, isTrue: true, explanation: truth)
        }
        return FactStatement(
            text: "The capital of \(country.name) is \(other.capital).",
            isTrue: false,
            explanation: "\(other.capital) is the capital of \(other.name). \(truth)"
        )
    }

    static func continentStatement(for country: Country) -> FactStatement? {
        let truth = "\(country.name) is in \(country.continent.displayName)."
        let wrongContinents = Country.Continent.allCases.filter { $0 != country.continent && $0 != .antarctica }
        guard Bool.random(), let wrong = wrongContinents.randomElement() else {
            return FactStatement(text: truth, isTrue: true, explanation: truth)
        }
        return FactStatement(
            text: "\(country.name) is in \(wrong.displayName).",
            isTrue: false,
            explanation: truth
        )
    }

    static func borderStatement(for country: Country, allCountries: [Country]) -> FactStatement? {
        let neighborCodes = Set(CountryNeighbors.neighbors(for: country.code))
        let neighbors = allCountries.filter { neighborCodes.contains($0.code) }
        guard let neighbor = neighbors.randomElement() else { return nil }
        let truth = "\(country.name) shares a border with \(neighbor.name)."
        guard Bool.random(),
              let stranger = selectDistractors(
                  for: country,
                  from: allCountries,
                  count: 1,
                  excludingCodes: neighborCodes
              ).first
        else {
            return FactStatement(text: truth, isTrue: true, explanation: truth)
        }
        return FactStatement(
            text: "\(country.name) shares a border with \(stranger.name).",
            isTrue: false,
            explanation: "\(country.name) and \(stranger.name) don't share a border. \(truth)"
        )
    }
}

// MARK: - Helpers
extension QuestionGenerator {
    static func makeCountryChoiceQuestion(
        promptText: String,
        promptSubject: String?,
        promptDetails: [String] = [],
        country: Country,
        allCountries: [Country],
        optionCount: Int,
        explanation: String? = nil
    ) -> QuizQuestion {
        let correctOption = QuizOption(text: country.name)
        let distractors = selectDistractors(for: country, from: allCountries, count: optionCount - 1)
            .map { QuizOption(text: $0.name) }

        return QuizQuestion(
            promptText: promptText,
            promptSubject: promptSubject,
            promptDetails: promptDetails,
            options: ([correctOption] + distractors).shuffled(),
            correctOptionID: correctOption.id,
            correctCountry: country,
            explanation: explanation
        )
    }
}
