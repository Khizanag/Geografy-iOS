import SwiftUI

struct BadgeCard: View {
    let definition: BadgeDefinition
    let isUnlocked: Bool
    let progress: BadgeProgress
    let onTap: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        } label: {
            cardContent
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}

// MARK: - Subviews

private extension BadgeCard {
    var cardContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            badgeIcon
            titleLabel
            rarityChip
            if !isUnlocked {
                progressBar
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(borderOverlay)
        .opacity(isUnlocked ? 1.0 : 0.55)
    }

    var badgeIcon: some View {
        ZStack {
            Circle()
                .fill(
                    definition.category.themeColor
                        .opacity(isUnlocked ? 0.2 : 0.08)
                )
                .frame(
                    width: DesignSystem.Size.xxl,
                    height: DesignSystem.Size.xxl
                )
            if isUnlocked {
                Image(systemName: definition.iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(definition.category.themeColor)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(DesignSystem.Color.success)
                    .offset(x: 4, y: -4)
            }
        }
    }

    var titleLabel: some View {
        Text(definition.title)
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    var rarityChip: some View {
        Text(definition.rarity.displayName)
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(definition.rarity.borderColor)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 2)
            .background(
                definition.rarity.borderColor.opacity(0.12),
                in: Capsule()
            )
    }

    var progressBar: some View {
        VStack(spacing: 2) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.pill
                    )
                    .fill(
                        DesignSystem.Color.cardBackgroundHighlighted
                    )
                    .frame(height: 4)
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.pill
                    )
                    .fill(definition.category.themeColor)
                    .frame(
                        width: geometry.size.width * progress.fraction,
                        height: 4
                    )
                }
            }
            .frame(height: 4)
            Text(
                "\(progress.currentValue)/\(progress.targetValue)"
            )
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var borderOverlay: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .strokeBorder(
                isUnlocked
                    ? definition.rarity.borderGradient
                    : LinearGradient(
                        colors: [
                            DesignSystem.Color.textTertiary.opacity(0.15),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                lineWidth: isUnlocked
                    ? definition.rarity.borderWidth
                    : 1
            )
    }
}
