#if !os(tvOS)
import SwiftUI

// MARK: - Stats Grid
extension ProfileScreen {
    var statsGridSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Statistics")
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible()),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                accuracyCard
                statCard(
                    icon: "checkmark.seal.fill",
                    color: DesignSystem.Color.accent,
                    value: "\(statistics?.perfectScores ?? 0)",
                    label: "Perfect"
                )
                statCard(
                    icon: "flame.fill",
                    color: DesignSystem.Color.error,
                    value: "\(statistics?.longestStreak ?? 0)",
                    label: "Best Streak"
                )
                statCard(
                    icon: "gamecontroller.fill",
                    color: DesignSystem.Color.purple,
                    value: "\(statistics?.totalQuizzes ?? 0)",
                    label: "Quizzes"
                )
                statCard(
                    icon: "globe.americas.fill",
                    color: DesignSystem.Color.blue,
                    value: "\(statistics?.countriesExplored ?? 0)",
                    label: "Explored"
                )
                statCard(
                    icon: "airplane.departure",
                    color: DesignSystem.Color.success,
                    value: "\(statistics?.countriesVisited ?? 0)",
                    label: "Visited"
                )
                statCard(
                    icon: "star.fill",
                    color: DesignSystem.Color.warning,
                    value: "\(achievementService.unlockedAchievements.count)",
                    label: "Badges"
                )
                statCard(
                    icon: "bolt.fill",
                    color: DesignSystem.Color.orange,
                    value: "\(streakService.currentStreak)",
                    label: "Streak"
                )
                statCard(
                    icon: "calendar.badge.checkmark",
                    color: DesignSystem.Color.indigo,
                    value: statistics?.formattedMemberSince ?? "—",
                    label: "Member"
                )
            }
        }
    }
}

// MARK: - Stats Subviews
private extension ProfileScreen {
    var accuracyCard: some View {
        let percentage = statistics?.accuracyPercentage ?? 0
        let rate = statistics?.accuracyRate ?? 0
        let color = accuracyColor(for: rate)

        return VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                    .frame(width: 36, height: 36)
                Circle()
                    .trim(from: 0, to: rate)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                Text("\(percentage)")
                    .font(DesignSystem.Font.roundedPico)
                    .foregroundStyle(color)
            }
            Text("\(percentage)%")
                .font(DesignSystem.Font.roundedFootnote)
                .foregroundStyle(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("Accuracy")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Accuracy \(percentage) percent")
    }

    func accuracyColor(for rate: Double) -> Color {
        switch rate {
        case 0.8...1.0: DesignSystem.Color.success
        case 0.5..<0.8: DesignSystem.Color.warning
        default:        DesignSystem.Color.error
        }
    }

    func statCard(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(DesignSystem.Font.iconXS)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(DesignSystem.Font.roundedFootnote)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}
#endif
