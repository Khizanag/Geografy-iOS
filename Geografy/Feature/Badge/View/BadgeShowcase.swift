import SwiftUI

struct BadgeShowcase: View {
    let pinnedBadges: [BadgeDefinition]

    var body: some View {
        if pinnedBadges.isEmpty {
            emptyShowcase
        } else {
            filledShowcase
        }
    }
}

// MARK: - Subviews

private extension BadgeShowcase {
    var emptyShowcase: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("No badges pinned yet")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
    }

    var filledShowcase: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ForEach(pinnedBadges) { badge in
                showcaseBadge(badge)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    func showcaseBadge(_ badge: BadgeDefinition) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            ZStack {
                Circle()
                    .fill(
                        badge.category.themeColor.opacity(0.18)
                    )
                    .frame(
                        width: DesignSystem.Size.xl,
                        height: DesignSystem.Size.xl
                    )
                Circle()
                    .strokeBorder(
                        badge.rarity.borderGradient,
                        lineWidth: badge.rarity.borderWidth
                    )
                    .frame(
                        width: DesignSystem.Size.xl,
                        height: DesignSystem.Size.xl
                    )
                Image(systemName: badge.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(badge.category.themeColor)
            }
            Text(badge.title)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
