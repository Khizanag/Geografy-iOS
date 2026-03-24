import SwiftUI

struct FlagGameScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var countryDataService = CountryDataService()
    @State private var gameState = FlagGameState()
    @State private var targetCountry: Country?
    @State private var options: [Country] = []
    @State private var selectedAnswer: Country?
    @State private var feedbackState: FeedbackState = .none
    @State private var timer: Timer?
    @State private var blobAnimating = false

    var body: some View {
        ZStack {
            backgroundView
            if gameState.isFinished || (!gameState.isActive && gameState.roundNumber > 0) {
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
        .navigationTitle("Flag Game")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            countryDataService.loadCountries()
            startGame()
        }
        .onDisappear { stopTimer() }
    }
}

// MARK: - Subviews

private extension FlagGameScreen {
    var backgroundView: some View {
        DesignSystem.Color.background
            .ignoresSafeArea()
            .overlay {
                ZStack {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [DesignSystem.Color.orange.opacity(0.20), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 220
                            )
                        )
                        .frame(width: 440, height: 340)
                        .blur(radius: 44)
                        .offset(x: -80, y: -200)
                        .scaleEffect(blobAnimating ? 1.10 : 0.90)
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [DesignSystem.Color.indigo.opacity(0.18), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 320)
                        .blur(radius: 48)
                        .offset(x: 160, y: 300)
                        .scaleEffect(blobAnimating ? 0.88 : 1.10)
                }
                .allowsHitTesting(false)
            }
    }

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
            scoreLabel
            HStack {
                Spacer()
                livesView
            }
        }
    }

    var scoreLabel: some View {
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
    }

    var livesView: some View {
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
        .frame(minWidth: 60, alignment: .trailing)
    }

    var countryNameCard: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            timerBar
            CardView {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Which flag belongs to?")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
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
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    var timerBar: some View {
        SessionProgressBar(
            progress: CGFloat(max(0, gameState.timeRemaining) / 60.0)
        )
    }

    var flagGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
        ]
        return LazyVGrid(
            columns: columns,
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(options) { country in
                flagCard(for: country)
            }
        }
    }

    func flagCard(for country: Country) -> some View {
        let state = cardFeedbackState(for: country)
        return CardView {
            FlagView(countryCode: country.code, height: 56)
                .geoShadow(.subtle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .background(cardOverlayColor(for: state))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(cardStrokeColor(for: state), lineWidth: state == .none ? 0 : 2)
        )
        .scaleEffect(state == .correct ? 1.04 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: state)
        .onTapGesture {
            guard feedbackState == .none else { return }
            handleAnswer(country)
        }
        .buttonStyle(PressButtonStyle())
    }

    func cardFeedbackState(for country: Country) -> FeedbackState {
        guard let selected = selectedAnswer else { return .none }
        if country.id == targetCountry?.id { return .correct }
        if country.id == selected.id { return .wrong }
        return .none
    }

    func cardOverlayColor(for state: FeedbackState) -> Color {
        switch state {
        case .none: DesignSystem.Color.cardBackground
        case .correct: DesignSystem.Color.success.opacity(0.85)
        case .wrong: DesignSystem.Color.error.opacity(0.85)
        }
    }

    func cardStrokeColor(for state: FeedbackState) -> Color {
        switch state {
        case .none: .clear
        case .correct: DesignSystem.Color.success
        case .wrong: DesignSystem.Color.error
        }
    }
}

// MARK: - Actions

private extension FlagGameScreen {
    func startGame() {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            blobAnimating = true
        }
        gameState = FlagGameState()
        loadNextQuestion()
        startTimer()
    }

    func restartGame() {
        stopTimer()
        startGame()
    }

    func loadNextQuestion() {
        let countries = countryDataService.countries.filter { !$0.code.isEmpty }
        guard countries.count >= 4 else { return }
        let target = countries.randomElement()!
        var pool = countries.filter { $0.id != target.id }.shuffled()
        let distractors = Array(pool.prefix(3))
        let shuffled = ([target] + distractors).shuffled()
        targetCountry = target
        options = shuffled
        selectedAnswer = nil
        feedbackState = .none
        gameState.roundNumber += 1
    }

    func handleAnswer(_ country: Country) {
        selectedAnswer = country
        let isCorrect = country.id == targetCountry?.id
        feedbackState = isCorrect ? .correct : .wrong

        if isCorrect {
            withAnimation(.spring()) {
                gameState.score += 10
            }
            if let target = targetCountry {
                gameState.answeredCountries.append(target)
            }
        } else {
            withAnimation(.spring()) {
                gameState.lives -= 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if !gameState.isActive {
                stopTimer()
                gameState.isFinished = true
            } else {
                loadNextQuestion()
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard gameState.isActive else {
                stopTimer()
                gameState.isFinished = true
                return
            }
            gameState.timeRemaining = max(0, gameState.timeRemaining - 0.1)
            if gameState.timeRemaining <= 0 {
                stopTimer()
                gameState.isFinished = true
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Feedback State

private extension FlagGameScreen {
    enum FeedbackState: Equatable {
        case none
        case correct
        case wrong
    }
}
