import Geografy_Core_DesignSystem
import SwiftUI

struct QuizPackCategoryCard: View {
    let category: QuizPackCategory
    let packCount: Int
    let completedCount: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            categoryIcon
            categoryInfo
            Spacer(minLength: 0)
            progressBadge
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
    }
}

// MARK: - Subviews
private extension QuizPackCategoryCard {
    var categoryIcon: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.small
            )
            .fill(
                LinearGradient(
                    colors: [
                        category.gradientColors.0,
                        category.gradientColors.1,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(
                width: DesignSystem.Size.xl,
                height: DesignSystem.Size.xl
            )

            Image(systemName: category.icon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
    }

    var categoryInfo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(category.displayName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)

            Text("\(packCount) packs")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var progressBadge: some View {
        Text("\(completedCount)/\(packCount)")
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: Capsule()
            )
    }
}
