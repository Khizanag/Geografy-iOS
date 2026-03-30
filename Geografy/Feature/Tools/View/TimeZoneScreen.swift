import SwiftUI

struct TimeZoneScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var countryDataService = CountryDataService()

    @State private var selectedTab: TimeZoneTab = .worldClock
    @State private var blobAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            tabContent
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Time Zones")
        .navigationBarTitleDisplayMode(.inline)
        .task { countryDataService.loadCountries() }
        .onAppear {
            guard !reduceMotion else { blobAnimating = true; return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
    }
}

// MARK: - Tab Enum
private extension TimeZoneScreen {
    enum TimeZoneTab: CaseIterable {
        case worldClock
        case allZones
        case quiz

        var label: String {
            switch self {
            case .worldClock: "World Clock"
            case .allZones: "By Zone"
            case .quiz: "Quiz"
            }
        }

        var icon: String {
            switch self {
            case .worldClock: "clock.fill"
            case .allZones: "list.bullet.rectangle"
            case .quiz: "questionmark.circle.fill"
            }
        }
    }
}

// MARK: - Subviews
private extension TimeZoneScreen {
    var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(TimeZoneTab.allCases, id: \.label) { tab in
                    Button {
                        hapticsService.impact(.light)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xxs) {
                            Image(systemName: tab.icon)
                                .font(DesignSystem.Font.caption)
                            Text(tab.label)
                                .font(DesignSystem.Font.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(
                            selectedTab == tab
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.textSecondary
                        )
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xxs + 2)
                        .background(
                            selectedTab == tab
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.cardBackground,
                            in: Capsule()
                        )
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
    }

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .worldClock:
            WorldClockView(countries: countriesWithZones)
        case .allZones:
            AllZonesView(countries: countriesWithZones)
        case .quiz:
            TimeZoneQuizView(countries: countriesWithZones)
        }
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.20), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 36)
                .offset(x: -80, y: -60)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.purple.opacity(0.14), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 40)
                .offset(x: 140, y: 400)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Helpers
private extension TimeZoneScreen {
    var countriesWithZones: [CountryWithZone] {
        countryDataService.countries.compactMap { country in
            guard let zone = CountryTimeZoneData.timeZone(for: country.code) else { return nil }
            return CountryWithZone(country: country, timeZone: zone)
        }
        .sorted { $0.country.name < $1.country.name }
    }
}

// MARK: - CountryWithZone
struct CountryWithZone: Identifiable {
    let country: Country
    let timeZone: TimeZone

    var id: String { country.code }

    var currentTime: Date { Date() }

    var utcOffsetHours: Double {
        Double(timeZone.secondsFromGMT(for: Date())) / 3600
    }

    var utcOffsetLabel: String {
        let hours = utcOffsetHours
        let sign = hours >= 0 ? "+" : ""
        if hours == Double(Int(hours)) {
            return "UTC\(sign)\(Int(hours))"
        }
        let absHours = abs(hours)
        let wholeHours = Int(absHours)
        let minutes = Int((absHours - Double(wholeHours)) * 60)
        return "UTC\(sign)\(wholeHours):\(String(format: "%02d", minutes))"
    }
}

// MARK: - World Clock View
private struct WorldClockView: View {
    let countries: [CountryWithZone]
    @State private var searchText = ""
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        List(filteredCountries) { item in
            worldClockRow(for: item)
                .listRowBackground(DesignSystem.Color.cardBackground)
                .listRowSeparatorTint(DesignSystem.Color.textTertiary.opacity(0.2))
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search country…")
        .onReceive(timer) { date in now = date }
    }

    private var filteredCountries: [CountryWithZone] {
        guard !searchText.isEmpty else { return countries }
        let query = searchText.lowercased()
        return countries.filter { $0.country.name.lowercased().contains(query) }
    }

    private func worldClockRow(for item: CountryWithZone) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: item.country.code, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.country.name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                Text(item.utcOffsetLabel)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(currentTimeString(for: item.timeZone))
                    .font(DesignSystem.Font.monoSmall)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.default, value: now)
                Text(currentDateString(for: item.timeZone))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
    }

    private func currentTimeString(for zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = zone
        return formatter.string(from: now)
    }

    private func currentDateString(for zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        formatter.timeZone = zone
        return formatter.string(from: now)
    }
}

// MARK: - All Zones View
private struct AllZonesView: View {
    let countries: [CountryWithZone]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                ForEach(groupedZones, id: \.offset) { group in
                    zoneGroup(offset: group.offset, countries: group.countries)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    private struct ZoneGroup {
        let offset: Double
        let countries: [CountryWithZone]
    }

    private var groupedZones: [ZoneGroup] {
        var dict: [Double: [CountryWithZone]] = [:]
        for item in countries {
            let offset = item.utcOffsetHours
            dict[offset, default: []].append(item)
        }
        return dict.map { ZoneGroup(offset: $0.key, countries: $0.value.sorted { $0.country.name < $1.country.name }) }
            .sorted { $0.offset < $1.offset }
    }

    private func zoneGroup(offset: Double, countries: [CountryWithZone]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            offsetHeader(offset: offset)
            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(countries.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 44)
                        }
                        zoneCountryRow(for: item)
                    }
                }
            }
        }
    }

    private func offsetHeader(offset: Double) -> some View {
        let sign = offset >= 0 ? "+" : ""
        let label: String
        if offset == Double(Int(offset)) {
            label = "UTC\(sign)\(Int(offset))"
        } else {
            let absHours = abs(offset)
            let wholeHours = Int(absHours)
            let minutes = Int((absHours - Double(wholeHours)) * 60)
            label = "UTC\(sign)\(wholeHours):\(String(format: "%02d", minutes))"
        }

        return HStack(spacing: DesignSystem.Spacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(zoneColor(for: offset))
                .frame(width: 3, height: 18)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    private func zoneCountryRow(for item: CountryWithZone) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: item.country.code, height: 20)
            Text(item.country.name)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Spacer()
            Text(currentTimeString(for: item.timeZone))
                .font(DesignSystem.Font.monoCaption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    private func currentTimeString(for zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = zone
        return formatter.string(from: Date())
    }

    private func zoneColor(for offset: Double) -> Color {
        let colors: [Color] = [
            DesignSystem.Color.blue,
            DesignSystem.Color.indigo,
            DesignSystem.Color.purple,
            DesignSystem.Color.accent,
            DesignSystem.Color.success,
            DesignSystem.Color.warning,
            DesignSystem.Color.orange,
        ]
        let normalized = (offset + 12) / 26
        let index = Int(normalized * Double(colors.count - 1))
        return colors[max(0, min(index, colors.count - 1))]
    }
}

// MARK: - Time Zone Quiz View
private struct TimeZoneQuizView: View {
    let countries: [CountryWithZone]

    @State private var questionPair: (CountryWithZone, CountryWithZone)?
    @State private var choices: [Int] = []
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var totalAnswered = 0
    @State private var answerState: AnswerState = .unanswered

    private enum AnswerState {
        case unanswered, correct, wrong
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                scoreHeader
                if let (countryA, countryB) = questionPair {
                    questionCard(countryA: countryA, countryB: countryB)
                    choicesGrid
                    nextButton
                } else {
                    emptyState
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .onAppear { generateQuestion() }
    }

    private var scoreHeader: some View {
        HStack {
            Label("\(score)/\(totalAnswered)", systemImage: "checkmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.success)
            Spacer()
            Text("Time Difference Quiz")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    private func questionCard(countryA: CountryWithZone, countryB: CountryWithZone) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("What is the time difference?")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                HStack(spacing: DesignSystem.Spacing.lg) {
                    countryTimeCard(for: countryA, color: DesignSystem.Color.accent)
                    Image(systemName: "arrow.left.arrow.right")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    countryTimeCard(for: countryB, color: DesignSystem.Color.blue)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
        }
    }

    private func countryTimeCard(for item: CountryWithZone, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: item.country.code, height: 32)
            Text(item.country.name)
                .font(DesignSystem.Font.caption)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(item.utcOffsetLabel)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(color)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }

    private var choicesGrid: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(choices.enumerated()), id: \.element) { index, choice in
                QuizOptionButton(
                    text: choiceLabel(for: choice),
                    flagCode: nil,
                    state: optionState(for: choice),
                    index: index
                ) {
                    guard selectedAnswer == nil else { return }
                    selectedAnswer = choice
                    if choice == correctAnswer {
                        answerState = .correct
                        score += 1
                    } else {
                        answerState = .wrong
                    }
                    totalAnswered += 1
                }
            }
        }
    }

    private var nextButton: some View {
        Group {
            if selectedAnswer != nil {
                GlassButton("Next Question", systemImage: "arrow.right", fullWidth: true) {
                    generateQuestion()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "clock.badge.questionmark")
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("Not enough countries with time zone data")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
    }

    private func optionState(for choice: Int) -> QuizOptionButton.OptionState {
        guard let selected = selectedAnswer else { return .default }
        let isCorrect = choice == correctAnswer
        if isCorrect { return .correct }
        if choice == selected { return .incorrect }
        return .disabled
    }

    private func choiceLabel(for hours: Int) -> String {
        if hours == 0 {
            "Same time"
        } else {
            "\(abs(hours))h difference"
        }
    }

    private var correctAnswer: Int {
        guard let (a, b) = questionPair else { return 0 }
        return Int(round(b.utcOffsetHours - a.utcOffsetHours))
    }

    private func generateQuestion() {
        selectedAnswer = nil
        answerState = .unanswered

        let available = countries
        guard available.count >= 2 else {
            questionPair = nil
            return
        }

        var countryA: CountryWithZone
        var countryB: CountryWithZone
        repeat {
            countryA = available.randomElement()!
            countryB = available.randomElement()!
        } while countryA.id == countryB.id || countryA.utcOffsetHours == countryB.utcOffsetHours

        questionPair = (countryA, countryB)

        let correct = Int(round(countryB.utcOffsetHours - countryA.utcOffsetHours))
        var wrongChoices = Set<Int>()
        while wrongChoices.count < 3 {
            let candidate = Int.random(in: -12...14)
            if candidate != correct {
                wrongChoices.insert(candidate)
            }
        }
        choices = ([correct] + wrongChoices).shuffled()
    }
}
