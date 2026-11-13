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
        }
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Streak")
            DailyChallengeStreakCard(streak: streak(for: service))
        }
        DailyChallengeHistorySection(results: sortedHistory(for: service))
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
    func loadData() async {
        let challengeService = DailyChallengeService(
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        await challengeService.loadChallenge()
        service = challengeService
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
        let streak = streak(for: service)
        return [
            GameIntroHeader.Fact("\(streak.current)-day streak", systemImage: "flame.fill"),
            GameIntroHeader.Fact("Best streak \(streak.best)", systemImage: "trophy.fill"),
            GameIntroHeader.Fact("\(streak.completedCount) completed", systemImage: "checkmark.seal.fill"),
        ]
    }

    func streak(for service: DailyChallengeService) -> DailyChallengeStreak {
        DailyChallengeStreak(dateKeys: service.history.map(\.dateKey))
    }

    func sortedHistory(for service: DailyChallengeService) -> [DailyChallengeResult] {
        service.history.sorted { lhs, rhs in
            lhs.dateKey == rhs.dateKey ? lhs.completedAt > rhs.completedAt : lhs.dateKey > rhs.dateKey
        }
    }
}
