import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SpeedRunSessionScreen: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss
    @Environment(SoundService.self) private var soundService
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let region: QuizRegion

    @State private var targetCountries: [Country] = []
    @State private var nameIndex = SpeedRunNameIndex(countries: [])
    @State private var startDate = Date.now
    @State private var elapsedTime: TimeInterval = 0
    @State private var inputText = ""
    @State private var completedCodes: Set<String> = []
    @State private var completedCountries: [Country] = []
    @State private var flashingCode: String?
    @State private var inputFeedback: AnswerField.Feedback = .none
    @State private var inputMessage: String?
    @State private var rejectedInput: String?
    @State private var rejectionCount = 0
    @State private var isFinished = false
    @State private var xpEarned = 0
    @State private var showGiveUpAlert = false

    @FocusState private var isInputFocused: Bool

    @ScaledMetric(relativeTo: .largeTitle) private var resultTimeFontSize: CGFloat = 40

    // MARK: - Init
    public init(region: QuizRegion) {
        self.region = region
    }

    // MARK: - Body
    public var body: some View {
        mainContent
            .screenBackground()
            .navigationTitle("Speed Run · \(region.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .hideNavigationCloseButton()
            .onAppear { isInputFocused = true }
            .onChange(of: countryDataService.countries.count, initial: true) {
                loadCountries()
            }
            .alert("Give Up?", isPresented: $showGiveUpAlert) {
                Button("Give Up", role: .destructive) { finishRun() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("You'll see your results and missed countries.")
            }
            .haptic(trigger: completedCodes.count) { oldCount, newCount in
                newCount > oldCount ? .success : nil
            }
            .haptic(.error, trigger: rejectionCount)
    }
}

// MARK: - Subviews
private extension SpeedRunSessionScreen {
    var mainContent: some View {
        Group {
            if isFinished {
                resultsView
            } else {
                gameplayView
            }
        }
    }

    var gameplayView: some View {
        VStack(spacing: 0) {
            VStack(spacing: DesignSystem.Spacing.md) {
                timerSection

                progressSection

                completedList
            }
            .padding(.top, DesignSystem.Spacing.sm)

            inputField
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.sm)
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if !isFinished {
            ToolbarItem(placement: .topBarLeading) {
                LeaveGameButton { showGiveUpAlert = true }
            }
        }
    }

    /// The count is in the progress pill below, as in every game.
    var timerSection: some View {
        SpeedRunClock(startDate: startDate, isComplete: isComplete)
            .frame(maxWidth: .infinity)
    }

    var progressSection: some View {
        SessionProgressView(
            progress: progressFraction,
            current: completedCodes.count,
            total: targetCountries.count
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Input & Completed List
private extension SpeedRunSessionScreen {
    var inputField: some View {
        AnswerField(
            String(localized: "Name a country", bundle: .module, in: locale),
            text: $inputText,
            isFocused: $isInputFocused,
            systemImage: "keyboard",
            color: DesignSystem.Color.pink,
            feedback: inputFeedback,
            message: inputMessage,
            showsSendButton: false,
            onSubmit: rejectInput
        )
        .onChange(of: inputText) { _, newValue in
            checkInput(newValue)
        }
    }

    var completedList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(completedCountries) { country in
                        completedRow(country: country)
                            .id(country.code)
                            .transition(
                                .asymmetric(
                                    insertion: reduceMotion ? .opacity : .scale(scale: 0.85).combined(with: .opacity),
                                    removal: .opacity
                                )
                            )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .readableContentWidth()
            }
            .onChange(of: completedCodes.count) { _, _ in
                if let last = completedCountries.first {
                    withAnimation(reduceMotion ? nil : .default) {
                        proxy.scrollTo(last.code, anchor: .top)
                    }
                }
            }
        }
    }

    func completedRow(country: Country) -> some View {
        let isFlashing = flashingCode == country.code
        return CountryListRow(country: country) {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.success)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            isFlashing
                ? DesignSystem.Color.success.opacity(DesignSystem.Opacity.tint)
                : DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isFlashing)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Results
private extension SpeedRunSessionScreen {
    var resultsView: some View {
        GameResultLayout(
            title: Text(completionMessage),
            xpEarned: xpEarned,
            primaryAction: .playAgain { restart() },
            share: resultShare,
            onDone: { dismiss() },
            hero: { resultsHero },
            stats: { resultsStats },
            details: {
                if !missedCountries.isEmpty {
                    missedSection
                }
            }
        )
    }

    var resultShare: ResultShare {
        ResultShare(
            game: String(localized: "Speed Run"),
            score: "\(completedCodes.count)/\(targetCountries.count)",
            caption: SpeedRunClock.formatted(elapsedTime),
            fraction: Double(progressFraction),
            details: [ResultShare.Detail(region.displayName, systemImage: "globe")],
            onShare: achievementService.recordShare
        )
    }

    var resultsHero: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            IconBadge("trophy.fill", color: DesignSystem.Color.warning, size: .hero)
                .symbolEffect(.bounce, isActive: !reduceMotion)
                .accessibilityHidden(true)
            Text(SpeedRunClock.formatted(elapsedTime))
                .font(DesignSystem.Font.system(size: resultTimeFontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(DesignSystem.Color.pink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityLabel("Time")
                .accessibilityValue(SpeedRunClock.spokenValue(elapsedTime, isComplete: isComplete))
        }
    }

    @ViewBuilder
    var resultsStats: some View {
        StatTile(
            value: "\(completedCodes.count)",
            label: "Named",
            icon: "checkmark.circle.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(targetCountries.count - completedCodes.count)",
            label: "Missed",
            icon: "xmark.circle.fill",
            color: DesignSystem.Color.error
        )
        StatTile(
            value: "\(Int(progressFraction * 100))%",
            label: "Done",
            icon: "chart.bar.fill",
            color: DesignSystem.Color.blue
        )
    }

    var missedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Missed Countries", icon: "xmark.circle")

            RowListCard(
                missedCountries,
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagWidth)
            ) { country in
                CountryListRow(country: country)
                    .rowListCardRow()
                    .accessibilityElement(children: .combine)
            }
        }
    }
}

// MARK: - Actions
private extension SpeedRunSessionScreen {
    func loadCountries() {
        targetCountries = region.filter(countryDataService.countries)
        nameIndex = SpeedRunNameIndex(countries: countryDataService.countries)
    }

    func checkInput(_ text: String) {
        let normalized = normalizeInput(text)
        // Return can also accept the keyboard's suggestion; that edit alone shouldn't clear the rejection.
        guard normalized != rejectedInput else { return }
        rejectedInput = nil
        if inputFeedback == .incorrect { inputFeedback = .none }
        inputMessage = isAlreadyNamed(normalized)
            ? String(localized: "Already named", bundle: .module, in: locale)
            : nil
        guard normalized.count >= 2,
              let match = remainingCountry(named: normalized)
        else { return }

        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
            completedCodes.insert(match.code)
            completedCountries.insert(match, at: 0)
        }
        inputText = ""
        inputMessage = nil
        inputFeedback = .correct
        flashingCode = match.code
        soundService.play(.correct)
        let announcement = "\(match.name). \(completedCodes.count) of \(targetCountries.count)."
        AccessibilityNotification.Announcement(announcement).post()

        Task {
            try? await Task.sleep(for: .milliseconds(700))
            flashingCode = nil
            if inputFeedback == .correct { inputFeedback = .none }
        }

        if completedCodes.count == targetCountries.count {
            finishRun()
        }
    }

    /// Return only arrives when nothing matched, so it explains why and keeps the keyboard up.
    func rejectInput() {
        let normalized = normalizeInput(inputText)
        inputMessage = if isAlreadyNamed(normalized) {
            String(localized: "Already named", bundle: .module, in: locale)
        } else if !nameIndex.codes(named: normalized).isEmpty {
            String(localized: "Not in \(region.displayName)", bundle: .module, in: locale)
        } else {
            String(localized: "No country by that name", bundle: .module, in: locale)
        }
        rejectedInput = normalized
        inputFeedback = .incorrect
        rejectionCount += 1
        soundService.play(.wrong)
        isInputFocused = true
        if let inputMessage {
            AccessibilityNotification.Announcement(inputMessage).post()
        }
    }

    func normalizeInput(_ text: String) -> String {
        SpeedRunNameIndex.normalize(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func remainingCountry(named normalized: String) -> Country? {
        let codes = nameIndex.codes(named: normalized)
        guard !codes.isEmpty else { return nil }
        return targetCountries.first { codes.contains($0.code) && !completedCodes.contains($0.code) }
    }

    func isAlreadyNamed(_ normalized: String) -> Bool {
        nameIndex.codes(named: normalized).contains { completedCodes.contains($0) }
    }

    /// Posted in tenths of a second, which the leaderboards show as elapsed time.
    func submitTime() {
        let leaderboardID = speedRunLeaderboardID
        let timeScore = Int(elapsedTime * 10)
        Task {
            await gameCenterService.submitScore(timeScore, to: leaderboardID)
        }
    }

    func finishRun() {
        elapsedTime = Date.now.timeIntervalSince(startDate)
        isFinished = true
        isInputFocused = false

        // Only a run that names every country counts as a personal best or a leaderboard time.
        if isComplete {
            SpeedRunRecords.record(elapsedTime, for: region)
            submitTime()
        }
        achievementService.checkSpeedRunAchievements(
            region: region,
            namedEveryCountry: completedCodes.count == targetCountries.count
        )

        let earned = calculateXP()
        xpEarned = earned
        xpService.award(earned, source: .speedRunCompleted)

        let announcement = "\(completionMessage) Named \(completedCodes.count) of \(targetCountries.count) countries."
        AccessibilityNotification.Announcement(announcement).post()
    }

    func calculateXP() -> Int {
        let completionRate = targetCountries.isEmpty ? 0 : Double(completedCodes.count) / Double(targetCountries.count)
        return XPRules.speedRun(completionRate: completionRate, elapsedSeconds: elapsedTime)
    }

    func restart() {
        completedCodes = []
        completedCountries = []
        inputText = ""
        inputFeedback = .none
        inputMessage = nil
        rejectedInput = nil
        elapsedTime = 0
        isFinished = false
        xpEarned = 0
        flashingCode = nil
        startDate = .now
        isInputFocused = true
    }
}

// MARK: - Helpers
private extension SpeedRunSessionScreen {
    var isComplete: Bool {
        !targetCountries.isEmpty && completedCodes.count == targetCountries.count
    }

    var missedCountries: [Country] {
        targetCountries
            .filter { !completedCodes.contains($0.code) }
            .sorted(by: \.name)
    }

    var progressFraction: CGFloat {
        guard !targetCountries.isEmpty else { return 0 }
        return CGFloat(completedCodes.count) / CGFloat(targetCountries.count)
    }

    var completionMessage: String {
        let fraction = Double(completedCodes.count) / Double(targetCountries.count)
        if fraction >= 1.0 { return "Perfect" }
        if fraction >= 0.8 { return "Impressive" }
        if fraction >= 0.5 { return "Good Run" }
        return "Keep Training"
    }

    var speedRunLeaderboardID: String {
        switch region {
        case .world: GameCenterService.LeaderboardID.speedRunWorld
        case .africa: GameCenterService.LeaderboardID.speedRunAfrica
        case .asia: GameCenterService.LeaderboardID.speedRunAsia
        case .europe: GameCenterService.LeaderboardID.speedRunEurope
        case .northAmerica: GameCenterService.LeaderboardID.speedRunNorthAmerica
        case .southAmerica: GameCenterService.LeaderboardID.speedRunSouthAmerica
        case .oceania: GameCenterService.LeaderboardID.speedRunOceania
        }
    }
}
