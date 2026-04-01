import Accessibility
import Geografy_Core_Service
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct ExploreGameSessionScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var gameState: ExploreGameState
    @State private var suggestions: [Country] = []
    @State private var showWrongGuess = false
    @State private var wrongGuessName = ""
    @State private var result: ExploreGameResult?
    @State private var showQuitAlert = false
    @State private var showRules = false

    private let gameService: ExploreGameService
    private let onDismiss: () -> Void

    public init(
        initialState: ExploreGameState,
        gameService: ExploreGameService,
        onDismiss: @escaping () -> Void
    ) {
        _gameState = State(initialValue: initialState)
        self.gameService = gameService
        self.onDismiss = onDismiss
    }

    public var body: some View {
        sessionContent
            .navigationTitle("Mystery Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showRules) { ExploreGameRulesSheet() }
            .alert("Quit Game?", isPresented: $showQuitAlert) {
                quitAlertActions
            } message: {
                Text("Your progress will be lost.")
            }
    }
}

// MARK: - Body Subviews
private extension ExploreGameSessionScreen {
    @ViewBuilder
    var sessionContent: some View {
        if let result {
            ExploreGameResultView(
                result: result,
                onPlayAgain: { handlePlayAgain() },
                onDone: { onDismiss() }
            )
        } else {
            gameplayContent
        }
    }

    var gameplayContent: some View {
        VStack(spacing: 0) {
            scoreHeader
            clueList
            Spacer(minLength: 0)
            bottomControls
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { showRules = true } label: {
                Label("Rules", systemImage: "questionmark.circle")
            }
        }
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { onDismiss() }
    }
}

// MARK: - Score Header
private extension ExploreGameSessionScreen {
    var scoreHeader: some View {
        HStack {
            clueProgress
            Spacer(minLength: 0)
            availablePointsBadge
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    var clueProgress: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        index < gameState.revealedClueCount
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted
                    )
                    .frame(
                        width: DesignSystem.Spacing.xs,
                        height: DesignSystem.Spacing.xs
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Clue \(gameState.revealedClueCount) of 5 revealed")
    }

    var availablePointsBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption2)
                .accessibilityHidden(true)
            Text("\(gameState.currentPointsAvailable) pts")
                .font(DesignSystem.Font.roundedMicro2)
                .contentTransition(.numericText())
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(gameState.currentPointsAvailable) points available")
    }
}

// MARK: - Clue List
private extension ExploreGameSessionScreen {
    var clueList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(
                    Array(gameState.revealedClues.enumerated()),
                    id: \.element.id
                ) { index, clue in
                    ExploreClueCard(
                        clue: clue,
                        isLatest: index == gameState.revealedClueCount - 1
                    )
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8),
                        value: gameState.revealedClueCount
                    )
                }
                wrongGuessBanner
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .readableContentWidth()
        }
    }

    @ViewBuilder
    var wrongGuessBanner: some View {
        if showWrongGuess {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(DesignSystem.Color.error)
                Text("\(wrongGuessName) is not correct. −100 pts")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.error)
            }
            .padding(DesignSystem.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                DesignSystem.Color.error.opacity(0.1),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: showWrongGuess
            )
        }
    }
}

// MARK: - Bottom Controls
private extension ExploreGameSessionScreen {
    var bottomControls: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ExploreGuessField(
                suggestions: suggestions,
                onSearch: { query in
                    suggestions = gameService.searchCountries(query: query)
                },
                onSubmit: { country in handleGuess(country) }
            )
            actionButtons
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    var actionButtons: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if gameState.hasMoreClues {
                Button { revealNextClue() } label: {
                    Label("Next Clue", systemImage: "lightbulb.fill")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                }
                .buttonStyle(.glass)
            }
            Button { revealAnswer() } label: {
                Label("Reveal", systemImage: "eye.fill")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xs)
            }
            .buttonStyle(.glass)
        }
    }
}

// MARK: - Actions
private extension ExploreGameSessionScreen {
    func handleGuess(_ country: Country) {
        let isCorrect = gameState.submitGuess(country.name)
        if isCorrect {
            hapticsService.notification(.success)
            AccessibilityNotification.Announcement("Correct! The country was \(country.name)").post()
            finishGame()
        } else {
            hapticsService.impact(.light)
            wrongGuessName = country.name
            AccessibilityNotification.Announcement("\(country.name) is not correct. Minus 100 points").post()
            showWrongGuess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showWrongGuess = false
            }
        }
    }

    func revealNextClue() {
        gameState.revealNextClue()
    }

    func revealAnswer() {
        gameState.revealAnswer()
        finishGame()
    }

    func finishGame() {
        let gameResult = ExploreGameResult(from: gameState)
        gameService.recordResult(gameResult)
        result = gameResult
    }

    func handlePlayAgain() {
        guard let newState = gameService.makePracticeGame() else { return }
        gameState = newState
        result = nil
        suggestions = []
        showWrongGuess = false
    }
}
