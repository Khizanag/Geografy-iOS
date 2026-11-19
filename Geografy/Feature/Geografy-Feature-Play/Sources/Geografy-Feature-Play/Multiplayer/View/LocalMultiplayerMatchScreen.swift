#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// A multiplayer question, drawn by the same question view as a solo quiz: the prompt above, the answers at the
/// bottom within thumb reach. The bar on top keeps both scores and shows whether the other player has answered.
public struct LocalMultiplayerMatchScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(SoundService.self) private var soundService
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Bindable var coordinator: LocalMultiplayerCoordinator

    @State private var selectedOptionID: UUID?
    @State private var answerStartTime = Date()
    @State private var showFlagPreview = false

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            scoreBar
            progressBar
            questionContent
        }
        .screenBackground()
        .navigationTitle(coordinator.activeQuizType.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: coordinator.currentIndex) {
            selectedOptionID = nil
            answerStartTime = Date()
        }
        .zoomableViewer(isPresented: $showFlagPreview, title: nil) {
            if let flagCode = currentQuestion?.promptFlag {
                ZoomableFlagView(countryCode: flagCode) { showFlagPreview = false }
            }
        }
    }
}

// MARK: - Score Bar
private extension LocalMultiplayerMatchScreen {
    var scoreBar: some View {
        HStack(alignment: .top) {
            scorePill(
                label: coordinator.playerName,
                score: coordinator.playerScore,
                color: PairSide.left.color,
                hasAnswered: coordinator.playerAnsweredCurrent
            )
            Spacer()
            QuestionCounterPill(current: coordinator.currentIndex + 1, total: coordinator.questions.count)
            Spacer()
            scorePill(
                label: opponentName,
                score: coordinator.opponentScore,
                color: PairSide.right.color,
                hasAnswered: coordinator.opponentHasAnswered
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.xs)
    }

    func scorePill(label: String, score: Int, color: Color, hasAnswered: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxxs) {
            Text("\(score)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.black)
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            answerState(hasAnswered: hasAnswered)
        }
        .frame(minWidth: 80, maxWidth: 120)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.large))
        .animation(reduceMotion ? nil : .snappy, value: hasAnswered)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(Text("\(score) points, \(hasAnswered ? "answered" : "thinking")"))
    }

    func answerState(hasAnswered: Bool) -> some View {
        Label(
            hasAnswered ? "Answered" : "Thinking",
            systemImage: hasAnswered ? "checkmark.circle.fill" : "ellipsis"
        )
        .labelStyle(.titleAndIcon)
        .font(DesignSystem.Font.caption2)
        .foregroundStyle(hasAnswered ? DesignSystem.Color.success : DesignSystem.Color.textSecondary)
        .symbolEffect(.variableColor.iterative, options: .repeating, isActive: !hasAnswered && !reduceMotion)
        .contentTransition(.symbolEffect(.replace))
    }

    var progressBar: some View {
        SessionProgressBar(
            progress: Double(coordinator.currentIndex + (coordinator.playerAnsweredCurrent ? 1 : 0))
                / Double(max(coordinator.questions.count, 1))
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Question
private extension LocalMultiplayerMatchScreen {
    @ViewBuilder
    var questionContent: some View {
        if let question = currentQuestion {
            QuizQuestionView(
                question: question,
                quizType: coordinator.activeQuizType,
                selectedOptionID: selectedOptionID,
                correctOptionID: question.correctOptionID,
                showFeedback: selectedOptionID != nil,
                showFlagPreview: $showFlagPreview,
                onSelectOption: selectOption
            )
            .id(question.id)
            .transition(.opacity)
        } else {
            Spacer()
        }
    }
}

// MARK: - Helpers
private extension LocalMultiplayerMatchScreen {
    var currentQuestion: QuizQuestion? {
        coordinator.questions.indices.contains(coordinator.currentIndex)
            ? coordinator.questions[coordinator.currentIndex]
            : nil
    }

    var opponentName: String {
        coordinator.opponent?.displayName ?? String(localized: "Opponent", bundle: .module)
    }
}

// MARK: - Actions
private extension LocalMultiplayerMatchScreen {
    func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil, let question = currentQuestion else { return }
        selectedOptionID = optionID
        let isCorrect = optionID == question.correctOptionID
        hapticsService.notification(isCorrect ? .success : .error)
        soundService.play(isCorrect ? .correct : .wrong)
        countInReviews(question: question, isCorrect: isCorrect)
        coordinator.submitAnswer(optionID: optionID, timeSpent: Date().timeIntervalSince(answerStartTime))
        announceAnswer(question: question, isCorrect: isCorrect)
    }

    func countInReviews(question: QuizQuestion, isCorrect: Bool) {
        guard let cardType = FlashcardType(quizType: coordinator.activeQuizType) else { return }
        flashcardService.recordGameAnswer(
            countryCode: question.correctCountry.code,
            type: cardType,
            isCorrect: isCorrect
        )
    }

    func announceAnswer(question: QuizQuestion, isCorrect: Bool) {
        let message: String
        if isCorrect {
            message = String(localized: "Correct.", bundle: .module)
        } else {
            let answer = question.options.first { $0.id == question.correctOptionID }?.text
                ?? question.correctCountry.name
            message = String(localized: "Incorrect. The answer is \(answer).", bundle: .module)
        }
        AccessibilityNotification.Announcement(message).post()
    }
}
#endif
