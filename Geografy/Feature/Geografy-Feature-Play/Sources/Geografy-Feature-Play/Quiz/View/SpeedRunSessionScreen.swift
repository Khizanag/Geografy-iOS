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
    @Environment(AchievementService.self) var achievementService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(Navigator.self) var coordinator
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public let region: QuizRegion
    /// Set when racing another phone; the match's own result screen and Give Up then replace the solo ones.
    let match: (any LocalMatch)?

    @AppStorage(SpeedRunMap.storageKey) private var showsMap = false

    @State var targetCountries: [Country] = []
    @State private var nameIndex = SpeedRunNameIndex(countries: [])
    @State private var startDate = Date.now
    @State var elapsedTime: TimeInterval = 0
    @State private var inputText = ""
    @State var completedCodes: Set<String> = []
    @State private var completedCountries: [Country] = []
    @State private var flashingCode: String?
    /// The named country tapped in the list, picked out on the map.
    @State private var highlightedCode: String?
    @State private var inputFeedback: AnswerField.Feedback = .none
    @State private var inputMessage: String?
    @State private var rejectedInput: String?
    @State private var rejectionCount = 0
    @State private var isFinished = false
    @State private var xpEarned = 0
    @State private var showGiveUpAlert = false

    @FocusState private var isInputFocused: Bool

    @ScaledMetric(relativeTo: .largeTitle) var resultTimeFontSize: CGFloat = 40

    // MARK: - Init
    public init(region: QuizRegion) {
        self.init(region: region, match: nil)
    }

    /// Plays a multiplayer race when `match` is set: reports each named country and gives no solo rewards.
    init(region: QuizRegion, match: (any LocalMatch)?) {
        self.region = region
        self.match = match
    }

    // MARK: - Body
    public var body: some View {
        mainContent
            .screenBackground()
            .navigationTitle("Speed Run · \(region.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            // A match brings its own Give Up; on its own, Give Up replaces the cover's close button.
            .hideNavigationCloseButton(match == nil)
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
            .haptic(.selection, trigger: highlightedCode)
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

                if let match {
                    matchChip(match)
                }

                progressSection

                if showsMap {
                    SpeedRunMap(
                        region: region,
                        countries: targetCountries,
                        namedCodes: completedCodes,
                        highlightedCode: highlightedCode
                    )
                    .padding(.horizontal, DesignSystem.Spacing.md)
                }

                completedList
            }
            .padding(.top, DesignSystem.Spacing.sm)
        }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if match == nil, !isFinished {
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

    /// No waiting state: the first player to name every country ends the race for both.
    func matchChip(_ match: any LocalMatch) -> some View {
        MatchOpponentChip(
            name: match.opponentName,
            score: "\(match.opponentScore)/\(targetCountries.count)",
            status: String(localized: "Racing", bundle: .module),
            systemImage: "hare.fill"
        )
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
            // The named countries scroll under the field, softened by the bar's edge effect, as under any bar.
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .safeAreaBar(edge: .bottom) {
                inputField
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.sm)
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

    /// A glass capsule. With the map showing, a tap picks its country out there, and again lets it go; a country
    /// just named flashes green, and the one picked out takes the map's colour.
    @ViewBuilder
    func completedRow(country: Country) -> some View {
        let isHighlighted = highlightedCode == country.code
        if showsMap {
            Button {
                withAnimation(reduceMotion ? nil : .snappy) {
                    highlightedCode = isHighlighted ? nil : country.code
                }
            } label: {
                completedRowLabel(country: country, isHighlighted: isHighlighted)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("Shows it on the map", bundle: .module))
            .accessibilityAddTraits(isHighlighted ? .isSelected : [])
        } else {
            completedRowLabel(country: country, isHighlighted: false)
        }
    }

    func completedRowLabel(country: Country, isHighlighted: Bool) -> some View {
        let isFlashing = flashingCode == country.code
        let tint: Color? = if isFlashing {
            DesignSystem.Color.success
        } else if isHighlighted {
            SpeedRunMap.highlightColor
        } else {
            nil
        }
        return CountryListRow(country: country) {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.success)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .contentShape(.capsule)
        .glassEffect(
            .regular.tint(tint?.opacity(DesignSystem.Opacity.soft)).interactive(showsMap),
            in: .capsule
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
                if showsMap {
                    SpeedRunMap(region: region, countries: targetCountries, namedCodes: completedCodes)
                }
                if !missedCountries.isEmpty {
                    missedSection
                }
                if !namedCountries.isEmpty {
                    namedSection
                }
            }
        )
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
              let country = remainingCountry(named: normalized)
        else { return }

        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
            completedCodes.insert(country.code)
            completedCountries.insert(country, at: 0)
        }
        match?.didScore(round: matchRound(for: country), points: 1)
        inputText = ""
        inputMessage = nil
        inputFeedback = .correct
        flashingCode = country.code
        soundService.play(.correct)
        let announcement = "\(country.name). \(completedCodes.count) of \(targetCountries.count)."
        AccessibilityNotification.Announcement(announcement).post()

        Task {
            try? await Task.sleep(for: .milliseconds(700))
            flashingCode = nil
            if inputFeedback == .correct { inputFeedback = .none }
        }

        if completedCodes.count == targetCountries.count {
            if let match {
                isInputFocused = false
                match.didFinishRounds()
            } else {
                finishRun()
            }
        }
    }

    /// The country's place in the region sorted by code, which both phones agree on whatever their language.
    func matchRound(for country: Country) -> Int {
        targetCountries.map(\.code).sorted().firstIndex(of: country.code) ?? 0
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
