import SwiftUI

struct BorderChallengeScreen: View {
    @Environment(\.dismiss) private var dismiss
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
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            mainContent
        }
        .navigationTitle("Border Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleCloseButton { dismiss() }
            }
        }
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

// MARK: - Subviews

private extension BorderChallengeScreen {
    @ViewBuilder
    var mainContent: some View {
        if isGameOver {
            resultContent
        } else if let country = challengeCountry {
            gameContent(country)
        } else {
            ProgressView()
                .tint(DesignSystem.Color.accent)
        }
    }

    func gameContent(_ country: Country) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                difficultySelector
                    .padding(.horizontal, DesignSystem.Spacing.md)
                countryHeader(country)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                progressRow
                    .padding(.horizontal, DesignSystem.Spacing.md)
                timerSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                guessField
                    .padding(.horizontal, DesignSystem.Spacing.md)
                neighborsGrid
                    .padding(.horizontal, DesignSystem.Spacing.md)
                revealButton
                    .padding(.horizontal, DesignSystem.Spacing.md)
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    var difficultySelector: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(BorderChallengeService.Difficulty.allCases, id: \.self) { difficulty in
                difficultyChip(difficulty)
            }
        }
    }

    func difficultyChip(_ difficulty: BorderChallengeService.Difficulty) -> some View {
        Button {
            selectedDifficulty = difficulty
            startNewChallenge()
        } label: {
            Text(difficulty.rawValue)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    selectedDifficulty == difficulty
                        ? DesignSystem.Color.onAccent
                        : DesignSystem.Color.textSecondary
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    selectedDifficulty == difficulty
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.cardBackground,
                    in: Capsule()
                )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    func countryHeader(_ country: Country) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                FlagView(countryCode: country.code, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    .shadow(color: DesignSystem.Color.textPrimary.opacity(0.15), radius: 6, x: 0, y: 3)
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    Text(country.name)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Name all neighboring countries")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }

    var progressRow: some View {
        HStack {
            Text("\(foundNeighbors.count) / \(neighbors.count) neighbors found")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            progressBadge
        }
    }

    var progressBadge: some View {
        let fraction = neighbors.isEmpty ? 0.0 : Double(foundNeighbors.count) / Double(neighbors.count)
        return Text("\(Int(fraction * 100))%")
            .font(DesignSystem.Font.caption)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(DesignSystem.Color.accent, in: Capsule())
    }

    var timerSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "timer")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(timerColor)
            Text(formattedTime)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(timerColor)
                .monospacedDigit()
            timerBar
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            timerColor.opacity(0.08),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var timerBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(DesignSystem.Color.cardBackgroundHighlighted).frame(height: 4)
                Capsule()
                    .fill(timerColor)
                    .frame(width: geometry.size.width * timerFraction, height: 4)
                    .animation(.linear(duration: 1), value: secondsRemaining)
            }
        }
        .frame(height: 4)
    }

    var guessField: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Type a neighboring country...", text: $guessText)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .onSubmit { submitGuess() }
            Button("Submit") { submitGuess() }
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Color.accent, in: Capsule())
                .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
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

        return CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isFound || isRevealing {
                    FlagView(countryCode: neighbor.code, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                        .frame(width: 36, height: 24)
                }
                Text(isFound || isRevealing ? neighbor.name : "?")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isFound
                            ? DesignSystem.Color.success
                            : (isRevealing
                                ? DesignSystem.Color.warning
                                : DesignSystem.Color.textTertiary)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    var revealButton: some View {
        GeoButton("Reveal Remaining Answers", style: .secondary) {
            revealAnswers()
        }
    }

    var resultContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer(minLength: DesignSystem.Spacing.lg)
                resultIcon
                resultTexts
                scoreCard
                xpEarnedBadge
                Spacer(minLength: DesignSystem.Spacing.lg)
                HStack(spacing: DesignSystem.Spacing.md) {
                    GeoButton("Play Again", style: .primary) { startNewChallenge() }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    var resultIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            Image(systemName: resultGradeIcon)
                .font(.system(size: 52))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var resultTexts: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(resultGradeTitle)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if let country = challengeCountry {
                Text("Neighbors of \(country.name): \(foundNeighbors.count) / \(neighbors.count) found")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var scoreCard: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            resultStat(
                value: "\(foundNeighbors.count)",
                label: "Found",
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success
            )
            resultStat(
                value: "\(neighbors.count)",
                label: "Total",
                icon: "globe",
                color: DesignSystem.Color.accent
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
    }

    func resultStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var xpEarnedBadge: some View {
        let earned = service.xpEarned(
            found: foundNeighbors.count,
            total: neighbors.count,
            difficulty: selectedDifficulty
        )
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

// MARK: - Actions

private extension BorderChallengeScreen {
    var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var timerColor: Color {
        if secondsRemaining > 30 { return DesignSystem.Color.success }
        if secondsRemaining > 10 { return DesignSystem.Color.warning }
        return DesignSystem.Color.error
    }

    var timerFraction: CGFloat {
        let total = CGFloat(selectedDifficulty.timeLimit)
        return CGFloat(secondsRemaining) / total
    }

    var resultGradeIcon: String {
        let fraction = neighbors.isEmpty ? 0.0 : Double(foundNeighbors.count) / Double(neighbors.count)
        return switch fraction {
        case 1.0: "trophy.fill"
        case 0.6...: "star.fill"
        case 0.3...: "globe"
        default: "book.fill"
        }
    }

    var resultGradeTitle: String {
        let fraction = neighbors.isEmpty ? 0.0 : Double(foundNeighbors.count) / Double(neighbors.count)
        return switch fraction {
        case 1.0: "Perfect Score!"
        case 0.6...: "Well Done!"
        case 0.3...: "Getting There!"
        default: "Keep Exploring!"
        }
    }

    func startNewChallenge() {
        let countries = countryDataService.countries
        guard let country = service.selectCountry(from: countries, difficulty: selectedDifficulty) else {
            return
        }
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
            hapticsService.impact(.medium)
            if foundNeighbors.count == neighbors.count {
                endGame()
            }
        } else {
            wrongGuesses.insert(input.lowercased())
            hapticsService.notification(.error)
        }
    }

    func revealAnswers() {
        timerActive = false
        withAnimation(.easeInOut(duration: 0.4)) {
            isRevealed = true
        }
        hapticsService.impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            endGame()
        }
    }

    func endGame() {
        timerActive = false
        let xp = service.xpEarned(
            found: foundNeighbors.count,
            total: neighbors.count,
            difficulty: selectedDifficulty
        )
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
