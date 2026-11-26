import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// Today's chain of capitals, one link at a time, asked like a quiz: the capital on top, the countries at the
/// bottom.
public struct CapitalChainView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(SoundService.self) private var soundService
    @Environment(FlashcardService.self) private var flashcardService

    public let content: DailyChallenge.CapitalChainContent

    @Binding var score: Int
    @Binding var currentStep: Int

    public let onFinish: () -> Void

    @State private var questions: [QuizQuestion] = []
    @State private var nextStep = PendingAction()
    @State private var checkedAnswer: CheckedAnswer?
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var showFlagPreview = false

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            SessionProgressView(
                progress: progressFraction,
                current: min(currentStep + 1, content.chainSteps.count),
                total: content.chainSteps.count
            )
            .padding(.horizontal, DesignSystem.Spacing.md)

            if let question = currentQuestion {
                QuizQuestionView(
                    question: question,
                    quizType: .reverseCapital,
                    selectedOptionID: selectedOptionID,
                    correctOptionID: question.correctOptionID,
                    showFeedback: showFeedback,
                    showFlagPreview: $showFlagPreview,
                    onSelectOption: select
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .task { prepareQuestions() }
        .onDisappear { nextStep.cancel() }
        .answerHaptic(checkedAnswer)
    }
}

// MARK: - Helpers
private extension CapitalChainView {
    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentStep) ? questions[currentStep] : nil
    }

    var progressFraction: CGFloat {
        guard !content.chainSteps.isEmpty else { return 0 }
        return CGFloat(currentStep) / CGFloat(content.chainSteps.count)
    }
}

// MARK: - Actions
private extension CapitalChainView {
    func prepareQuestions() {
        questions = content.chainSteps.map { step in
            let options = step.options.map { QuizOption(text: $0.name) }
            let correctIndex = step.options.firstIndex { $0.code == step.expectedCountry.code } ?? 0
            return QuizQuestion(
                promptText: String(
                    localized: "Which country in \(step.continent.displayName) has this capital?",
                    bundle: .module
                ),
                promptSubject: step.expectedCountry.capital,
                options: options,
                correctOptionID: options[correctIndex].id,
                correctCountry: step.expectedCountry
            )
        }
    }

    func select(_ optionID: UUID) {
        guard !showFeedback, let question = currentQuestion else { return }
        selectedOptionID = optionID

        let expected = question.correctCountry
        let isCorrect = optionID == question.correctOptionID
        flashcardService.recordGameAnswer(countryCode: expected.code, type: .capitalToCountry, isCorrect: isCorrect)
        if !isCorrect {
            score = max(0, score - 250)
        }
        checkedAnswer = AnswerFeedback(soundService: soundService).play(
            isCorrect: isCorrect,
            announcement: isCorrect ? nil : AnswerFeedback.incorrectAnnouncement(answer: expected.name)
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }
        nextStep.schedule(after: AnswerFeedback.revealDuration) { advance() }
    }

    func advance() {
        guard currentStep + 1 < content.chainSteps.count else {
            onFinish()
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            currentStep += 1
            selectedOptionID = nil
            showFeedback = false
        }
    }
}
