import GameKit
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct LeaderboardScreen: View {
    @Environment(GameCenterService.self) private var gameCenterService

    @State private var players: [GKLeaderboard.Entry] = []
    @State private var localPlayer: GKLeaderboard.Entry?
    @State private var isLoading = true

    var body: some View {
        // swiftlint:disable:next closure_body_length
        List {
            if isLoading {
                Section {
                    ProgressView("Loading leaderboard…")
                }
            } else if players.isEmpty {
                Section {
                    Text("No leaderboard data available")
                        .foregroundStyle(.secondary)
                }
            } else {
                if let localPlayer {
                    Section("Your Rank") {
                        playerRow(localPlayer)
                    }
                }

                Section("Top Players") {
                    ForEach(Array(players.enumerated()), id: \.element.player.gamePlayerID) { _, entry in
                        HStack(spacing: 20) {
                            Text("#\(entry.rank)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(rankColor(entry.rank))
                                .frame(width: 60, alignment: .leading)

                            Text(entry.player.displayName)
                                .font(.system(size: 22))

                            Spacer()

                            Text(entry.formattedScore)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(DesignSystem.Color.accent)
                        }
                    }
                }
            }
        }
        .navigationTitle("Leaderboard")
        .task { await loadLeaderboard() }
    }
}

// MARK: - Subviews
private extension LeaderboardScreen {
    func playerRow(_ entry: GKLeaderboard.Entry) -> some View {
        HStack(spacing: 20) {
            Text("#\(entry.rank)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DesignSystem.Color.accent)

            Text(entry.player.displayName)
                .font(.system(size: 24, weight: .semibold))

            Spacer()

            Text(entry.formattedScore)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: DesignSystem.Color.warning
        case 2: .gray
        case 3: DesignSystem.Color.orange
        default: DesignSystem.Color.textSecondary
        }
    }
}

// MARK: - Data Loading
private extension LeaderboardScreen {
    func loadLeaderboard() async {
        defer { isLoading = false }

        guard GKLocalPlayer.local.isAuthenticated else { return }

        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: ["totalXP"])
            guard let leaderboard = leaderboards.first else { return }

            let (local, entries, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 25)
            )
            localPlayer = local
            players = entries
        } catch {
            players = []
        }
    }
}
