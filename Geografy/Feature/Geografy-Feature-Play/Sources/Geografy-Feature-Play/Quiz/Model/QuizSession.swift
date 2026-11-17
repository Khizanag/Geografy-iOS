import Foundation
import Geografy_Core_Common

/// One run of a quiz: its questions, the answers given, the streak, and an arcade game's lives and score.
///
/// The rules of play live here, apart from the screen, so they can be tested. `QuizSessionScreen` keeps only
/// what it shows, such as feedback and the typed answer, and the timers, which call in here when they run out.
@Observable
@MainActor
final class QuizSession {
    // MARK: - Properties
    static let arcadeLives = 3
    static let arcadePointsPerCorrect = 10
    /// An endless arcade game draws from at most this many questions.
    static let arcadeQuestionLimit = 100

    let configuration: QuizConfiguration

    private(set) var questions: [QuizQuestion] = []
    /// Set once questions have been built, so an empty list can be told apart from one not built yet.
    private(set) var hasLoaded = false
    private(set) var currentIndex = 0
    private(set) var answers: [QuizAnswer] = []
    /// Right answers in a row, reset by a wrong one.
    private(set) var streak = 0
    private(set) var lives = QuizSession.arcadeLives
    private(set) var arcadeScore = 0
    private(set) var startTime = Date.now
    private(set) var questionStartTime = Date.now

    // MARK: - Init
    init(configuration: QuizConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - State
extension QuizSession {
    var isArcade: Bool { configuration.gameMode == .arcade }
    var hasArcadeTimer: Bool { configuration.arcadeTimer.duration != nil }
    var isOutOfLives: Bool { isArcade && lives <= 0 }

    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    /// The share of questions already behind the player, for the progress bar.
    var progress: Double {
        questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count)
    }

    func correctAnswerText(for question: QuizQuestion) -> String {
        question.options.first { $0.id == question.correctOptionID }?.text ?? question.correctCountry.name
    }
}

// MARK: - Playing
extension QuizSession {
    /// Builds the questions from `countries` and starts over. Does nothing until there are countries, so a quiz
    /// opened at launch waits for them instead of settling on an empty list.
    func load(countries: [Country], now: Date = .now) {
        guard !countries.isEmpty else { return }
        hasLoaded = true
        let pool = configuration.countryCodes.map { codes in
            let wanted = Set(codes)
            return countries.filter { wanted.contains($0.code) }
        } ?? configuration.region.filter(countries)
        let optionCount = max(configuration.difficulty.optionCount, 4)
        questions = []
        if pool.count >= optionCount {
            let questionCount = isArcade
                ? min(Self.arcadeQuestionLimit, pool.count)
                : min(configuration.questionCount.rawValue, pool.count)
            questions = QuestionGenerator.generate(
                type: configuration.type,
                countries: pool,
                count: questionCount,
                optionCount: optionCount,
                comparisonMetric: configuration.comparisonMetric
            )
        }
        currentIndex = 0
        answers = []
        streak = 0
        lives = Self.arcadeLives
        arcadeScore = 0
        startTime = now
        questionStartTime = now
    }

    /// Records a tapped option and says whether it was right.
    @discardableResult
    func answer(option optionID: UUID, now: Date = .now) -> Bool {
        guard let question = currentQuestion else { return false }
        let isCorrect = optionID == question.correctOptionID
        record(question, selectedOptionID: optionID, isCorrect: isCorrect, timeSpent: elapsed(until: now))
        return isCorrect
    }

    /// Records a typed answer and says whether it was right. Case, accents, and punctuation don't count, and a
    /// capital quiz takes any of a country's capitals.
    @discardableResult
    func answer(typed input: String, now: Date = .now) -> Bool {
        guard let question = currentQuestion else { return false }
        let isCorrect = accepts(input, for: question)
        record(
            question,
            selectedOptionID: isCorrect ? question.correctOptionID : nil,
            isCorrect: isCorrect,
            timeSpent: elapsed(until: now)
        )
        return isCorrect
    }

    /// Records giving up on the question, which counts as wrong.
    func skip(now: Date = .now) {
        guard let question = currentQuestion else { return }
        record(question, selectedOptionID: nil, isCorrect: false, timeSpent: elapsed(until: now))
    }

    /// Records the question's time running out, which counts as wrong.
    func timeOut() {
        guard let question = currentQuestion else { return }
        record(question, selectedOptionID: nil, isCorrect: false, timeSpent: configuration.difficulty.timerDuration)
    }

    /// Moves to the next question, or says there's none left.
    func moveToNext(now: Date = .now) -> Bool {
        guard currentIndex + 1 < questions.count else { return false }
        currentIndex += 1
        questionStartTime = now
        return true
    }

    /// The finished quiz. A timed arcade game counts the time it used; any other counts from the start.
    func result(now: Date = .now, arcadeTimeRemaining: TimeInterval = 0) -> QuizResult {
        let totalTime = isArcade
            ? configuration.arcadeTimer.duration.map { $0 - arcadeTimeRemaining } ?? now.timeIntervalSince(startTime)
            : now.timeIntervalSince(startTime)
        return QuizResult(configuration: configuration, answers: answers, totalTime: totalTime)
    }
}

// MARK: - Helpers
private extension QuizSession {
    func record(_ question: QuizQuestion, selectedOptionID: UUID?, isCorrect: Bool, timeSpent: TimeInterval) {
        answers.append(QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: selectedOptionID,
            isCorrect: isCorrect,
            timeSpent: timeSpent
        ))
        if isCorrect {
            streak += 1
            if isArcade { arcadeScore += Self.arcadePointsPerCorrect }
        } else {
            streak = 0
            if isArcade { lives -= 1 }
        }
    }

    func elapsed(until now: Date) -> TimeInterval {
        now.timeIntervalSince(questionStartTime)
    }

    func accepts(_ input: String, for question: QuizQuestion) -> Bool {
        let typed = Self.normalized(input)
        let typedLetters = typed.filter(\.isLetter)
        return acceptableAnswers(for: question).contains { answer in
            let normalizedAnswer = Self.normalized(answer)
            return normalizedAnswer == typed || normalizedAnswer.filter(\.isLetter) == typedLetters
        }
    }

    func acceptableAnswers(for question: QuizQuestion) -> [String] {
        var answers: [String] = []
        if let text = question.options.first(where: { $0.id == question.correctOptionID })?.text {
            answers.append(text)
        }
        if configuration.type == .capitalQuiz {
            answers += question.correctCountry.allCapitals.map(\.name)
            answers.append(question.correctCountry.capital)
        }
        answers.append(question.correctCountry.name)
        return answers.filter { !$0.isEmpty }
    }

    static func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}
