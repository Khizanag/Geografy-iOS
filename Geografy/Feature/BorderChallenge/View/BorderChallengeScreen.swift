import SwiftUI

struct BorderChallengeScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(XPService.self) private var xpService

    @State private var countryDataService = CountryDataService()
    @State private var selectedDifficulty: BorderChallengeService.Difficulty = .medium
    @State private var challengeCountry: Country?
    @State private var neighbors: [Country] = []
    @State private var foundNeighbors: [Country] = []
    @State private var guessText = ""
    @State private var wrongGuesses: Set<String> = []
    @State private var secondsRemaining = 90
    @State private var timerActive = false
    @State private var isRevealed = false
    @State private var isGameOver = false

    private let service = BorderChallengeService()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if isGameOver {
                resultContent
            } else if challengeCountry != nil {
                gameContent
            } else {
                ProgressView().tint(DesignSystem.Color.accent)
            }
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Border Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard timerActive, !isGameOver else { return }
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                endGame()
            }
        }
        .task {
            countryDataService.loadCountries()
            startNewChallenge()
        }
    }
}

// MARK: - Game Content
private extension BorderChallengeScreen {
    var gameContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                difficultyPicker
                if let country = challengeCountry {
                    countryHeader(country)
                }
                progressSection
                timerSection
                neighborsGrid
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .safeAreaInset(edge: .bottom) {
            guessField
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    var difficultyPicker: some View {
        Picker("Difficulty", selection: $selectedDifficulty) {
            ForEach(BorderChallengeService.Difficulty.allCases, id: \.self) { difficulty in
                Text(difficulty.rawValue).tag(difficulty)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedDifficulty) { _, _ in
            startNewChallenge()
        }
    }

    func countryHeader(_ country: Country) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                FlagView(countryCode: country.code, height: 60)
                    .geoShadow(.subtle)
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Name all neighboring countries")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }

    var progressSection: some View {
        SessionProgressView(
            progress: progressFraction,
            current: foundNeighbors.count,
            total: neighbors.count
        )
    }

    var timerSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "timer")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(timerColor)
            Text(formattedTime)
                .font(DesignSystem.Font.monoBody)
                .foregroundStyle(timerColor)
                .contentTransition(.numericText())
            Spacer()
            if !isRevealed {
                Button {
                    revealAnswers()
                } label: {
                    Text("Reveal")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                }
                .glassEffect(.regular.interactive(), in: .capsule)
            }
        }
    }

    var guessField: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Type a neighbor...", text: $guessText)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .onSubmit { submitGuess() }
            Button { submitGuess() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        guessText.isEmpty
                            ? DesignSystem.Color.textTertiary
                            : DesignSystem.Color.accent
                    )
            }
            .buttonStyle(.plain)
            .disabled(guessText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }

    var neighborsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
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
                FlagView(countryCode: neighbor.code, height: 24)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(width: 36, height: 24)
            }
            Text(isFound || isRevealing ? neighbor.name : "???")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isFound
                        ? DesignSystem.Color.success
                        : (isRevealing ? DesignSystem.Color.warning : DesignSystem.Color.textTertiary)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Result
private extension BorderChallengeScreen {
    var resultContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                resultHeader
                statsCard
                xpBadge
            }
            .padding(DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true) {
                startNewChallenge()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    var resultHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: resultGradeIcon)
                    .font(DesignSystem.Font.displayXS)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            Text(resultGradeTitle)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if let country = challengeCountry {
                Text("\(foundNeighbors.count) of \(neighbors.count) neighbors of \(country.name)")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var statsCard: some View {
        CardView {
            HStack(spacing: 0) {
                ResultStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(foundNeighbors.count)",
                    label: "Found",
                    color: DesignSystem.Color.success
                )
                ResultStatItem(
                    icon: "globe",
                    value: "\(neighbors.count)",
                    label: "Total"
                )
                ResultStatItem(
                    icon: "chart.bar.fill",
                    value: "\(Int(progressFraction * 100))%",
                    label: "Accuracy",
                    color: DesignSystem.Color.indigo
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var xpBadge: some View {
        let earned = service.xpEarned(found: foundNeighbors.count, total: neighbors.count, difficulty: selectedDifficulty)
        return HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.warning)
            Text("+\(earned) XP")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.warning.opacity(0.12), in: Capsule())
    }
}

// MARK: - Helpers
private extension BorderChallengeScreen {
    var progressFraction: CGFloat {
        guard !neighbors.isEmpty else { return 0 }
        return CGFloat(foundNeighbors.count) / CGFloat(neighbors.count)
    }

    var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var timerColor: Color {
        if secondsRemaining > 30 { DesignSystem.Color.success }
        else if secondsRemaining > 10 { DesignSystem.Color.warning }
        else { DesignSystem.Color.error }
    }

    var resultGradeIcon: String {
        let fraction = progressFraction
        return switch fraction {
        case 1.0: "trophy.fill"
        case 0.6...: "star.fill"
        case 0.3...: "globe"
        default: "book.fill"
        }
    }

    var resultGradeTitle: String {
        let fraction = progressFraction
        return switch fraction {
        case 1.0: "Perfect Score!"
        case 0.6...: "Well Done!"
        case 0.3...: "Getting There!"
        default: "Keep Exploring!"
        }
    }
}

// MARK: - Actions
private extension BorderChallengeScreen {
    func startNewChallenge() {
        let countries = countryDataService.countries
        guard let country = service.selectCountry(from: countries, difficulty: selectedDifficulty) else { return }
        challengeCountry = country
        neighbors = service.neighbors(for: country, in: countries)
        foundNeighbors = []
        wrongGuesses = []
        guessText = ""
        secondsRemaining = selectedDifficulty.timeLimit
        isRevealed = false
        isGameOver = false
        timerActive = true
    }

    func submitGuess() {
        let input = guessText.trimmingCharacters(in: .whitespaces)
        guessText = ""
        guard !input.isEmpty else { return }

        let remaining = neighbors.filter { !foundNeighbors.contains($0) }
        if let match = service.isCorrectGuess(input, for: remaining) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                foundNeighbors.append(match)
            }
            hapticsService.notification(.success)
            if foundNeighbors.count == neighbors.count { endGame() }
        } else {
            wrongGuesses.insert(input.lowercased())
            hapticsService.notification(.error)
        }
    }

    func revealAnswers() {
        timerActive = false
        withAnimation(.easeInOut(duration: 0.4)) { isRevealed = true }
        hapticsService.impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { endGame() }
    }

    func endGame() {
        timerActive = false
        let xp = service.xpEarned(found: foundNeighbors.count, total: neighbors.count, difficulty: selectedDifficulty)
        if xp > 0 {
            let source: XPSource = switch selectedDifficulty {
            case .easy: .quizCompletedEasy
            case .medium: .quizCompletedMedium
            case .hard: .quizCompletedHard
            }
            xpService.award(xp, source: source)
        }
        withAnimation { isGameOver = true }
    }
}
