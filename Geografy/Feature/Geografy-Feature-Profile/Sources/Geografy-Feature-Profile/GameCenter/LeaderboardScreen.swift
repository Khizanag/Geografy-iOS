import GameKit
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct LeaderboardScreen: View {
    // MARK: - Properties
    @Environment(GameCenterService.self) private var gameCenterService

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Leaderboards")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Scroll Content
private extension LeaderboardScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                if gameCenterService.isAuthenticated {
                    connectedContent
                } else {
                    signedOutContent
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    @ViewBuilder
    var connectedContent: some View {
        statusCard
            .padding(.top, DesignSystem.Spacing.sm)
        ForEach(leaderboards) { info in
            leaderboardCard(info)
        }
        openGameCenterButton
    }

    var signedOutContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            GameCenterSignInPrompt(
                message: "Sign in to Game Center in Settings to post your scores and see how you rank."
            )
            SectionHeaderView(title: "Leaderboards")
            RowListCard(
                leaderboards,
                dividerInset: RowListCardLayout.dividerInset(after: DesignSystem.Size.xl)
            ) { info in
                leaderboardSummary(info)
                    .rowListCardRow()
                    .accessibilityElement(children: .combine)
            }
        }
    }

    var statusCard: some View {
        CardView {
            statusContent
                .padding(DesignSystem.Spacing.sm)
        }
    }

    var statusContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge("checkmark.seal.fill", color: DesignSystem.Color.success, size: .small)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text("Connected to Game Center")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Your scores are syncing automatically")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.success)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    func leaderboardCard(_ info: LeaderboardInfo) -> some View {
        Button {
            GKAccessPoint.shared.trigger(
                leaderboardID: info.id,
                playerScope: .global,
                timeScope: .allTime
            ) {}
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    leaderboardSummary(info)
                    RowChevron()
                }
                .padding(DesignSystem.Spacing.md)
            }
            .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the rankings in Game Center")
    }

    func leaderboardSummary(_ info: LeaderboardInfo) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: info.icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(info.color)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .background(
                    info.color.opacity(DesignSystem.Opacity.tint),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(info.title)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(info.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var openGameCenterButton: some View {
        GlassButton("Open Game Center", systemImage: "gamecontroller.fill", fullWidth: true) {
            GKAccessPoint.shared.trigger(state: .dashboard) {}
        }
        .padding(.top, DesignSystem.Spacing.xs)
    }
}

// MARK: - Leaderboard Data
private extension LeaderboardScreen {
    struct LeaderboardInfo: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
    }

    var leaderboards: [LeaderboardInfo] {
        [
            LeaderboardInfo(
                id: GameCenterService.LeaderboardID.totalXP,
                title: "Total XP",
                subtitle: "Earn XP by exploring countries, completing quizzes, and maintaining streaks",
                icon: "bolt.fill",
                color: DesignSystem.Color.indigo
            ),
            LeaderboardInfo(
                id: GameCenterService.LeaderboardID.quizHighScore,
                title: "Best Quiz Score",
                subtitle: "Your highest quiz accuracy score across all quiz types",
                icon: "trophy.fill",
                color: DesignSystem.Color.warning
            ),
            LeaderboardInfo(
                id: GameCenterService.LeaderboardID.countriesVisited,
                title: "Countries Visited",
                subtitle: "Number of countries you've marked as visited in the Travel Tracker",
                icon: "airplane.departure",
                color: DesignSystem.Color.blue
            ),
            LeaderboardInfo(
                id: GameCenterService.LeaderboardID.longestStreak,
                title: "Longest Streak",
                subtitle: "Your longest run of days learning something new",
                icon: "flame.fill",
                color: DesignSystem.Color.orange
            ),
            LeaderboardInfo(
                id: GameCenterService.LeaderboardID.dailyChallengesWon,
                title: "Daily Challenges",
                subtitle: "Total number of daily challenges you've completed",
                icon: "calendar.badge.checkmark",
                color: DesignSystem.Color.indigo
            ),
            LeaderboardInfo(
                id: GameCenterService.LeaderboardID.speedRunWorld,
                title: "Speed Run — World",
                subtitle: "Fastest time to complete the world speed run quiz",
                icon: "bolt.circle.fill",
                color: DesignSystem.Color.error
            ),
        ]
    }
}
