import SwiftUI

struct TVExploreGameScreen: View {
    let countryDataService: CountryDataService

    @State private var gameState: ExploreGameState?
    @State private var guessText = ""
    @State private var showResult = false
    @State private var suggestions: [Country] = []

    var body: some View {
        Group {
            if let gameState {
                if showResult {
                    resultView(gameState)
                } else {
                    gameView(gameState)
                }
            } else {
                startView
            }
        }
        .navigationTitle("Mystery Country")
    }
}

// MARK: - Start

private extension TVExploreGameScreen {
    var startView: some View {
        VStack(spacing: 40) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Color.accent)

            Text("Mystery Country")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Guess the country from progressive clues.\nFewer clues = more points!")
                .font(.system(size: 24))
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                startNewGame()
            } label: {
                Label("Start Game", systemImage: "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 20)
                    .background(DesignSystem.Color.accent, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.card)
        }
    }
}

// MARK: - Game View

private extension TVExploreGameScreen {
    func gameView(_ state: ExploreGameState) -> some View {
        HStack(alignment: .top, spacing: 60) {
            cluesPanel(state)

            guessPanel(state)
        }
        .padding(60)
    }

    func cluesPanel(_ state: ExploreGameState) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Clues")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer()

                Text("\(state.currentPointsAvailable) pts")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            ForEach(state.revealedClues) { clue in
                HStack(spacing: 16) {
                    Image(systemName: clue.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(DesignSystem.Color.accent)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(clue.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Text(clue.detail)
                            .font(.system(size: 18))
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            }

            if state.hasMoreClues {
                Button {
                    gameState?.revealNextClue()
                } label: {
                    Label("Reveal Next Clue", systemImage: "eye")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.card)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func guessPanel(_ state: ExploreGameState) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Guess")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            TextField("Type country name…", text: $guessText)
                .font(.system(size: 22))
                .onChange(of: guessText) { _, newValue in
                    updateSuggestions(newValue)
                }

            if !suggestions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(suggestions.prefix(6)) { country in
                        Button {
                            submitGuess(country.name)
                        } label: {
                            HStack(spacing: 16) {
                                FlagView(countryCode: country.code, height: 30)

                                Text(country.name)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(DesignSystem.Color.textPrimary)

                                Spacer()
                            }
                            .padding(16)
                            .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.card)
                    }
                }
            }

            if !state.guessHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wrong guesses: \(state.wrongGuessCount)")
                        .font(.system(size: 18))
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }

            Spacer()

            Button {
                gameState?.revealAnswer()
                showResult = true
            } label: {
                Label("Give Up", systemImage: "flag.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.error)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.card)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Result

private extension TVExploreGameScreen {
    func resultView(_ state: ExploreGameState) -> some View {
        VStack(spacing: 40) {
            FlagView(countryCode: state.targetCountry.code, height: 120)

            Text(state.targetCountry.name)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            if state.outcome == .guessedCorrectly {
                Label("Correct!", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.success)

                Text("\(state.finalScore) points · \(state.revealedClueCount) clues used")
                    .font(.system(size: 24))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else {
                Label("Revealed", systemImage: "eye.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            HStack(spacing: 32) {
                Button {
                    startNewGame()
                } label: {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(DesignSystem.Color.accent, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.card)
            }
        }
        .padding(80)
    }
}

// MARK: - Actions

private extension TVExploreGameScreen {
    func startNewGame() {
        guard let country = countryDataService.countries.randomElement() else { return }
        let clues = ClueGenerator.generateClues(for: country)
        gameState = ExploreGameState(targetCountry: country, clues: clues)
        guessText = ""
        suggestions = []
        showResult = false
    }

    func updateSuggestions(_ query: String) {
        guard query.count >= 2 else {
            suggestions = []
            return
        }
        let lowercased = query.lowercased()
        suggestions = countryDataService.countries
            .filter { $0.name.lowercased().contains(lowercased) }
            .sorted { $0.name < $1.name }
    }

    func submitGuess(_ name: String) {
        guard gameState != nil else { return }
        let isCorrect = gameState?.submitGuess(name) ?? false
        if isCorrect {
            showResult = true
        }
        guessText = ""
        suggestions = []
    }
}
