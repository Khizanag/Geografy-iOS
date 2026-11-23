import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct QuizSessionScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) var hapticsService
    @Environment(SoundService.self) var soundService
    @Environment(CountryDataService.self) var countryDataService
    @Environment(Navigator.self) var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public let configuration: QuizConfiguration

    @State var session: QuizSession

    @State var selectedOptionID: UUID?
    @State var showFeedback = false
    @State var timerRemaining: TimeInterval = 0
    @State var timerDeadline: Date?
    @State var timerTask: Task<Void, Never>?
    @State var transition = PendingAction()
    @State private var showQuitAlert = false
    @State private var showFlagPreview = false
    @State var isPaused = false
    @State var navigateToResult: QuizResult?
    @State var isAwaitingNext = false
    @AppStorage(QuizAnswerAdvance.storageKey) var answerAdvance: QuizAnswerAdvance = .always

    @AppStorage("quiz_showAutocomplete") private var showAutocomplete = false
    @State var typingInput: String = ""
    @State var showHint: Bool = false
    @State var typingIsCorrect: Bool = false
    @State var typingWasSkipped = false
    @State var showStreakBurst = false
    @State var streakBurstEnd = PendingAction()

    // Arcade mode
    @State var arcadeTimeRemaining: TimeInterval = 60
    @State var arcadeDeadline: Date?
    @State var arcadeTimerTask: Task<Void, Never>?

    // MARK: - Init
    public init(configuration: QuizConfiguration) {
        self.configuration = configuration
        _session = State(initialValue: QuizSession(configuration: configuration))
    }

    // MARK: - Body
    public var body: some View {
        quizContent
            .navigationTitle(configuration.type.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .hideNavigationCloseButton()
            .task(id: countryDataService.countries.isEmpty) { loadQuiz() }
            .onDisappear {
                stopTimer()
                stopArcadeTimer()
                transition.cancel()
            }
            .navigationDestination(item: $navigateToResult) { result in
                resultsDestination(for: result)
            }
            .alert("Give Up?", isPresented: $showQuitAlert) {
                Button("Give Up", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("Your answers so far won't be saved.")
            }
            .zoomableViewer(isPresented: $showFlagPreview, title: nil) {
                if let flagCode = session.currentQuestion?.promptFlag {
                    ZoomableFlagView(countryCode: flagCode) { showFlagPreview = false }
                }
            }
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
        .safeAreaBar(edge: .bottom) { answerReviewBar }
        .blur(radius: isPaused && !reduceTransparency ? 12 : 0)
        .accessibilityHidden(isPaused)
        .allowsHitTesting(!isPaused)
        .screenBackground()
    }

    @ViewBuilder
    var answerReviewBar: some View {
        if isAwaitingNext, let question = session.currentQuestion {
            AnswerReviewBar(
                country: question.correctCountry,
                nextTitle: isLastAnswer ? "Results" : "Next",
                onShowCountry: { showCountry(question.correctCountry) },
                onNext: { continueAfterAnswer() }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    /// The quiz ends after this answer: the last question, or an arcade game out of lives.
    var isLastAnswer: Bool {
        session.isArcade ? session.isOutOfLives : session.currentIndex + 1 >= session.questions.count
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            LeaveGameButton { showQuitAlert = true }
        }
        if configuration.difficulty.hasTimer {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Pause", systemImage: "pause.fill") { togglePause() }
                    .disabled(showFeedback)
            }
        }
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
            .background(
                DesignSystem.Color.background
                    .opacity(reduceTransparency ? 1 : 0.5)
                    .ignoresSafeArea()
            )
            .transition(.opacity)
        }
    }

    var pauseIcon: some View {
        IconBadge("pause.circle.fill", size: .hero)
            .accessibilityHidden(true)
    }

    var pauseInfo: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Paused")
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("\(Int(timerRemaining.rounded(.up)))s remaining")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text("Question \(session.currentIndex + 1) of \(session.questions.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var resumeButton: some View {
        GlassButton("Resume", systemImage: "play.fill") {
            togglePause()
        }
    }
}

// MARK: - Progress & Question
private extension QuizSessionScreen {
    var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if session.isArcade {
                arcadeHeader
            } else {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SessionProgressBar(progress: session.progress)
                    if session.streak >= 2 {
                        streakBadge
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                    } else {
                        QuestionCounterPill(current: session.currentIndex + 1, total: session.questions.count)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.7), value: session.streak)

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
                    Image(systemName: index < session.lives ? "heart.fill" : "heart")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(
                            index < session.lives
                                ? DesignSystem.Color.error
                                : DesignSystem.Color.error.opacity(DesignSystem.Opacity.soft)
                        )
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Lives")
            .accessibilityValue("\(session.lives) of 3")

            Spacer()

            Text("\(session.arcadeScore)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
                .accessibilityLabel("Score")
                .accessibilityValue("\(session.arcadeScore)")

            Spacer()

            if session.hasArcadeTimer {
                QuizCountdown(deadline: arcadeDeadline, remaining: arcadeTimeRemaining, rounding: .down) { seconds in
                    QuizTimerBadge(seconds: seconds, style: .compact)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var streakBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "flame.fill")
                .font(DesignSystem.Font.roundedNano)
            Text("\(session.streak)×")
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
        .shadow(color: DesignSystem.Color.error.opacity(DesignSystem.Opacity.half), radius: 8, y: 2)
        .scaleEffect(showStreakBurst && !reduceMotion ? 1.25 : 1.0)
        .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.5), value: showStreakBurst)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Streak")
        .accessibilityValue("\(session.streak) in a row")
    }

    var timerPill: some View {
        QuizCountdown(deadline: timerDeadline, remaining: timerRemaining, rounding: .up) { seconds in
            QuizTimerBadge(
                seconds: seconds,
                totalSeconds: Int(configuration.difficulty.timerDuration)
            )
            .opacity(timerPulseOpacity(seconds: seconds))
            .animation(.easeInOut(duration: 0.3), value: seconds)
        }
    }

    @ViewBuilder
    var questionContent: some View {
        if let question = session.currentQuestion {
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
        } else if session.hasLoaded, session.questions.isEmpty {
            EmptyStateView(
                icon: "globe",
                title: "No Questions",
                message: "This quiz has no questions for this region. Pick World or another continent.",
                actionTitle: "Choose a Region"
            ) {
                dismiss()
            }
        }
    }

    var questionTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - Helpers
extension QuizSessionScreen {
    func timerPulseOpacity(seconds: Int) -> Double {
        let threshold = configuration.difficulty.timerDuration * 0.4
        guard Double(seconds) <= threshold else { return 1.0 }
        return seconds.isMultiple(of: 2) ? 0.7 : 1.0
    }
}
