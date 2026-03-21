import SwiftUI

struct CoinPackCard: View {
    let pack: CoinPack
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            tagBadge
            coinDisplay
            priceSection
            buyButton
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .overlay(cardBorder)
        .geoShadow(.card)
    }
}

// MARK: - Subviews

private extension CoinPackCard {
    @ViewBuilder
    var tagBadge: some View {
        if pack.isPopular {
            tagLabel("Popular", color: DesignSystem.Color.accent)
        } else if pack.isBestValue {
            tagLabel("Best Value", color: DesignSystem.Color.success)
        } else if pack.bonusPercentage > 0 {
            tagLabel("+\(pack.bonusPercentage)% Bonus", color: DesignSystem.Color.orange)
        }
    }

    func tagLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(color, in: Capsule())
    }

    var coinDisplay: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: pack.icon)
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

    var buyButton: some View {
        Button(action: onPurchase) {
            Text("Buy")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(buyButtonGradient, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Styles

private extension CoinPackCard {
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
        if pack.isPopular { return DesignSystem.Color.accent }
        if pack.isBestValue { return DesignSystem.Color.success }
        return DesignSystem.Color.textTertiary
    }

    var coinGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.warning, DesignSystem.Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var buyButtonGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
