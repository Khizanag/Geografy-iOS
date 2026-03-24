import Foundation

struct GeoTriviaService {
    func generateQuestions(from countries: [Country]) -> [GeoTriviaQuestion] {
        var questions: [GeoTriviaQuestion] = []
        questions += capitalQuestions(from: countries)
        questions += continentQuestions(from: countries)
        questions += borderQuestions(from: countries)
        questions += sizeQuestions(from: countries)
        questions += staticFacts()
        return questions.shuffled()
    }
}

// MARK: - Generators

private extension GeoTriviaService {
    func capitalQuestions(from countries: [Country]) -> [GeoTriviaQuestion] {
        countries.compactMap { country in
            guard !country.capital.isEmpty else { return nil }
            let useCorrect = Bool.random()
            if useCorrect {
                return GeoTriviaQuestion(
                    statement: "The capital of \(country.name) is \(country.capital).",
                    isTrue: true,
                    explanation: "\(country.capital) is indeed the capital of \(country.name)."
                )
            } else {
                let wrong = countries.filter { $0.id != country.id && !$0.capital.isEmpty }.randomElement()
                guard let wrongCountry = wrong else { return nil }
                return GeoTriviaQuestion(
                    statement: "The capital of \(country.name) is \(wrongCountry.capital).",
                    isTrue: false,
                    explanation: "The capital of \(country.name) is \(country.capital), not \(wrongCountry.capital)."
                )
            }
        }
    }

    func continentQuestions(from countries: [Country]) -> [GeoTriviaQuestion] {
        countries.compactMap { country in
            let useCorrect = Bool.random()
            if useCorrect {
                return GeoTriviaQuestion(
                    statement: "\(country.name) is located in \(country.continent.displayName).",
                    isTrue: true,
                    explanation: "\(country.name) is indeed in \(country.continent.displayName)."
                )
            } else {
                let wrongContinents = Country.Continent.allCases.filter { $0 != country.continent && $0 != .antarctica }
                guard let wrong = wrongContinents.randomElement() else { return nil }
                return GeoTriviaQuestion(
                    statement: "\(country.name) is located in \(wrong.displayName).",
                    isTrue: false,
                    explanation: "\(country.name) is in \(country.continent.displayName), not \(wrong.displayName)."
                )
            }
        }
    }

    func borderQuestions(from countries: [Country]) -> [GeoTriviaQuestion] {
        []
    }

    func sizeQuestions(from countries: [Country]) -> [GeoTriviaQuestion] {
        let sorted = countries.sorted { $0.area > $1.area }
        var questions: [GeoTriviaQuestion] = []

        if let largest = sorted.first {
            questions.append(
                GeoTriviaQuestion(
                    statement: "\(largest.name) is the largest country in the world by land area.",
                    isTrue: true,
                    explanation: "\(largest.name) has an area of approximately \(Int(largest.area).formatted()) km²."
                )
            )
        }

        if sorted.count > 1 {
            let second = sorted[1]
            questions.append(
                GeoTriviaQuestion(
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
                GeoTriviaQuestion(
                    statement: "\(mostPopulous.name) is the most populous country in the world.",
                    isTrue: true,
                    explanation: "\(mostPopulous.name) has a population of over \(pop) people."
                )
            )
        }

        return questions
    }

    func staticFacts() -> [GeoTriviaQuestion] {
        [
            GeoTriviaQuestion(
                statement: "The Pacific Ocean is the largest ocean on Earth.",
                isTrue: true,
                explanation: "The Pacific Ocean covers about 165 million km², making it the world's largest ocean."
            ),
            GeoTriviaQuestion(
                statement: "The Atlantic Ocean is the largest ocean on Earth.",
                isTrue: false,
                explanation: "The Pacific Ocean is the largest. The Atlantic is the second largest ocean."
            ),
            GeoTriviaQuestion(
                statement: "Africa is the second largest continent by area.",
                isTrue: true,
                explanation: "Africa covers about 30.3 million km², making it the second largest continent after Asia."
            ),
            GeoTriviaQuestion(
                statement: "Europe is the largest continent by area.",
                isTrue: false,
                explanation: "Asia is the largest continent by area, covering about 44.6 million km²."
            ),
            GeoTriviaQuestion(
                statement: "The Amazon River is the longest river in the world.",
                isTrue: false,
                explanation: "The Nile River is generally considered the longest river at about 6,650 km."
            ),
            GeoTriviaQuestion(
                statement: "The Nile is the longest river in the world.",
                isTrue: true,
                explanation: "The Nile River stretches approximately 6,650 km through northeastern Africa."
            ),
            GeoTriviaQuestion(
                statement: "Mount Everest is the tallest mountain on Earth.",
                isTrue: true,
                explanation: "Mount Everest stands at 8,849 meters above sea level, the highest point on Earth."
            ),
            GeoTriviaQuestion(
                statement: "The Sahara is the largest desert in the world.",
                isTrue: false,
                explanation: "Antarctica is actually the world's largest desert. The Sahara is the largest hot desert."
            ),
            GeoTriviaQuestion(
                statement: "Antarctica is the coldest continent.",
                isTrue: true,
                explanation: "Antarctica holds the record for the lowest natural temperature ever recorded on Earth."
            ),
            GeoTriviaQuestion(
                statement: "Australia is both a country and a continent.",
                isTrue: true,
                explanation: "Australia is unique in being both a sovereign country and a continental landmass."
            ),
        ]
    }
}
