import GeografyDesign
import SwiftUI

struct MatchHistoryScreen: View {
    let multiplayerService: MultiplayerService

    var body: some View {
        Group {
            if multiplayerService.matchHistory.isEmpty {
                emptyState
            } else {
                matchList
            }
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Match History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension MatchHistoryScreen {
    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "person.2.slash")
                .font(DesignSystem.IconSize.xLarge)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            Text("No Matches Yet")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Play a multiplayer match to see your history here.")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var matchList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(multiplayerService.matchHistory) { match in
                    matchRow(match)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    func matchRow(_ match: MultiplayerMatch) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                resultIndicator(match)

                OpponentAvatarView(
                    opponent: match.opponent,
                    size: DesignSystem.Size.lg,
                    showFlag: false,
                )

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(match.opponent.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(
                            match.configuration.type.displayName
                        )
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)

                        Text(formattedDate(match.date))
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxs) {
                    Text("\(match.playerScore) - \(match.opponentScore)")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    ratingChangeLabel(match.playerRatingChange)
                }
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func resultIndicator(_ match: MultiplayerMatch) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(matchResultColor(match))
            .frame(width: 4, height: DesignSystem.Spacing.xl)
    }

    func ratingChangeLabel(_ change: Int) -> some View {
        let text = change >= 0 ? "+\(change)" : "\(change)"
        let color = change > 0
            ? DesignSystem.Color.success
            : change < 0
                ? DesignSystem.Color.error
                : DesignSystem.Color.warning

        return Text(text)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(color)
    }
}

// MARK: - Helpers
private extension MatchHistoryScreen {
    func matchResultColor(_ match: MultiplayerMatch) -> Color {
        if match.playerWon {
            DesignSystem.Color.success
        } else if match.opponentWon {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.warning
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
