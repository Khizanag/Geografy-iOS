import SwiftUI
import GameKit
import GeografyDesign

struct LeaderboardScreen: View {
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(HapticsService.self) private var hapticsService

    @State private var showSignIn = false

    var body: some View {
        scrollContent
            .background { AmbientBlobsView(.leaderboard) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Leaderboards")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSignIn) {
                SignInOptionsSheet()
            }
    }
}

// MARK: - Scroll Content
private extension LeaderboardScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                statusCard
                    .padding(.top, DesignSystem.Spacing.sm)
                ForEach(leaderboards, id: \.id) { info in
                    leaderboardCard(info)
                }
                openGameCenterButton
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var statusCard: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: DesignSystem.Size.lg, height: DesignSystem.Size.lg)
                Image(systemName: statusIcon)
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(statusColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                if gameCenterService.isAuthenticated {
                    Text(statusSubtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                } else {
                    Button {
                        hapticsService.impact(.light)
                        showSignIn = true
                    } label: {
                        Text("Sign In")
                            .font(DesignSystem.Font.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: DesignSystem.Spacing.xs, height: DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func leaderboardCard(_ info: LeaderboardInfo) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .fill(info.color.opacity(0.18))
                            .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                        Image(systemName: info.icon)
                            .font(DesignSystem.Font.title2)
                            .foregroundStyle(info.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(info.title)
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(info.subtitle)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Button {
                    hapticsService.impact(.light)
                    GKAccessPoint.shared.trigger(
                        leaderboardID: info.id,
                        playerScope: .global,
                        timeScope: .allTime
                    ) {}
                } label: {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "list.number")
                            .font(DesignSystem.Font.caption)
                        Text("View Rankings")
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(info.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(
                        info.color.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    )
                }
                .disabled(!gameCenterService.isAuthenticated)
                .opacity(gameCenterService.isAuthenticated ? 1 : 0.4)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var openGameCenterButton: some View {
        Button {
            hapticsService.impact(.medium)
            GKAccessPoint.shared.trigger(state: .dashboard) {}
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "gamecontroller.fill")
                    .font(DesignSystem.Font.subheadline)
                Text("Open Game Center")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(.glass)
        .disabled(!gameCenterService.isAuthenticated)
        .opacity(gameCenterService.isAuthenticated ? 1 : 0.4)
        .padding(.top, DesignSystem.Spacing.xs)
    }
}

// MARK: - Leaderboard Data
private extension LeaderboardScreen {
    struct LeaderboardInfo {
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
                color: DesignSystem.Color.accent
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
                subtitle: "The longest consecutive daily login streak you've achieved",
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

// MARK: - Status
private extension LeaderboardScreen {
    var statusColor: Color {
        gameCenterService.isAuthenticated ? DesignSystem.Color.success : DesignSystem.Color.textTertiary
    }

    var statusIcon: String {
        gameCenterService.isAuthenticated ? "checkmark.seal.fill" : "gamecontroller"
    }

    var statusTitle: String {
        gameCenterService.isAuthenticated ? "Connected to Game Center" : "Not Connected"
    }

    var statusSubtitle: String {
        gameCenterService.isAuthenticated
            ? "Your scores are syncing automatically"
            : "Sign in to Game Center in iOS Settings"
    }
}
