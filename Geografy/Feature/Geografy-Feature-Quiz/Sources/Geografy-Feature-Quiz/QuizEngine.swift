import Combine
import Foundation
import Geografy_Core_Common

@Observable
public final class QuizEngine {
    public var questions: [QuizQuestion] = []
    public var currentIndex = 0
    public var answers: [QuizAnswer] = []
    public var selectedOptionID: UUID?
    public var state: QuizState = .setup
    public var timerRemaining: TimeInterval = 0

    private var questionStartTime = Date()
    private var quizStartTime = Date()
    private var timerCancellable: AnyCancellable?
}

// MARK: - QuizState
public enum QuizState {
    case setup
    case answering
    case showingFeedback(isCorrect: Bool)
    case finished
}

// MARK: - Computed Properties
extension QuizEngine {
    public var currentQuestion: QuizQuestion? {
        guard currentIndex >= 0, currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    public var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    public var isLastQuestion: Bool {
        currentIndex >= questions.count - 1
    }
}

// MARK: - Actions
extension QuizEngine {
    public func start(config: QuizConfiguration, countries: [Country]) {
        let filtered = config.region.filter(countries)

        questions = QuestionGenerator.generate(
            type: config.type,
            countries: filtered,
            count: config.questionCount.rawValue,
            optionCount: config.difficulty.optionCount,
        )

        currentIndex = 0
        answers = []
        selectedOptionID = nil
        quizStartTime = Date()
        questionStartTime = Date()
        state = .answering

        if config.difficulty.hasTimer {
            startTimer(duration: config.difficulty.timerDuration)
        }
    }

    public func selectAnswer(_ optionID: UUID) {
        guard case .answering = state, let question = currentQuestion else { return }

        selectedOptionID = optionID
        let isCorrect = optionID == question.correctOptionID
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: optionID,
            isCorrect: isCorrect,
            timeSpent: timeSpent,
        )

        answers.append(answer)
        stopTimer()
        state = .showingFeedback(isCorrect: isCorrect)
    }

    public func nextQuestion() {
        guard currentIndex < questions.count - 1 else {
            state = .finished
            return
        }

        currentIndex += 1
        selectedOptionID = nil
        questionStartTime = Date()
        state = .answering
    }

    public func buildResult(config: QuizConfiguration) -> QuizResult {
        let totalTime = Date().timeIntervalSince(quizStartTime)

        return QuizResult(
            configuration: config,
            answers: answers,
            totalTime: totalTime,
        )
    }
}

// MARK: - Timer
private extension QuizEngine {
    func startTimer(duration: TimeInterval) {
        timerRemaining = duration

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard case .answering = state else {
                    stopTimer()
                    return
                }

                timerRemaining -= 1

                if timerRemaining <= 0 {
                    handleTimerExpired()
                }
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func handleTimerExpired() {
        guard let question = currentQuestion else { return }

        let timeSpent = Date().timeIntervalSince(questionStartTime)

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: nil,
            isCorrect: false,
            timeSpent: timeSpent,
        )

        answers.append(answer)
        stopTimer()
        state = .showingFeedback(isCorrect: false)
    }
}
