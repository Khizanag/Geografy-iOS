import SwiftUI

struct DailyChallengeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(XPService.self) private var xpService

    @State private var countryDataService = CountryDataService()
    @State private var service: DailyChallengeService?
    @State private var showSession = false
    @State private var blobAnimating = false

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Daily Challenge")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task { loadData() }
                .onAppear { startBlobAnimation() }
                .fullScreenCover(isPresented: $showSession) {
                    sessionCover
                }
        }
    }
}

// MARK: - Toolbar

private extension DailyChallengeScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton()
        }
    }
}

// MARK: - Content

private extension DailyChallengeScreen {
    var contentView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                challengeHeader
                if let service {
                    streakSection(service: service)
                    todayChallengeCard(service: service)
                    countdownSection
                    historySection(service: service)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    var sessionCover: some View {
        Group {
            if let challenge = service?.todayChallenge, let service {
                DailyChallengeSessionScreen(
                    challenge: challenge,
                    service: service
                )
            }
        }
    }
}

// MARK: - Header

private extension DailyChallengeScreen {
    var challengeHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            headerIcon
            Text("Daily Challenge")
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(formattedDate)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    var headerIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.15))
                .frame(
                    width: DesignSystem.Size.xxxl,
                    height: DesignSystem.Size.xxxl
                )
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 28))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Streak Section

private extension DailyChallengeScreen {
    func streakSection(service: DailyChallengeService) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                streakIcon(streak: service.streak)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Challenge Streak")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(service.streak) day\(service.streak == 1 ? "" : "s")")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    func streakIcon(streak: Int) -> some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.orange.opacity(0.15))
                .frame(
                    width: DesignSystem.Size.xl,
                    height: DesignSystem.Size.xl
                )
            Image(systemName: "flame.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.orange)
        }
    }
}

// MARK: - Today's Challenge Card

private extension DailyChallengeScreen {
    func todayChallengeCard(service: DailyChallengeService) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Today's Challenge")
            if let challenge = service.todayChallenge {
                challengeCardContent(
                    challenge: challenge,
                    completed: service.hasCompletedToday,
                    result: service.todayResult
                )
            }
        }
    }

    func challengeCardContent(
        challenge: DailyChallenge,
        completed: Bool,
        result: DailyChallengeResult?
    ) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                challengeTypeRow(challenge: challenge)
                if completed, let result {
                    completedResultRow(result: result)
                } else {
                    startChallengeButton
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    func challengeTypeRow(challenge: DailyChallenge) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            challengeTypeIcon(challenge: challenge)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(challenge.type.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(challenge.type.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
    }

    func challengeTypeIcon(challenge: DailyChallenge) -> some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.indigo.opacity(0.15))
                .frame(
                    width: DesignSystem.Size.xl,
                    height: DesignSystem.Size.xl
                )
            Image(systemName: challenge.type.iconName)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.indigo)
        }
    }

    func completedResultRow(result: DailyChallengeResult) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            resultStat(
                label: "Score",
                value: "\(result.score)/\(result.maxScore)",
                color: DesignSystem.Color.accent
            )
            resultStat(
                label: "Time",
                value: formatTime(result.timeSpentSeconds),
                color: DesignSystem.Color.warning
            )
            completedBadge
        }
    }

    func resultStat(
        label: String,
        value: String,
        color: Color
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(value)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var completedBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.caption)
            Text("Done")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.success)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.success.opacity(0.15),
            in: Capsule()
        )
    }

    var startChallengeButton: some View {
        Button { showSession = true } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "play.fill")
                    .font(DesignSystem.Font.headline)
                Text("Start Challenge")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Countdown

private extension DailyChallengeScreen {
    var countdownSection: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "clock")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Next Challenge")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(timeUntilMidnight)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - History Section

private extension DailyChallengeScreen {
    func historySection(service: DailyChallengeService) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "History")
            if service.history.isEmpty {
                emptyHistoryView
            } else {
                ForEach(service.history) { result in
                    historyRow(result: result)
                }
            }
        }
    }

    var emptyHistoryView: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 32))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Text("No challenges completed yet")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.xl)
        }
    }

    func historyRow(result: DailyChallengeResult) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                historyDateLabel(dateKey: result.dateKey)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(result.challengeType.replacingOccurrences(
                        of: "([a-z])([A-Z])",
                        with: "$1 $2",
                        options: .regularExpression
                    ).capitalized)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)
                    Text(formatTime(result.timeSpentSeconds))
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                Spacer()
                Text("\(result.score)")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor(for: result))
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    func historyDateLabel(dateKey: String) -> some View {
        VStack(spacing: 0) {
            let parts = dateKey.split(separator: "-")
            if parts.count == 3 {
                Text(String(parts[2]))
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(monthAbbreviation(from: String(parts[1])))
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .frame(width: DesignSystem.Size.lg)
    }
}

// MARK: - Background

private extension DailyChallengeScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        DesignSystem.Color.accent.opacity(0.22),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 420, height: 320)
                .blur(radius: 36)
                .offset(x: -80, y: -100)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        DesignSystem.Color.indigo.opacity(0.18),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 300)
                .blur(radius: 44)
                .offset(x: 140, y: 300)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
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

private extension DailyChallengeScreen {
    func loadData() {
        countryDataService.loadCountries()
        let challengeService = DailyChallengeService(
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        challengeService.loadChallenge()
        service = challengeService
    }
}

// MARK: - Helpers

private extension DailyChallengeScreen {
    var formattedDate: String {
        Date.now.formatted(date: .abbreviated, time: .omitted)
    }

    var timeUntilMidnight: String {
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 1, to: .now)!
        )
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: .now,
            to: tomorrow
        )
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        return "\(hours)h \(minutes)m remaining"
    }

    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if minutes > 0 {
            return "\(minutes)m \(secs)s"
        }
        return "\(secs)s"
    }

    func scoreColor(for result: DailyChallengeResult) -> Color {
        if result.accuracy >= 0.7 {
            DesignSystem.Color.success
        } else if result.accuracy >= 0.4 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.error
        }
    }

    func monthAbbreviation(from monthString: String) -> String {
        guard let month = Int(monthString), (1...12).contains(month) else {
            return monthString
        }
        let formatter = DateFormatter()
        return formatter.shortMonthSymbols[month - 1].uppercased()
    }
}
