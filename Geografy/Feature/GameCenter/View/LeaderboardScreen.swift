import GameKit
import SwiftUI

struct LeaderboardScreen: View {
    @Environment(GameCenterService.self) private var gameCenterService

    @State private var showLeaderboard = false
    @State private var selectedLeaderboardID = ""
    @State private var blobAnimating = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ambientBlobs
            scrollContent
        }
        .navigationTitle("Leaderboards")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showLeaderboard) {
            GameCenterViewControllerRepresentable(
                isPresented: $showLeaderboard,
                leaderboardID: selectedLeaderboardID
            )
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
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
                Text(statusSubtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
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
        GeoCard {
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
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    selectedLeaderboardID = info.id
                    showLeaderboard = true
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
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            selectedLeaderboardID = ""
            showLeaderboard = true
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

// MARK: - Background

private extension LeaderboardScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.22), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 400, height: 300)
                .blur(radius: 32)
                .offset(x: -80, y: -60)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.warning.opacity(0.14), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 160
                ))
                .frame(width: 320, height: 280)
                .blur(radius: 40)
                .offset(x: 140, y: 120)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
