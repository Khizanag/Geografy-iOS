import SwiftUI

struct CoinPackCard: View {
    let pack: CoinPack
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                tagBadge
                coinDisplay
                priceSection
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .overlay(cardBorder)
            .geoShadow(.card)
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}

// MARK: - Subviews

private extension CoinPackCard {
    var tagBadge: some View {
        Group {
            if let tagText = pack.tagText {
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    if !pack.badgeIcon.isEmpty {
                        Image(systemName: pack.badgeIcon)
                            .font(.system(size: 9, weight: .bold))
                    }
                    Text(tagText)
                }
                .font(DesignSystem.Font.caption2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(tagColor, in: Capsule())
            } else {
                Color.clear
                    .frame(height: 20)
            }
        }
    }

    var coinDisplay: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "dollarsign.circle.fill")
                .font(DesignSystem.IconSize.large)
                .foregroundStyle(coinGradient)

            Text(pack.formattedCoins)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("coins")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var priceSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(pack.price)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("\(pack.coinsPerDollar) coins/$")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}

// MARK: - Styles

private extension CoinPackCard {
    var tagColor: Color {
        if pack.isPopular { DesignSystem.Color.accent }
        else if pack.isBestValue { DesignSystem.Color.success }
        else { DesignSystem.Color.orange }
    }

    var cardBackground: some View {
        LinearGradient(
            colors: [
                DesignSystem.Color.cardBackground,
                DesignSystem.Color.cardBackgroundHighlighted.opacity(0.5),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .strokeBorder(
                borderColor.opacity(0.3),
                lineWidth: pack.isPopular || pack.isBestValue
                    ? DesignSystem.Size.xxs * 2
                    : DesignSystem.Size.xxs
            )
    }

    var borderColor: Color {
        if pack.isPopular { DesignSystem.Color.accent }
        else if pack.isBestValue { DesignSystem.Color.success }
        else { DesignSystem.Color.textTertiary }
    }

    var coinGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.warning, DesignSystem.Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing,
        )
    }
}
