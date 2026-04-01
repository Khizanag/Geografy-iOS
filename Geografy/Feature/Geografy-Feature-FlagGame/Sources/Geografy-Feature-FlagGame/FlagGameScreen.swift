import Accessibility
import Geografy_Core_Service
import Combine
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct FlagGameScreen: View {
    public init() {}
    @Environment(\.dismiss) private var dismiss
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService

    @State private var gameState = FlagGameState()
    @State private var targetCountry: Country?
    @State private var options: [Country] = []
    @State private var selectedAnswer: Country?
    @State private var showFeedback = false
    @State private var timerCancellable: AnyCancellable?

    public var body: some View {
        ZStack {
            if gameState.isFinished {
                FlagGameResultScreen(
                    score: gameState.score,
                    answeredCountries: gameState.answeredCountries,
                    onPlayAgain: restartGame,
                    onDismiss: { dismiss() }
                )
            } else {
                gameContent
            }
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
                Text("\(gameState.score)")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())

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
                        Image(systemName: index < gameState.lives ? "heart.fill" : "heart")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(
                                index < gameState.lives
                                    ? DesignSystem.Color.error
                                    : DesignSystem.Color.textTertiary
                            )
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

        let target = countries.randomElement()!
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
        showFeedback = true

        let isCorrect = country.id == targetCountry?.id

        if isCorrect {
            gameState.score += 10
            if let target = targetCountry {
                gameState.answeredCountries.append(target)
            }
            #if !os(tvOS)
            hapticsService.notification(.success)
            #endif
            AccessibilityNotification.Announcement("Correct!").post()
        } else {
            gameState.lives -= 1
            #if !os(tvOS)
            hapticsService.notification(.error)
            #endif
            AccessibilityNotification.Announcement("Incorrect. \(gameState.lives) lives remaining").post()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if !gameState.isActive {
                timerCancellable?.cancel()
                gameState.isFinished = true
            } else {
                loadNextQuestion()
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
