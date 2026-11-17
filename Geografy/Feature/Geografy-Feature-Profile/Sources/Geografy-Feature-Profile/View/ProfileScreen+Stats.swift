#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Stats Grid
extension ProfileScreen {
    public var statsGridSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Statistics")
            statsGrid
        }
    }
}

// MARK: - Stats Grid
private extension ProfileScreen {
    var statsGrid: some View {
        let columnCount = dynamicTypeSize.isAccessibilitySize ? 2 : 3
        return LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                count: columnCount
            ),
            spacing: DesignSystem.Spacing.sm
        ) {
            statsGridItems
        }
    }

    @ViewBuilder
    var statsGridItems: some View {
        accuracyCard
        StatTile(
            value: "\(statistics?.perfectScores ?? 0)",
            label: "Perfect",
            icon: "checkmark.seal.fill",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: "\(statistics?.longestStreak ?? 0)",
            label: "Best Streak",
            icon: "flame.fill",
            color: DesignSystem.Color.orange
        )
        StatTile(
            value: "\(statistics?.totalQuizzes ?? 0)",
            label: "Quizzes",
            icon: "gamecontroller.fill",
            color: DesignSystem.Color.purple
        )
        StatTile(
            value: "\(statistics?.countriesExplored ?? 0)",
            label: "Explored",
            icon: "globe.americas.fill",
            color: DesignSystem.Color.blue
        )
        StatTile(
            value: "\(statistics?.countriesVisited ?? 0)",
            label: "Visited",
            icon: "airplane.departure",
            color: DesignSystem.Color.teal
        )
        StatTile(
            value: "\(achievementService.unlockedCount)",
            label: "Badges",
            icon: "star.fill",
            color: DesignSystem.Color.warning
        )
        StatTile(
            value: "\(streakService.currentStreak)",
            label: "Streak",
            icon: "bolt.fill",
            color: DesignSystem.Color.orange
        )
        StatTile(
            value: statistics?.formattedMemberSince ?? "—",
            label: "Member",
            icon: "calendar.badge.checkmark",
            color: DesignSystem.Color.indigo
        )
    }
}

// MARK: - Stats Subviews
private extension ProfileScreen {
    var accuracyCard: some View {
        let percentage = statistics?.accuracyPercentage ?? 0
        let rate = statistics?.accuracyRate ?? 0
        return StatTile(
            value: "\(percentage)%",
            label: "Accuracy",
            icon: "target",
            color: accuracyColor(for: rate)
        )
    }

    func accuracyColor(for rate: Double) -> Color {
        switch rate {
        case 0.8...1.0: DesignSystem.Color.success
        case 0.5..<0.8: DesignSystem.Color.warning
        default:        DesignSystem.Color.error
        }
    }
}
#endif
