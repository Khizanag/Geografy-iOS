import Foundation
import Geografy_Core_Common

struct TriviaService {
    func generateQuestions(from countries: [Country]) -> [TriviaQuestion] {
        var questions: [TriviaQuestion] = []
        questions += capitalQuestions(from: countries)
        questions += continentQuestions(from: countries)
        questions += borderQuestions(from: countries)
        questions += sizeQuestions(from: countries)
        questions += staticFacts()
        return questions.shuffled()
    }
}

// MARK: - Generators
private extension TriviaService {
    func capitalQuestions(from countries: [Country]) -> [TriviaQuestion] {
        countries.compactMap { country in
            guard !country.capital.isEmpty else { return nil }
            let useCorrect = Bool.random()
            if useCorrect {
                return TriviaQuestion(
                    statement: "The capital of \(country.name) is \(country.capital).",
                    isTrue: true,
                    explanation: "\(country.capital) is indeed the capital of \(country.name)."
                )
            } else {
                let wrong = countries.filter { $0.id != country.id && !$0.capital.isEmpty }.randomElement()
                guard let wrongCountry = wrong else { return nil }
                return TriviaQuestion(
                    statement: "The capital of \(country.name) is \(wrongCountry.capital).",
                    isTrue: false,
                    explanation: "The capital of \(country.name) is \(country.capital), not \(wrongCountry.capital)."
                )
            }
        }
    }

    func continentQuestions(from countries: [Country]) -> [TriviaQuestion] {
        countries.compactMap { country in
            let useCorrect = Bool.random()
            if useCorrect {
                return TriviaQuestion(
                    statement: "\(country.name) is located in \(country.continent.displayName).",
                    isTrue: true,
                    explanation: "\(country.name) is indeed in \(country.continent.displayName)."
                )
            } else {
                let wrongContinents = Country.Continent.allCases.filter { $0 != country.continent && $0 != .antarctica }
                guard let wrong = wrongContinents.randomElement() else { return nil }
                return TriviaQuestion(
                    statement: "\(country.name) is located in \(wrong.displayName).",
                    isTrue: false,
                    explanation: "\(country.name) is in \(country.continent.displayName), not \(wrong.displayName)."
                )
            }
        }
    }

    func borderQuestions(from countries: [Country]) -> [TriviaQuestion] {
        []
    }

    func sizeQuestions(from countries: [Country]) -> [TriviaQuestion] {
        let sorted = countries.sorted { $0.area > $1.area }
        var questions: [TriviaQuestion] = []

        if let largest = sorted.first {
            questions.append(
                TriviaQuestion(
                    statement: "\(largest.name) is the largest country in the world by land area.",
                    isTrue: true,
                    explanation: "\(largest.name) has an area of approximately \(Int(largest.area).formatted()) km²."
                )
            )
        }

        if sorted.count > 1 {
            let second = sorted[1]
            questions.append(
                TriviaQuestion(
                    statement: "\(second.name) is the largest country in the world by land area.",
                    isTrue: false,
                    explanation: "\(second.name) is actually the second largest. The largest is \(sorted[0].name)."
                )
            )
        }

        let popSorted = countries.sorted { $0.population > $1.population }
        if let mostPopulous = popSorted.first {
            let pop = mostPopulous.population.formatted()
            questions.append(
                TriviaQuestion(
                    statement: "\(mostPopulous.name) is the most populous country in the world.",
                    isTrue: true,
                    explanation: "\(mostPopulous.name) has a population of over \(pop) people."
                )
            )
        }

        return questions
    }

    func staticFacts() -> [TriviaQuestion] {
        [
            TriviaQuestion(
                statement: "The Pacific Ocean is the largest ocean on Earth.",
                isTrue: true,
                explanation: "The Pacific Ocean covers about 165 million km², making it the world's largest ocean."
            ),
            TriviaQuestion(
                statement: "The Atlantic Ocean is the largest ocean on Earth.",
                isTrue: false,
                explanation: "The Pacific Ocean is the largest. The Atlantic is the second largest ocean."
            ),
            TriviaQuestion(
                statement: "Africa is the second largest continent by area.",
                isTrue: true,
                explanation: "Africa covers about 30.3 million km², making it the second largest continent after Asia."
            ),
            TriviaQuestion(
                statement: "Europe is the largest continent by area.",
                isTrue: false,
                explanation: "Asia is the largest continent by area, covering about 44.6 million km²."
            ),
            TriviaQuestion(
                statement: "The Amazon River is the longest river in the world.",
                isTrue: false,
                explanation: "The Nile River is generally considered the longest river at about 6,650 km."
            ),
            TriviaQuestion(
                statement: "The Nile is the longest river in the world.",
                isTrue: true,
                explanation: "The Nile River stretches approximately 6,650 km through northeastern Africa."
            ),
            TriviaQuestion(
                statement: "Mount Everest is the tallest mountain on Earth.",
                isTrue: true,
                explanation: "Mount Everest stands at 8,849 meters above sea level, the highest point on Earth."
            ),
            TriviaQuestion(
                statement: "The Sahara is the largest desert in the world.",
                isTrue: false,
                explanation: "Antarctica is actually the world's largest desert. The Sahara is the largest hot desert."
            ),
            TriviaQuestion(
                statement: "Antarctica is the coldest continent.",
                isTrue: true,
                explanation: "Antarctica holds the record for the lowest natural temperature ever recorded on Earth."
            ),
            TriviaQuestion(
                statement: "Australia is both a country and a continent.",
                isTrue: true,
                explanation: "Australia is unique in being both a sovereign country and a continental landmass."
            ),
        ]
    }
}
