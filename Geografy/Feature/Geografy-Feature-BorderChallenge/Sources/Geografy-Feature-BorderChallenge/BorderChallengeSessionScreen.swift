import Accessibility
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct BorderChallengeSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    let difficulty: BorderChallengeService.Difficulty
    let region: QuizRegion

    @State private var challengeCountry: Country?
    @State private var neighbors: [Country] = []
    @State private var foundNeighbors: [Country] = []
    @State private var guessText = ""
    @State private var wrongGuesses: Set<String> = []
    @State private var secondsRemaining = 90
    @State private var timerActive = false
    @State private var isRevealed = false
    @State private var showResult = false
    @State private var shakeWrong = false

    private let service = BorderChallengeService()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            mainContent
                .background(DesignSystem.Color.background.ignoresSafeArea())
                .navigationTitle(challengeCountry?.name ?? "Border Challenge")
                #if !os(tvOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar { sessionToolbar }
                .task { startChallenge() }
                .onReceive(timer) { _ in tickTimer() }
                .sheet(isPresented: $showResult) {
                    BorderChallengeResultView(
                        country: challengeCountry,
                        found: foundNeighbors.count,
                        total: neighbors.count,
                        difficulty: difficulty,
                        secondsUsed: totalTime - secondsRemaining,
                        onPlayAgain: {
                            showResult = false
                            startChallenge()
                        },
                        onDone: { dismiss() }
                    )
                }
        }
    }
}

// MARK: - Content
private extension BorderChallengeSessionScreen {
    @ViewBuilder
    var mainContent: some View {
        if challengeCountry != nil {
            gameContent
        } else {
            ProgressView()
                .tint(DesignSystem.Color.accent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var gameContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                countryHeader
                progressAndTimer
                neighborsGrid
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { guessInputBar }
    }
}

// MARK: - Country Header
private extension BorderChallengeSessionScreen {
    @ViewBuilder
    var countryHeader: some View {
        if let country = challengeCountry {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    FlagView(countryCode: country.code, height: 48)
                        .geoShadow(.subtle)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(country.name)
                            .font(DesignSystem.Font.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("\(neighbors.count) neighboring countries")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }

                    Spacer(minLength: 0)

                    QuizTimerBadge(seconds: secondsRemaining, totalSeconds: totalTime)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }
}

// MARK: - Progress & Timer
private extension BorderChallengeSessionScreen {
    var progressAndTimer: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(progress: progressFraction)

            HStack {
                QuestionCounterPill(current: foundNeighbors.count, total: neighbors.count)
                Spacer()
                if !isRevealed {
                    revealButton
                }
            }
        }
    }

    var revealButton: some View {
        Button {
            revealAnswers()
        } label: {
            Label("Reveal All", systemImage: "eye")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

// MARK: - Neighbors Grid
private extension BorderChallengeSessionScreen {
    var neighborsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(neighbors) { neighbor in
                neighborSlot(neighbor)
            }
        }
    }

    func neighborSlot(_ neighbor: Country) -> some View {
        let isFound = foundNeighbors.contains(neighbor)
        let isRevealing = isRevealed && !isFound

        return HStack(spacing: DesignSystem.Spacing.sm) {
            if isFound || isRevealing {
                FlagView(countryCode: neighbor.code, height: 24, fixedWidth: true)
                    .transition(.scale.combined(with: .opacity))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(width: 36, height: 24)
            }

            Text(isFound || isRevealing ? neighbor.name : "???")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(slotColor(isFound: isFound, isRevealing: isRevealing))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)

            if isFound {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.success)
                    .transition(.scale)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            slotBackground(isFound: isFound, isRevealing: isRevealing),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFound)
    }

    func slotColor(isFound: Bool, isRevealing: Bool) -> Color {
        if isFound {
            DesignSystem.Color.success
        } else if isRevealing {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.textTertiary
        }
    }

    func slotBackground(isFound: Bool, isRevealing: Bool) -> Color {
        if isFound {
            DesignSystem.Color.success.opacity(0.08)
        } else if isRevealing {
            DesignSystem.Color.warning.opacity(0.08)
        } else {
            DesignSystem.Color.cardBackground
        }
    }
}

// MARK: - Guess Input
private extension BorderChallengeSessionScreen {
    var guessInputBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            TextField("Type a neighbor...", text: $guessText)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .onSubmit { submitGuess() }

            if !guessText.isEmpty {
                Button { submitGuess() } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(DesignSystem.Color.cardBackgroundHighlighted, lineWidth: 1)
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
        .offset(x: shakeWrong ? -8 : 0)
        .animation(.default, value: guessText.isEmpty)
    }
}

// MARK: - Toolbar
private extension BorderChallengeSessionScreen {
    @ToolbarContentBuilder
    var sessionToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Quit") { dismiss() }
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Actions
private extension BorderChallengeSessionScreen {
    func startChallenge() {
        let countries = region.filter(countryDataService.countries)

        guard let country = service.selectCountry(from: countries, difficulty: difficulty) else {
            dismiss()
            return
        }

        challengeCountry = country
        neighbors = service.neighbors(for: country, in: countryDataService.countries)
        foundNeighbors = []
        wrongGuesses = []
        guessText = ""
        secondsRemaining = difficulty.timeLimit
        isRevealed = false
        showResult = false
        timerActive = true
    }

    func submitGuess() {
        let input = guessText.trimmingCharacters(in: .whitespaces)
        guessText = ""
        guard !input.isEmpty else { return }

        let remaining = neighbors.filter { !foundNeighbors.contains($0) }
        if let match = service.isCorrectGuess(input, for: remaining) {
            foundNeighbors.append(match)
            #if !os(tvOS)
            hapticsService.notification(.success)
            #endif
            AccessibilityNotification.Announcement(
                "Correct! \(match.name). \(foundNeighbors.count) of \(neighbors.count) found"
            )
            .post()

            if foundNeighbors.count == neighbors.count {
                endGame()
            }
        } else {
            wrongGuesses.insert(input.lowercased())
            #if !os(tvOS)
            hapticsService.notification(.error)
            #endif
            shakeInput()
            AccessibilityNotification.Announcement("Incorrect guess").post()
        }
    }

    func revealAnswers() {
        timerActive = false
        isRevealed = true
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { endGame() }
    }

    func endGame() {
        timerActive = false
        saveStats()
        showResult = true
    }

    func tickTimer() {
        guard timerActive, !showResult else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            endGame()
        }
    }

    func shakeInput() {
        Task {
            for _ in 0..<3 {
                shakeWrong = true
                try? await Task.sleep(for: .milliseconds(60))
                shakeWrong = false
                try? await Task.sleep(for: .milliseconds(60))
            }
        }
    }

    func saveStats() {
        let accuracy = neighbors.isEmpty ? 0 : Int(progressFraction * 100)
        let key = "bc_bestScore_\(difficulty.rawValue)"
        let currentBest = UserDefaults.standard.integer(forKey: key)
        if foundNeighbors.count > currentBest {
            UserDefaults.standard.set(foundNeighbors.count, forKey: key)
        }

        let played = UserDefaults.standard.integer(forKey: "bc_gamesPlayed") + 1
        UserDefaults.standard.set(played, forKey: "bc_gamesPlayed")

        let totalAcc = UserDefaults.standard.integer(forKey: "bc_totalAccuracy") + accuracy
        UserDefaults.standard.set(totalAcc, forKey: "bc_totalAccuracy")
    }
}

// MARK: - Helpers
private extension BorderChallengeSessionScreen {
    var progressFraction: CGFloat {
        guard !neighbors.isEmpty else { return 0 }
        return CGFloat(foundNeighbors.count) / CGFloat(neighbors.count)
    }

    var totalTime: Int { difficulty.timeLimit }
}
