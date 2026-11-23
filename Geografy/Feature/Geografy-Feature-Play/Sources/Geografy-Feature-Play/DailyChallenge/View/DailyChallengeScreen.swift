import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct DailyChallengeScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(XPService.self) private var xpService

    @State private var service: DailyChallengeService?
    @State private var showSession = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Daily Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(.dailyChallenge)
            .safeAreaBar(edge: .bottom) { startBar }
            .task { await loadData() }
            .fullScreenCover(isPresented: $showSession) {
                sessionCover
            }
    }
}

// MARK: - Subviews
private extension DailyChallengeScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                header
                if let service {
                    loadedSections(service: service)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xl)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var header: some View {
        GameIntroHeader(
            title: "Daily Challenge",
            subtitle: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()),
            systemImage: "calendar.badge.clock",
            color: DesignSystem.Color.orange,
            facts: headerFacts
        )
    }

    @ViewBuilder
    func loadedSections(service: DailyChallengeService) -> some View {
        if let challenge = service.todayChallenge {
            DailyChallengeTodayCard(challenge: challenge, result: service.todayResult)
        } else {
            EmptyStateView(
                icon: "exclamationmark.triangle",
                title: "Today's challenge isn't ready",
                message: "The countries didn't load, so there's nothing to build it from yet.",
                actionTitle: "Try Again"
            ) {
                Task { await loadData() }
            }
        }
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Challenge Streak")
            DailyChallengeStreakCard(streak: service.streakSummary)
        }
        DailyChallengeHistorySection(results: service.sortedHistory)
    }

    @ViewBuilder
    var startBar: some View {
        if let service, service.todayChallenge != nil, !service.hasCompletedToday {
            // The same neutral glass start button as the other game setup screens.
            GlassButton("Start Challenge", systemImage: "play.fill", fullWidth: true) {
                showSession = true
            }
            .accessibilityHint("Opens today's challenge")
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    var sessionCover: some View {
        CoordinatedNavigationStack {
            if let challenge = service?.todayChallenge, let service {
                DailyChallengeSessionScreen(
                    challenge: challenge,
                    service: service
                )
            }
        }
    }
}

// MARK: - Actions
private extension DailyChallengeScreen {
    // Reuses the loaded service, so coming back from the session doesn't rebuild the whole screen.
    func loadData() async {
        let challengeService = DailyChallengeService.service(
            reusing: service,
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        await challengeService.loadChallenge()
        if service !== challengeService {
            service = challengeService
        }
    }
}

// MARK: - Helpers
private extension DailyChallengeScreen {
    var headerFacts: [GameIntroHeader.Fact] {
        guard let service, !service.history.isEmpty else {
            let gameCount = DailyChallengeType.allCases.count
            return [
                GameIntroHeader.Fact("New every day", systemImage: "calendar"),
                GameIntroHeader.Fact("\(gameCount) rotating games", systemImage: "square.stack"),
            ]
        }
        let streak = service.streakSummary
        return [
            GameIntroHeader.Fact("\(streak.current)-day challenge streak", systemImage: "flame.fill"),
            GameIntroHeader.Fact("Best streak \(streak.best)", systemImage: "trophy.fill"),
            GameIntroHeader.Fact("\(streak.completedCount) completed", systemImage: "checkmark.seal.fill"),
        ]
    }
}
