import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Quiz
import SwiftUI

public struct MultiplayerMatchScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let opponent: MockOpponent
    public let configuration: QuizConfiguration
    public let multiplayerService: MultiplayerService

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var selectedOptionID: UUID?
    @State private var showFeedback = false
    @State private var playerScore = 0
    @State private var opponentScore = 0
    @State private var rounds: [MultiplayerRound] = []
    @State private var questionStartTime = Date()
    @State private var opponentEngine = MockOpponentEngine()
    @State private var showQuitAlert = false
    @State private var completedMatch: MultiplayerMatch?

    // MARK: - Body
    public var body: some View {
        matchContent
            .navigationBarTitleDisplayMode(.inline)
            .task { loadMatch() }
            .onDisappear { opponentEngine.cancelPendingAnswer() }
            .fullScreenCover(item: $completedMatch) { match in
                MultiplayerResultScreen(
                    match: match,
                    onRematch: { startRematch() },
                    onDone: { dismiss() },
                )
            }
            .alert("Quit Match?", isPresented: $showQuitAlert) {
                quitAlertActions
            } message: {
                Text("Your progress will be lost.")
            }
    }
}

// MARK: - Subviews
private extension MultiplayerMatchScreen {
    var matchContent: some View {
        VStack(spacing: 0) {
            scoreBar
            progressSection
            questionContent
            Spacer(minLength: 0)
        }
        .screenBackground()
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { dismiss() }
    }
}

// MARK: - Score Bar
private extension MultiplayerMatchScreen {
    var scoreBar: some View {
        HStack(spacing: 0) {
            playerSide
            scoreDivider
            opponentSide
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score")
        .accessibilityValue("You \(playerScore), \(opponent.name) \(opponentScore)")
    }

    var playerSide: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            VStack(alignment: .leading, spacing: 2) {
                Text("You")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Text("\(playerScore)")
                .font(DesignSystem.Font.roundedBody)
                .foregroundStyle(DesignSystem.Color.accent)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }

    var scoreDivider: some View {
        Text(":")
            .font(DesignSystem.Font.roundedCallout)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
    }

    var opponentSide: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(opponentScore)")
                .font(DesignSystem.Font.roundedBody)
                .foregroundStyle(DesignSystem.Color.purple)
                .contentTransition(.numericText())

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(opponent.name)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Progress
private extension MultiplayerMatchScreen {
    var progressSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            progressBar
            QuestionCounterPill(current: currentIndex + 1, total: questions.count)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    var progressBar: some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Color.accent,
                                DesignSystem.Color.accent.opacity(0.7),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometryReader.size.width * progress)
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8),
                        value: progress
                    )
            }
        }
        .frame(height: 6)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("Question \(currentIndex + 1) of \(questions.count)")
    }
}

// MARK: - Question
private extension MultiplayerMatchScreen {
    @ViewBuilder
    var questionContent: some View {
        if let question = currentQuestion {
            MultiplayerRoundView(
                question: question,
                quizType: configuration.type,
                opponentIsThinking: opponentEngine.isThinking,
                opponentHasAnswered: opponentEngine.hasAnswered,
                selectedOptionID: selectedOptionID,
                showFeedback: showFeedback,
                opponentSelectedOptionID: showFeedback
                    ? opponentEngine.selectedOptionID
                    : nil,
                onSelectOption: { selectOption($0) }
            )
            .id(question.id)
            .transition(
                reduceMotion
                    ? .opacity
                    : .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
            )
        }
    }
}

// MARK: - Actions
private extension MultiplayerMatchScreen {
    func loadMatch() {
        let pool = configuration.region.filter(countryDataService.countries)
        let optionCount = max(configuration.difficulty.optionCount, 4)
        guard pool.count >= optionCount else { return }

        questions = QuestionGenerator.generate(
            type: configuration.type,
            countries: pool,
            count: min(
                configuration.questionCount.rawValue,
                pool.count
            ),
            optionCount: optionCount,
        )

        currentIndex = 0
        rounds = []
        playerScore = 0
        opponentScore = 0
        selectedOptionID = nil
        showFeedback = false
        questionStartTime = Date()

        startOpponentThinking()
    }

    func startOpponentThinking() {
        guard let question = currentQuestion else { return }
        opponentEngine.simulateAnswer(
            for: question,
            skillLevel: opponent.skillLevel,
        )
    }

    func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil else { return }

        selectedOptionID = optionID

        let question = questions[currentIndex]
        let isCorrect = optionID == question.correctOptionID
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        if isCorrect {
            hapticsService.notification(.success)
        } else {
            hapticsService.impact(.light)
        }

        waitForOpponentThenShowFeedback(
            playerOptionID: optionID,
            playerIsCorrect: isCorrect,
            playerTimeSpent: timeSpent,
        )
    }

    func waitForOpponentThenShowFeedback(
        playerOptionID: UUID,
        playerIsCorrect: Bool,
        playerTimeSpent: TimeInterval
    ) {
        Task { @MainActor in
            await waitForOpponent()
            processRoundResult(
                playerOptionID: playerOptionID,
                playerIsCorrect: playerIsCorrect,
                playerTimeSpent: playerTimeSpent
            )
            try? await Task.sleep(for: .seconds(1.5))
            advanceToNext()
        }
    }

    func waitForOpponent() async {
        while !opponentEngine.hasAnswered {
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    func processRoundResult(
        playerOptionID: UUID,
        playerIsCorrect: Bool,
        playerTimeSpent: TimeInterval
    ) {
        let question = questions[currentIndex]
        let opponentIsCorrect = opponentEngine.selectedOptionID
            == question.correctOptionID

        let playerAnswer = PlayerAnswer(
            id: UUID(),
            selectedOptionID: playerOptionID,
            isCorrect: playerIsCorrect,
            timeSpent: playerTimeSpent,
        )

        let opponentAnswer = PlayerAnswer(
            id: UUID(),
            selectedOptionID: opponentEngine.selectedOptionID,
            isCorrect: opponentIsCorrect,
            timeSpent: Double.random(in: 1.0...4.0),
        )

        let round = MultiplayerRound(
            id: UUID(),
            questionIndex: currentIndex,
            question: question,
            playerAnswer: playerAnswer,
            opponentAnswer: opponentAnswer,
        )

        rounds.append(round)

        if round.playerWonRound {
            playerScore += 1
        } else if round.opponentWonRound {
            opponentScore += 1
        }
        showFeedback = true
        announceRound(question: question, playerIsCorrect: playerIsCorrect, opponentIsCorrect: opponentIsCorrect)
    }

    func announceRound(question: QuizQuestion, playerIsCorrect: Bool, opponentIsCorrect: Bool) {
        let answer = question.options.first { $0.id == question.correctOptionID }?.text
            ?? question.correctCountry.name
        let playerPart = playerIsCorrect ? "Correct." : "Incorrect. The answer is \(answer)."
        let opponentPart = opponentIsCorrect ? "\(opponent.name) was right." : "\(opponent.name) was wrong."
        let announcement = "\(playerPart) \(opponentPart) You \(playerScore), \(opponent.name) \(opponentScore)."
        AccessibilityNotification.Announcement(announcement).post()
    }

    func advanceToNext() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedOptionID = nil
            showFeedback = false
            questionStartTime = Date()
            opponentEngine.reset()
            startOpponentThinking()
        } else {
            finishMatch()
        }
    }

    func finishMatch() {
        opponentEngine.cancelPendingAnswer()

        let match = multiplayerService.recordMatch(
            opponent: opponent,
            configuration: configuration,
            rounds: rounds,
        )

        completedMatch = match
    }

    func startRematch() {
        completedMatch = nil
        loadMatch()
    }
}

// MARK: - Helpers
private extension MultiplayerMatchScreen {
    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentIndex) / CGFloat(questions.count)
    }
}
