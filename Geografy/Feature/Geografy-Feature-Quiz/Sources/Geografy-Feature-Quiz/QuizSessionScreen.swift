import Combine
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct QuizSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) var hapticsService
    @Environment(CountryDataService.self) var countryDataService

    public let configuration: QuizConfiguration

    @State var questions: [QuizQuestion] = []
    @State var currentIndex = 0
    @State var answers: [QuizAnswer] = []
    @State var selectedOptionID: UUID?
    @State var showFeedback = false
    @State var timerRemaining: TimeInterval = 0
    @State var timerCancellable: AnyCancellable?
    @State var startTime = Date()
    @State var questionStartTime = Date()
    @State private var showQuitAlert = false
    @State private var showFlagPreview = false
    @State var isPaused = false
    @State var navigateToResult: QuizResult?

    @AppStorage("quiz_showAutocomplete") private var showAutocomplete = false
    @State var typingInput: String = ""
    @State var showHint: Bool = false
    @State var typingIsCorrect: Bool = false
    @State var typingWasSkipped = false
    @State var currentStreak: Int = 0
    @State var showStreakBurst = false

    // Arcade mode
    @State var arcadeLives = 3
    @State var arcadeScore = 0
    @State var arcadeTimeRemaining: TimeInterval = 60
    @State var arcadeTimerCancellable: AnyCancellable?

    public init(configuration: QuizConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        quizContent
            .navigationTitle(configuration.type.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { loadQuiz() }
            .onDisappear {
                timerCancellable?.cancel()
                arcadeTimerCancellable?.cancel()
            }
            .navigationDestination(item: $navigateToResult) { result in
                resultsDestination(for: result)
            }
            .alert("Quit Quiz?", isPresented: $showQuitAlert) {
                quitAlertActions
            } message: {
                Text("Your progress will be lost.")
            }
            .overlay { flagPreviewOverlay }
            .overlay { pauseOverlay }
    }
}

// MARK: - Subviews
private extension QuizSessionScreen {
    var quizContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            progressSection
            questionContent
            Spacer(minLength: 0)
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .blur(radius: isPaused ? 12 : 0)
        .allowsHitTesting(!isPaused)
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if configuration.difficulty.hasTimer {
            ToolbarItem(placement: .topBarLeading) {
                pauseButton
            }
        }
    }

    var pauseButton: some View {
        Button { togglePause() } label: {
            Image(systemName: "pause.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .buttonStyle(.plain)
        .disabled(showFeedback)
        .opacity(showFeedback ? 0.4 : 1)
        .accessibilityLabel("Pause")
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { dismiss() }
    }

    func resultsDestination(for result: QuizResult) -> some View {
        QuizResultsScreen(
            result: result,
            onPlayAgain: {
                navigateToResult = nil
                loadQuiz()
            },
            onDone: { dismiss() }
        )
    }

    @ViewBuilder
    var flagPreviewOverlay: some View {
        if showFlagPreview, let flagCode = currentQuestion?.promptFlag {
            ZoomableFlagView(countryCode: flagCode) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showFlagPreview = false
                }
            }
        }
    }
}

// MARK: - Pause Overlay
private extension QuizSessionScreen {
    @ViewBuilder
    var pauseOverlay: some View {
        if isPaused {
            VStack(spacing: DesignSystem.Spacing.xl) {
                pauseIcon
                pauseInfo
                resumeButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Color.background.opacity(0.5).ignoresSafeArea())
            .transition(.opacity)
        }
    }

    var pauseIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 80, height: 80)
            Image(systemName: "pause.circle.fill")
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var pauseInfo: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Paused")
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("\(Int(timerRemaining))s remaining")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text("Question \(currentIndex + 1) of \(questions.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var resumeButton: some View {
        Button { togglePause() } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "play.fill")
                Text("Resume")
            }
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(width: 200)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Progress & Question
private extension QuizSessionScreen {
    var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if isArcadeMode {
                arcadeHeader
            } else {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SessionProgressBar(progress: progress)
                    if currentStreak >= 2 {
                        streakBadge
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        QuestionCounterPill(current: currentIndex + 1, total: questions.count)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStreak)

                if configuration.difficulty.hasTimer {
                    timerPill
                }
            }
        }
    }

    var arcadeHeader: some View {
        HStack {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < arcadeLives ? "heart.fill" : "heart")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(
                            index < arcadeLives
                                ? DesignSystem.Color.error
                                : DesignSystem.Color.textTertiary
                        )
                }
            }

            Spacer()

            Text("\(arcadeScore)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())

            Spacer()

            if hasArcadeTimer {
                QuizTimerBadge(seconds: Int(arcadeTimeRemaining), style: .compact)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var streakBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "flame.fill")
                .font(DesignSystem.Font.roundedNano)
            Text("\(currentStreak)×")
                .font(DesignSystem.Font.roundedMicro)
        }
        .foregroundStyle(DesignSystem.Color.onAccent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            LinearGradient(
                colors: [DesignSystem.Color.orange, DesignSystem.Color.error],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: Capsule()
        )
        .shadow(color: DesignSystem.Color.error.opacity(0.4), radius: 8, y: 2)
        .scaleEffect(showStreakBurst ? 1.25 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: showStreakBurst)
    }

    var timerPill: some View {
        QuizTimerBadge(
            seconds: Int(timerRemaining),
            totalSeconds: Int(configuration.difficulty.timerDuration)
        )
        .opacity(timerPulseOpacity)
    }

    @ViewBuilder
    var questionContent: some View {
        if let question = currentQuestion {
            switch configuration.answerMode {
            case .multipleChoice:
                QuizQuestionView(
                    question: question,
                    quizType: configuration.type,
                    selectedOptionID: selectedOptionID,
                    correctOptionID: question.correctOptionID,
                    showFeedback: showFeedback,
                    showFlagPreview: $showFlagPreview,
                    onSelectOption: { optionID in selectOption(optionID) }
                )
                .id(question.id)
                .transition(questionTransition)
            case .typing:
                QuizTypingInputView(
                    question: question,
                    quizType: configuration.type,
                    showFeedback: showFeedback,
                    isCorrectAnswer: typingIsCorrect,
                    showAutocomplete: showAutocomplete,
                    countries: countryDataService.countries,
                    typingInput: $typingInput,
                    showHint: $showHint,
                    showFlagPreview: $showFlagPreview,
                    onSubmit: { submitTypingAnswer() }
                )
                .id(question.id)
                .transition(questionTransition)

            case .spellingBee:
                QuizSpellingBeeView(
                    question: question,
                    quizType: configuration.type,
                    showFeedback: showFeedback,
                    isCorrectAnswer: typingIsCorrect,
                    wasSkipped: typingWasSkipped,
                    typingInput: $typingInput,
                    showFlagPreview: $showFlagPreview,
                    onSubmit: { submitTypingAnswer() },
                    onSkip: { skipSpellingBee() }
                )
                .id(question.id)
                .transition(questionTransition)
            }
        }
    }

    var questionTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - Helpers
extension QuizSessionScreen {
    func isTypingAnswerCorrect(input: String, question: QuizQuestion) -> Bool {
        let normalizedInput = normalizeText(input)
        let lettersOnlyInput = normalizedInput.filter { $0.isLetter }
        return makeAcceptableAnswers(for: question).contains { answer in
            let normalizedAnswer = normalizeText(answer)
            let lettersOnlyAnswer = normalizedAnswer.filter { $0.isLetter }
            return normalizedAnswer == normalizedInput
                || lettersOnlyAnswer == lettersOnlyInput
        }
    }

    func normalizeText(_ string: String) -> String {
        string
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    func spellingBeeCorrectText(for question: QuizQuestion) -> String {
        if let correctOption = question.options.first(where: { $0.id == question.correctOptionID }),
           let text = correctOption.text {
            return text
        }
        return question.correctCountry.name
    }

    func makeAcceptableAnswers(for question: QuizQuestion) -> [String] {
        var answers: [String] = []

        if let correctOption = question.options.first(where: { $0.id == question.correctOptionID }),
           let text = correctOption.text {
            answers.append(text)
        }

        if configuration.type == .capitalQuiz {
            answers += question.correctCountry.allCapitals.map { $0.name }
            answers.append(question.correctCountry.capital)
        }

        answers.append(question.correctCountry.name)

        return answers.filter { !$0.isEmpty }
    }

    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }

    var timerPulseOpacity: Double {
        let threshold = configuration.difficulty.timerDuration * 0.4
        guard timerRemaining <= threshold else { return 1.0 }
        return timerRemaining.truncatingRemainder(dividingBy: 2) < 1 ? 0.7 : 1.0
    }
}
