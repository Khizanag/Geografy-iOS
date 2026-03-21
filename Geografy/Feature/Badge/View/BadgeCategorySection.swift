import SwiftUI

struct BadgeCategorySection: View {
    let category: BadgeCategory
    let badges: [BadgeDefinition]
    let badgeService: BadgeService
    let onBadgeTap: (BadgeDefinition) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            categoryHeader
            badgeGrid
        }
    }
}

// MARK: - Subviews

private extension BadgeCategorySection {
    var categoryHeader: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: category.iconName)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(category.themeColor)
            Text(category.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            progressLabel
        }
    }

    var progressLabel: some View {
        let unlocked = badges.filter {
            badgeService.isUnlocked($0.id)
        }.count
        return Text("\(unlocked)/\(badges.count)")
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var badgeGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            GridItem(.flexible()),
        ]
        return LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
            ForEach(badges) { badge in
                BadgeCard(
                    definition: badge,
                    isUnlocked: badgeService.isUnlocked(badge.id),
                    progress: badgeService.progress(for: badge),
                    onTap: { onBadgeTap(badge) }
                )
            }
        }
    }
}
