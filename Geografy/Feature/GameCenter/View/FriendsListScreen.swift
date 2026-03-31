import SwiftUI
import GameKit
import GeografyDesign

struct FriendsListScreen: View {
    @Environment(GameCenterService.self) private var gameCenterService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var friends: [GKPlayer] = []
    @State private var avatars: [String: Image] = [:]
    @State private var xpScores: [String: Int] = [:]
    @State private var isLoading = true
    @State private var animating = false

    var body: some View {
        content
            .background { AmbientBlobsView(.standard) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .task { await loadData() }
            .onAppear {
                animating = true
            }
    }
}

// MARK: - Content
private extension FriendsListScreen {
    @ViewBuilder
    var content: some View {
        if !gameCenterService.isAuthenticated {
            notAuthenticatedView
        } else if isLoading {
            loadingView
        } else if friends.isEmpty {
            emptyStateView
        } else {
            friendsList
        }
    }

    var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Spacer()

            PulsingCirclesView(icon: "person.2.fill", isAnimating: animating)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Finding your friends")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Connecting to Game Center...")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var notAuthenticatedView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            PulsingCirclesView(icon: "gamecontroller.fill", isAnimating: animating)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Sign in to Game Center")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Connect your Game Center account to see your friends and compare scores.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()

            PulsingCirclesView(icon: "person.2", isAnimating: animating)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("No Friends Yet")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Only Game Center friends who also have Geografy installed will appear here.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }

            addFriendsButton

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }
}

// MARK: - Friends List
private extension FriendsListScreen {
    var friendsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                friendsHeader

                ForEach(Array(sortedFriends.enumerated()), id: \.element.gamePlayerID) { index, friend in
                    friendRow(friend, rank: index + 1)
                }

                addFriendsButton
                    .padding(.top, DesignSystem.Spacing.sm)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var friendsHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.15))
                    .frame(width: DesignSystem.Size.lg, height: DesignSystem.Size.lg)
                Image(systemName: "person.2.fill")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(friends.count) Friend\(friends.count == 1 ? "" : "s")")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Ranked by Total XP")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func friendRow(_ player: GKPlayer, rank: Int) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                rankBadge(rank)
                avatarView(for: player)
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.displayName)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)
                    if let score = xpScores[player.gamePlayerID] {
                        Text("\(score.formatted()) XP")
                            .font(DesignSystem.Font.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(DesignSystem.Color.accent)
                    } else {
                        Text("No XP recorded")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
                Spacer(minLength: 0)
                if let score = xpScores[player.gamePlayerID] {
                    xpBadge(score)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension FriendsListScreen {
    func rankBadge(_ rank: Int) -> some View {
        ZStack {
            Circle()
                .fill(rankColor(rank).opacity(0.15))
                .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            Text("\(rank)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.black)
                .foregroundStyle(rankColor(rank))
        }
    }

    func avatarView(for player: GKPlayer) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.3), DesignSystem.Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
            if let avatar = avatars[player.gamePlayerID] {
                avatar
                    .resizable()
                    .scaledToFill()
                    .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                    .clipShape(Circle())
            } else {
                Text(playerInitial(player))
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
        }
    }

    func xpBadge(_ score: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "bolt.fill")
                .font(DesignSystem.Font.caption2)
            Text(abbreviatedScore(score))
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.accent.opacity(0.12),
            in: Capsule()
        )
    }

    var addFriendsButton: some View {
        GlassButton("Add Friends in Game Center", systemImage: "person.badge.plus", fullWidth: true) {
            hapticsService.impact(.medium)
            GKAccessPoint.shared.trigger(state: .localPlayerFriendsList) {}
        }
    }
}

// MARK: - Helpers
private extension FriendsListScreen {
    var sortedFriends: [GKPlayer] {
        friends.sorted { playerA, playerB in
            let scoreA = xpScores[playerA.gamePlayerID] ?? 0
            let scoreB = xpScores[playerB.gamePlayerID] ?? 0
            return scoreA > scoreB
        }
    }

    func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: DesignSystem.Color.warning
        case 2: DesignSystem.Color.textSecondary
        case 3: DesignSystem.Color.accent
        default: DesignSystem.Color.textTertiary
        }
    }

    func playerInitial(_ player: GKPlayer) -> String {
        String(player.displayName.prefix(1)).uppercased()
    }

    func abbreviatedScore(_ score: Int) -> String {
        if score >= 1_000_000 {
            String(format: "%.1fM", Double(score) / 1_000_000)
        } else if score >= 1_000 {
            String(format: "%.1fK", Double(score) / 1_000)
        } else {
            "\(score)"
        }
    }
}

// MARK: - Actions
private extension FriendsListScreen {
    func loadData() async {
        friends = await gameCenterService.loadFriends()

        for friend in friends {
            if let uiImage = try? await friend.loadPhoto(for: .small) {
                avatars[friend.gamePlayerID] = Image(uiImage: uiImage)
            }
        }

        let entries = await gameCenterService.loadFriendLeaderboardEntries(
            for: GameCenterService.LeaderboardID.totalXP
        )
        for entry in entries {
            xpScores[entry.player.gamePlayerID] = entry.score
        }

        isLoading = false
    }
}
