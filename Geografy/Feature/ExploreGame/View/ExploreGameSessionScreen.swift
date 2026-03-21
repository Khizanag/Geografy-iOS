import SwiftUI

struct ExploreGameSessionScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var gameState: ExploreGameState
    @State private var suggestions: [Country] = []
    @State private var showWrongGuess = false
    @State private var wrongGuessName = ""
    @State private var result: ExploreGameResult?
    @State private var blobAnimating = false
    @State private var showQuitAlert = false
    @State private var showRules = false

    private let gameService: ExploreGameService
    private let onFinish: (ExploreGameResult) -> Void

    init(
        initialState: ExploreGameState,
        gameService: ExploreGameService,
        onFinish: @escaping (ExploreGameResult) -> Void
    ) {
        _gameState = State(initialValue: initialState)
        self.gameService = gameService
        self.onFinish = onFinish
    }

    var body: some View {
        NavigationStack {
            sessionContent
                .navigationTitle("Mystery Country")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .alert("Quit Game?", isPresented: $showQuitAlert) {
                    quitAlertActions
                } message: {
                    Text("Your progress will be lost.")
                }
                .sheet(isPresented: $showRules) { rulesSheet }
                .onAppear { startBlobAnimation() }
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
                onDone: { dismiss() }
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
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { showRules = true } label: {
                Image(systemName: "questionmark.circle")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .buttonStyle(.plain)
        }
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton { showQuitAlert = true }
        }
    }

    @ViewBuilder
    var quitAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Quit", role: .destructive) { dismiss() }
    }
}

// MARK: - Rules Sheet

private extension ExploreGameSessionScreen {
    var rulesSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    rulesSection(
                        icon: "lightbulb.fill",
                        title: "How to Play",
                        items: [
                            "You'll receive progressive clues about a mystery country",
                            "Use the clues to guess which country it is",
                            "Type the country name and select from suggestions",
                        ]
                    )
                    rulesSection(
                        icon: "star.fill",
                        title: "Scoring",
                        items: [
                            "Start with 1,000 points",
                            "Each new clue revealed costs 200 points",
                            "Each wrong guess costs 100 points",
                            "Guess early with fewer clues for a higher score!",
                        ]
                    )
                    rulesSection(
                        icon: "list.number",
                        title: "Clue Order",
                        items: [
                            "1. Continent (free)",
                            "2. Population range (-200 pts)",
                            "3. Flag colors described (-200 pts)",
                            "4. Capital first letter (-200 pts)",
                            "5. Neighboring countries (-200 pts)",
                        ]
                    )
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GeoCircleCloseButton()
                }
            }
        }
        .presentationDetents([.medium])
    }

    func rulesSection(
        icon: String,
        title: String,
        items: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title, icon: icon)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(DesignSystem.Color.accent)
                            .frame(width: 5, height: 5)
                            .padding(.top, 6)
                        Text(item)
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                }
            }
        }
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
    }

    var availablePointsBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.caption2)
            Text("\(gameState.currentPointsAvailable) pts")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
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
                }
                wrongGuessBanner
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
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

// MARK: - Background

private extension ExploreGameSessionScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.18), .clear],
                    center: .center, startRadius: 0, endRadius: 200
                ))
                .frame(width: 400, height: 300)
                .blur(radius: 40)
                .offset(x: -60, y: -120)
                .scaleEffect(blobAnimating ? 1.08 : 0.92)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.indigo.opacity(0.14), .clear],
                    center: .center, startRadius: 0, endRadius: 160
                ))
                .frame(width: 340, height: 280)
                .blur(radius: 44)
                .offset(x: 120, y: 80)
                .scaleEffect(blobAnimating ? 0.90 : 1.08)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    func startBlobAnimation() {
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
        }
    }
}

// MARK: - Actions

private extension ExploreGameSessionScreen {
    func handleGuess(_ country: Country) {
        let isCorrect = gameState.submitGuess(country.name)
        if isCorrect {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            finishGame()
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            wrongGuessName = country.name
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showWrongGuess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showWrongGuess = false }
            }
        }
    }

    func revealNextClue() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            gameState.revealNextClue()
        }
    }

    func revealAnswer() {
        gameState.revealAnswer()
        finishGame()
    }

    func finishGame() {
        let gameResult = ExploreGameResult(from: gameState)
        gameService.recordResult(gameResult)
        onFinish(gameResult)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            result = gameResult
        }
    }

    func handlePlayAgain() {
        guard let newState = gameService.makePracticeGame() else { return }
        withAnimation {
            gameState = newState
            result = nil
            suggestions = []
            showWrongGuess = false
        }
    }
}
