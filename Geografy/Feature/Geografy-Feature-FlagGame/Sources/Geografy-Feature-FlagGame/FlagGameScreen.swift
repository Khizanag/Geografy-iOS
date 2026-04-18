import Accessibility
import Combine
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct FlagGameScreen: View {
    // MARK: - Init
    public init() {}
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService

    @State private var gameState = FlagGameState()
    @State private var targetCountry: Country?
    @State private var options: [Country] = []
    @State private var selectedAnswer: Country?
    @State private var showFeedback = false
    @State private var feedbackWasCorrect = false
    @State private var feedbackTrigger = 0
    @State private var timerCancellable: AnyCancellable?

    // MARK: - Body
    public var body: some View {
        ZStack {
            if gameState.isFinished {
                FlagGameResultScreen(
                    score: gameState.score,
                    answeredCountries: gameState.answeredCountries,
                    onPlayAgain: restartGame,
                    onDismiss: { coordinator.dismiss() }
                )
            } else {
                gameContent
            }

            feedbackOverlay
        }
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Flag Game")
        #if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            startGame()
        }
        .onDisappear { timerCancellable?.cancel() }
    }
}

// MARK: - Game Content
private extension FlagGameScreen {
    var gameContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            scoreAndLivesBar

            countryNameCard

            Spacer(minLength: 0)

            flagGrid
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
    }

    var scoreAndLivesBar: some View {
        ZStack {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                NumericTicker(
                    gameState.score,
                    font: DesignSystem.Font.title2,
                    color: DesignSystem.Color.textPrimary
                )

                Text("Score")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Score: \(gameState.score)")

            HStack {
                Spacer()

                HStack(spacing: DesignSystem.Spacing.xxs) {
                    ForEach(0..<3, id: \.self) { index in
                        let alive = index < gameState.lives
                        Image(systemName: alive ? "heart.fill" : "heart")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(alive ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                            .geoEffect(.streakIncrement(count: gameState.lives))
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(gameState.lives) lives remaining")
            }
        }
    }

    var countryNameCard: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(
                progress: CGFloat(max(0, gameState.timeRemaining) / 60.0)
            )

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Which flag belongs to?")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .accessibilityAddTraits(.isHeader)

                Text(targetCountry?.name ?? " ")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }

    var flagGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, country in
                QuizOptionButton(
                    text: nil,
                    flagCode: country.code,
                    state: optionState(for: country),
                    index: index
                ) {
                    handleAnswer(country)
                }
            }
        }
    }
}

// MARK: - Feedback overlay
private extension FlagGameScreen {
    @ViewBuilder
    var feedbackOverlay: some View {
        if showFeedback {
            VStack {
                Spacer()

                if feedbackWasCorrect {
                    GeoLottieView(.checkmarkSuccess, loopMode: .playOnce) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(DesignSystem.Font.displayXXS)
                            .foregroundStyle(DesignSystem.Color.success)
                    }
                    .frame(width: 120, height: 120)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Font.displayXXS)
                        .foregroundStyle(DesignSystem.Color.error)
                        .geoEffect(.wrongShake(trigger: feedbackTrigger))
                }

                Spacer()
            }
            .allowsHitTesting(false)
            .transition(.scale.combined(with: .opacity))
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Helpers
private extension FlagGameScreen {
    func optionState(for country: Country) -> QuizOptionButton.OptionState {
        guard showFeedback else { return .default }
        if country.id == targetCountry?.id { return .correct }
        if country.id == selectedAnswer?.id { return .incorrect }
        return .disabled
    }
}

// MARK: - Actions
private extension FlagGameScreen {
    func startGame() {
        gameState = FlagGameState()
        loadNextQuestion()
        startTimer()
    }

    func restartGame() {
        timerCancellable?.cancel()
        startGame()
    }

    func loadNextQuestion() {
        let countries = countryDataService.countries.filter { !$0.code.isEmpty }
        guard countries.count >= 4 else { return }

        guard let target = countries.randomElement() else { return }
        let distractors = Array(
            countries
                .filter { $0.id != target.id }
                .shuffled()
                .prefix(3)
        )
        targetCountry = target
        options = ([target] + distractors).shuffled()
        selectedAnswer = nil
        showFeedback = false
        gameState.roundNumber += 1
    }

    func handleAnswer(_ country: Country) {
        guard !showFeedback else { return }
        selectedAnswer = country
        let isCorrect = country.id == targetCountry?.id
        feedbackWasCorrect = isCorrect
        feedbackTrigger += 1

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showFeedback = true
        }

        if isCorrect {
            gameState.score += 10
            if let target = targetCountry {
                gameState.answeredCountries.append(target)
            }
            #if !os(tvOS)
            hapticsService.notification(.success)
            #endif
            SoundService.shared.play(.correct)
            AccessibilityNotification.Announcement("Correct!").post()
        } else {
            gameState.lives -= 1
            #if !os(tvOS)
            hapticsService.notification(.error)
            #endif
            SoundService.shared.play(.wrong)
            AccessibilityNotification.Announcement("Incorrect. \(gameState.lives) lives remaining").post()
        }

        // Advance sooner (0.55s) with a smooth spring so the UI never freezes.
        // Correct answers fade through quickly; wrong answers pause slightly
        // longer so the user sees the correct flag highlighted.
        let delay = isCorrect ? 0.55 : 0.75
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 0.2)) {
                showFeedback = false
            }
            if !gameState.isActive {
                timerCancellable?.cancel()
                gameState.isFinished = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    loadNextQuestion()
                }
            }
        }
    }

    func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard gameState.isActive else {
                    timerCancellable?.cancel()
                    gameState.isFinished = true
                    return
                }
                gameState.timeRemaining = max(0, gameState.timeRemaining - 0.1)
                if gameState.timeRemaining <= 0 {
                    timerCancellable?.cancel()
                    gameState.isFinished = true
                }
            }
    }
}
