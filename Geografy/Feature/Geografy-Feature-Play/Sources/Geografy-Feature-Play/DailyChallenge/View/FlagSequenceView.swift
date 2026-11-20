import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// Today's flags, one at a time, asked like a flag quiz: the flag on top, the names at the bottom.
public struct FlagSequenceView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(HapticsService.self) private var hapticsService
    @Environment(SoundService.self) private var soundService
    @Environment(FlashcardService.self) private var flashcardService

    public let content: DailyChallenge.FlagSequenceContent
    public let seed: UInt64

    @Binding var score: Int
    @Binding var currentIndex: Int

    public let onFinish: () -> Void

    @State private var questions: [QuizQuestion] = []
    @State private var nextStep = PendingAction()
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var showFlagPreview = false

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            SessionProgressView(
                progress: progressFraction,
                current: min(currentIndex + 1, content.countries.count),
                total: content.countries.count
            )
            .padding(.horizontal, DesignSystem.Spacing.md)

            if let question = currentQuestion {
                QuizQuestionView(
                    question: question,
                    quizType: .flagQuiz,
                    selectedOptionID: selectedOptionID,
                    correctOptionID: question.correctOptionID,
                    showFeedback: showFeedback,
                    showFlagPreview: $showFlagPreview,
                    onSelectOption: select
                )
                .id(question.id)
                .transition(questionTransition)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .zoomableViewer(isPresented: $showFlagPreview, title: nil) {
            if let flagCode = currentQuestion?.promptFlag {
                ZoomableFlagView(countryCode: flagCode) { showFlagPreview = false }
            }
        }
        .task { prepareQuestions() }
        .onDisappear { nextStep.cancel() }
    }
}

// MARK: - Helpers
private extension FlagSequenceView {
    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var progressFraction: CGFloat {
        guard !content.countries.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(content.countries.count)
    }

    var questionTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - Actions
private extension FlagSequenceView {
    /// Seeded, so everyone gets the same answers in the same order today.
    func prepareQuestions() {
        let allCountries = content.countries
        questions = allCountries.enumerated().map { index, country in
            let distractors = allCountries
                .filter { $0.code != country.code }
                .seededShuffle(seed: seed &+ UInt64(index) &* 7_919)
                .prefix(3)
            let options = ([country] + distractors)
                .seededShuffle(seed: seed &+ UInt64(index) &* 3_571)
                .map { QuizOption(text: $0.name) }
            let correctID = options[options.firstIndex { $0.text == country.name } ?? 0].id
            return QuizQuestion(
                promptText: String(localized: "Which country does this flag belong to?", bundle: .module),
                promptFlag: country.code,
                options: options,
                correctOptionID: correctID,
                correctCountry: country
            )
        }
    }

    func select(_ optionID: UUID) {
        guard !showFeedback, let question = currentQuestion else { return }
        selectedOptionID = optionID

        let correct = question.correctCountry
        let isCorrect = optionID == question.correctOptionID
        flashcardService.recordGameAnswer(countryCode: correct.code, type: .flagToCountry, isCorrect: isCorrect)
        if !isCorrect {
            score = max(0, score - 200)
        }
        AnswerFeedback(soundService: soundService, hapticsService: hapticsService).play(
            isCorrect: isCorrect,
            announcement: isCorrect ? nil : AnswerFeedback.incorrectAnnouncement(answer: correct.name)
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }
        nextStep.schedule(after: AnswerFeedback.revealDuration) { advance() }
    }

    func advance() {
        guard currentIndex + 1 < content.countries.count else {
            onFinish()
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            currentIndex += 1
            selectedOptionID = nil
            showFeedback = false
        }
    }
}
