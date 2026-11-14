import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SpeedRunSessionScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(XPService.self) private var xpService
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
    @State private var isFinished = false
    @State private var xpEarned = 0
    @State private var showXPBadge = false
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
                GiveUpButton { showGiveUpAlert = true }
            }
        }
    }

    var timerSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            SpeedRunClock(startDate: startDate, isComplete: isComplete)
            Text("\(completedCodes.count) of \(targetCountries.count) countries")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
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
            String(localized: "Name a country", bundle: .module),
            text: $inputText,
            isFocused: $isInputFocused,
            systemImage: "keyboard",
            color: DesignSystem.Color.error,
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
                ? DesignSystem.Color.success.opacity(0.18)
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
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                resultsHeader

                resultsStats

                xpBadge

                if !missedCountries.isEmpty {
                    missedSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
        .safeAreaBar(edge: .bottom) {
            resultsActions
        }
    }

    var resultsActions: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Try Again", systemImage: "arrow.counterclockwise", fullWidth: true) {
                restart()
            }

            GlassButton("Done", systemImage: "checkmark", fullWidth: true) {
                dismiss()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    var resultsHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            IconBadge("trophy.fill", color: DesignSystem.Color.warning, size: .hero)
                .symbolEffect(.bounce, isActive: !reduceMotion)
                .accessibilityHidden(true)

            Text(completionMessage)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(SpeedRunClock.formatted(elapsedTime))
                .font(DesignSystem.Font.system(size: resultTimeFontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(DesignSystem.Color.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityLabel("Time")
                .accessibilityValue(SpeedRunClock.spokenValue(elapsedTime, isComplete: isComplete))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.xl)
    }

    var resultsStats: some View {
        CardView {
            HStack(spacing: 0) {
                ResultStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(completedCodes.count)",
                    label: "Named",
                    color: DesignSystem.Color.success
                )
                ResultStatItem(
                    icon: "globe",
                    value: "\(targetCountries.count - completedCodes.count)",
                    label: "Missed",
                    color: DesignSystem.Color.error
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

    @ViewBuilder
    var xpBadge: some View {
        if showXPBadge, xpEarned > 0 {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "star.fill")
                    .foregroundStyle(DesignSystem.Color.warning)
                    .accessibilityHidden(true)
                Text("+\(xpEarned) XP")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.warning.opacity(0.12), in: Capsule())
            .transition(reduceMotion ? .opacity : .scale(scale: 0.7).combined(with: .opacity))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Earned \(xpEarned) XP")
        }
    }

    var missedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Missed Countries", icon: "xmark.circle")

            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(missedCountries) { country in
                    CardView(cornerRadius: DesignSystem.CornerRadius.small) {
                        CountryListRow(country: country)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                    }
                    .accessibilityElement(children: .combine)
                }
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
            ? String(localized: "Already named", bundle: .module)
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
        hapticsService.notification(.success)
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
            String(localized: "Already named", bundle: .module)
        } else if !nameIndex.codes(named: normalized).isEmpty {
            String(localized: "Not in \(region.displayName)", bundle: .module)
        } else {
            String(localized: "No country by that name", bundle: .module)
        }
        rejectedInput = normalized
        inputFeedback = .incorrect
        hapticsService.notification(.error)
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

    func finishRun() {
        elapsedTime = Date.now.timeIntervalSince(startDate)
        isFinished = true
        isInputFocused = false
        hapticsService.notification(.success)

        // Only a run that names every country counts as a personal best.
        if completedCodes.count == targetCountries.count {
            SpeedRunRecords.record(elapsedTime, for: region)
        }

        let earned = calculateXP()
        xpEarned = earned
        xpService.award(earned, source: .speedRunCompleted)

        let leaderboardID = speedRunLeaderboardID
        let timeScore = Int(elapsedTime * 10)
        Task {
            await gameCenterService.submitScore(timeScore, to: leaderboardID)
        }

        let announcement = "\(completionMessage) Named \(completedCodes.count) of \(targetCountries.count) countries."
        AccessibilityNotification.Announcement(announcement).post()

        withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7).delay(0.6)) {
            showXPBadge = true
        }
    }

    func calculateXP() -> Int {
        let completionRate = Double(completedCodes.count) / Double(targetCountries.count)
        let base = 50
        let completionBonus = Int(completionRate * 100)
        let speedBonus: Int = switch elapsedTime {
        case ..<60: 100
        case ..<120: 60
        case ..<300: 30
        case ..<600: 15
        default: 5
        }
        return base + completionBonus + speedBonus
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
        showXPBadge = false
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
        if fraction >= 1.0 { return "Perfect!" }
        if fraction >= 0.8 { return "Impressive!" }
        if fraction >= 0.5 { return "Good Run!" }
        return "Keep Training!"
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
