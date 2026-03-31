import SwiftUI
import GeografyDesign

/// Displays a single clue with reveal animation.
struct ExploreClueCard: View {
    let clue: ExploreClue
    let isLatest: Bool

    var body: some View {
        CardView {
            cardContent
                .padding(DesignSystem.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .opacity(isLatest ? 1.0 : 0.7)
    }
}

// MARK: - Subviews
private extension ExploreClueCard {
    var cardContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            iconCircle
            textContent
        }
    }

    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(
                    width: DesignSystem.Size.lg,
                    height: DesignSystem.Size.lg
                )

            Image(systemName: clue.icon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var textContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            HStack {
                Text(clue.title)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                Spacer(minLength: 0)

                pointsBadge
            }

            Text(clue.detail)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var pointsBadge: some View {
        Text("\(clue.pointsAvailable) pts")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.accent)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 2)
            .background(
                DesignSystem.Color.accent.opacity(0.12),
                in: Capsule()
            )
    }
}
