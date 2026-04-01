import Combine
import Geografy_Core_Service
import GeografyCore
import GeografyDesign
import SwiftUI

struct SpeedRunSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(XPService.self) private var xpService
    @Environment(CountryDataService.self) private var countryDataService

    let region: QuizRegion

    @State private var elapsedTime: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var inputText = ""
    @State private var completedCodes: [String] = []
    @State private var flashingCode: String?
    @State private var isFinished = false
    @State private var xpEarned = 0
    @State private var showXPBadge = false
    @State private var showQuitAlert = false
    @State private var showGiveUpAlert = false

    @FocusState private var isInputFocused: Bool

    var body: some View {
        mainContent
            .background { AmbientBlobsView(.quiz) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Speed Run · \(region.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                startTimer()
            }
            .onAppear { isInputFocused = true }
            .onDisappear { timerCancellable?.cancel() }
            .alert("Give Up?", isPresented: $showGiveUpAlert) {
                Button("Give Up", role: .destructive) { finishRun() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("You'll see your results and missed countries.")
            }
            .alert("Quit Speed Run?", isPresented: $showQuitAlert) {
                quitAlertActions
            } message: {
                Text("Your progress will be lost.")
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
                Button { showGiveUpAlert = true } label: {
                    Label("Give Up", systemImage: "flag.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.error)
                }
            }
        }
    }

    var timerSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(formattedTime)
                .font(DesignSystem.Font.monoLarge)
                .foregroundStyle(timerColor)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.1), value: elapsedTime)
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
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            TextField("Type a country name…", text: $inputText)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isInputFocused)
                .onChange(of: inputText) { _, newValue in
                    checkInput(newValue)
                }
                .submitLabel(.done)

            if !inputText.isEmpty {
                Button { inputText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(DesignSystem.Color.accent.opacity(0.3), lineWidth: 1)
        )
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
                                    insertion: .scale(scale: 0.85).combined(with: .opacity),
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
                    withAnimation {
                        proxy.scrollTo(last.code, anchor: .top)
                    }
                }
            }
        }
    }

    func completedRow(country: Country) -> some View {
        let isFlashing = flashingCode == country.code
        return HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                .frame(width: 40, alignment: .center)
            Text(country.name)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.success)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            isFlashing
                ? DesignSystem.Color.success.opacity(0.18)
                : DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
        .animation(.easeInOut(duration: 0.3), value: isFlashing)
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
        .safeAreaInset(edge: .bottom) {
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
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.warning.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "trophy.fill")
                    .font(DesignSystem.Font.displayXS)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .symbolEffect(.bounce)
            }

            Text(completionMessage)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)

            Text(formattedTime)
                .font(DesignSystem.Font.monoMedium)
                .foregroundStyle(DesignSystem.Color.accent)
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
                Text("+\(xpEarned) XP")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.warning.opacity(0.12), in: Capsule())
            .transition(.scale(scale: 0.7).combined(with: .opacity))
        }
    }

    var missedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Missed Countries", icon: "xmark.circle")

            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(missedCountries) { country in
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        FlagView(countryCode: country.code, height: 24, fixedWidth: true)
                            .frame(width: 40, alignment: .center)

                        Text(country.name)
                            .font(DesignSystem.Font.body)
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        DesignSystem.Color.cardBackground,
                        in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    )
                }
            }
        }
    }

    var quitAlertActions: some View {
        Group {
            Button("Quit", role: .destructive) { dismiss() }
            Button("Continue", role: .cancel) {}
        }
    }
}

// MARK: - Actions
private extension SpeedRunSessionScreen {
    func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                if !isFinished {
                    elapsedTime += 0.1
                }
            }
    }

    func checkInput(_ text: String) {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard normalized.count >= 2 else { return }

        guard let match = remainingCountries.first(where: { country in
            normalizeCountryName(country.name) == normalized ||
            alternateNames[country.code]?.contains(normalized) == true
        }) else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            completedCodes.append(match.code)
        }
        inputText = ""
        flashingCode = match.code
        hapticsService.notification(.success)

        Task {
            try? await Task.sleep(for: .milliseconds(700))
            flashingCode = nil
        }

        if completedCodes.count == targetCountries.count {
            finishRun()
        }
    }

    func normalizeCountryName(_ name: String) -> String {
        name.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    func finishRun() {
        timerCancellable?.cancel()
        isFinished = true
        isInputFocused = false
        hapticsService.notification(.success)

        let earned = calculateXP()
        xpEarned = earned
        xpService.award(earned, source: .speedRunCompleted)

        let leaderboardID = speedRunLeaderboardID
        let timeScore = Int(elapsedTime * 10)
        Task {
            await gameCenterService.submitScore(timeScore, to: leaderboardID)
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6)) {
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
        inputText = ""
        elapsedTime = 0
        isFinished = false
        showXPBadge = false
        xpEarned = 0
        flashingCode = nil
        startTimer()
        isInputFocused = true
    }
}

// MARK: - Helpers
private extension SpeedRunSessionScreen {
    var targetCountries: [Country] {
        region.filter(countryDataService.countries)
    }

    var remainingCountries: [Country] {
        targetCountries.filter { !completedCodes.contains($0.code) }
    }

    var missedCountries: [Country] {
        targetCountries
            .filter { !completedCodes.contains($0.code) }
            .sorted { $0.name < $1.name }
    }

    var completedCountries: [Country] {
        completedCodes
            .reversed()
            .compactMap { code in targetCountries.first { $0.code == code } }
    }

    var progressFraction: CGFloat {
        guard !targetCountries.isEmpty else { return 0 }
        return CGFloat(completedCodes.count) / CGFloat(targetCountries.count)
    }

    var formattedTime: String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let tenths = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }

    var timerColor: Color {
        if completedCodes.count == targetCountries.count {
            DesignSystem.Color.success
        } else if elapsedTime > 300 {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.textPrimary
        }
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

    var alternateNames: [String: [String]] {
        [
            "US": ["usa", "united states", "america", "u.s.a.", "u.s."],
            "GB": ["uk", "great britain", "england", "britain", "u.k."],
            "KP": ["north korea"],
            "KR": ["south korea"],
            "CD": ["drc", "democratic republic of congo", "congo dr", "congo drc"],
            "CG": ["republic of congo", "congo republic", "republic of the congo"],
            "CI": ["ivory coast", "cote d'ivoire", "cote divoire"],
            "MM": ["burma"],
            "CZ": ["czech republic"],
            "TL": ["east timor"],
            "FM": ["micronesia"],
            "MK": ["north macedonia", "macedonia"],
            "SS": ["south sudan"],
            "TT": ["trinidad and tobago"],
            "BO": ["bolivia"],
            "VE": ["venezuela"],
            "IR": ["iran"],
            "SY": ["syria"],
            "VN": ["vietnam"],
            "RU": ["russia"],
            "LA": ["laos"],
            "CV": ["cape verde"],
            "EH": ["western sahara"],
            "AE": ["uae", "emirates", "united arab emirates"],
            "XK": ["kosovo"],
        ]
    }
}
