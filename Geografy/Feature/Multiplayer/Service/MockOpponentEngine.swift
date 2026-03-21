import Foundation

@MainActor
@Observable
final class MockOpponentEngine {
    var hasAnswered = false
    var selectedOptionID: UUID?
    var isThinking = false

    private var answerTask: Task<Void, Never>?
}

// MARK: - Actions

extension MockOpponentEngine {
    func simulateAnswer(
        for question: QuizQuestion,
        skillLevel: Double
    ) {
        reset()
        isThinking = true

        let isCorrect = Double.random(in: 0...1) < skillLevel
        let delay = makeAnswerDelay(isCorrect: isCorrect)

        answerTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(delay))

            guard !Task.isCancelled else { return }
            guard let self else { return }

            let optionID: UUID
            if isCorrect {
                optionID = question.correctOptionID
            } else {
                let wrongOptions = question.options.filter {
                    $0.id != question.correctOptionID
                }
                optionID = wrongOptions.randomElement()?.id ?? question.correctOptionID
            }

            selectedOptionID = optionID
            hasAnswered = true
            isThinking = false
        }
    }

    func reset() {
        answerTask?.cancel()
        answerTask = nil
        hasAnswered = false
        selectedOptionID = nil
        isThinking = false
    }

    func cancelPendingAnswer() {
        answerTask?.cancel()
        answerTask = nil
    }
}

// MARK: - Helpers

private extension MockOpponentEngine {
    func makeAnswerDelay(isCorrect: Bool) -> TimeInterval {
        if isCorrect {
            Double.random(in: 1.0...3.0)
        } else {
            Double.random(in: 2.0...4.0)
        }
    }
}
