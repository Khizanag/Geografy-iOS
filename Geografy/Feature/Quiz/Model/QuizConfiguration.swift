import Foundation

struct QuizConfiguration: Identifiable {
    let id = UUID()
    let type: QuizType
    let region: QuizRegion
    let difficulty: QuizDifficulty
    let questionCount: QuestionCount
    let answerMode: QuizAnswerMode
    let comparisonMetric: ComparisonMetric
    let gameMode: QuizGameMode
}

// MARK: - QuestionCount
enum QuestionCount: Int, CaseIterable, Identifiable {
    case five = 5
    case ten = 10
    case twenty = 20
    case thirty = 30
    case fifty = 50

    var id: Int { rawValue }

    var displayName: String {
        "\(rawValue)"
    }
}

// MARK: - ComparisonMetric
enum ComparisonMetric: String, CaseIterable, Identifiable, Codable {
    case population = "Population"
    case area = "Area"
    case gdpPerCapita = "GDP per Capita"
    case populationDensity = "Density"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .population: "person.3.fill"
        case .area: "map.fill"
        case .gdpPerCapita: "dollarsign.circle.fill"
        case .populationDensity: "person.crop.square"
        }
    }

    var questionText: String {
        switch self {
        case .population: "Which country has the largest population?"
        case .area: "Which country has the largest area?"
        case .gdpPerCapita: "Which country has the highest GDP per capita?"
        case .populationDensity: "Which country has the highest population density?"
        }
    }

    func value(for country: Country) -> Double {
        switch self {
        case .population: Double(country.population)
        case .area: country.area
        case .gdpPerCapita: country.gdpPerCapita ?? 0
        case .populationDensity: country.populationDensity
        }
    }
}

// MARK: - QuizGameMode
enum QuizGameMode: String, CaseIterable, Identifiable, Codable {
    case standard = "Standard"
    case arcade = "Arcade"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .standard: "list.number"
        case .arcade: "bolt.fill"
        }
    }

    var description: String {
        switch self {
        case .standard: "Fixed questions, your pace"
        case .arcade: "60s timer, 3 lives, endless questions"
        }
    }
}
