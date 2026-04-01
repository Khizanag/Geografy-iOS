import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI
import Geografy_Core_Service

public struct CoinPackPreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CoinService.self) private var coinService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let pack: CoinPack

    @State private var coinAnimating = false
    @State private var sparkleVisible = false

    public var body: some View {
        mainContent
            .padding(DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .onAppear {
                coinAnimating = true
                sparkleVisible = true
            }
    }
}

// MARK: - Subviews
private extension CoinPackPreviewSheet {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            coinHero
            infoSection
            Spacer()
            buyButton
        }
    }

    var coinHero: some View {
        ZStack {
            glowCircle

            Image(systemName: "dollarsign.circle.fill")
                .font(DesignSystem.Font.displayXL)
                .foregroundStyle(coinGradient)
                .scaleEffect(coinAnimating ? 1.08 : 0.95)
                .shadow(color: DesignSystem.Color.warning.opacity(0.4), radius: 20)

            sparkles
        }
        .frame(height: 160)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
            value: coinAnimating
        )
    }

    var glowCircle: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        DesignSystem.Color.warning.opacity(0.25),
                        DesignSystem.Color.warning.opacity(0.08),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(coinAnimating ? 1.15 : 0.90)
    }

    var sparkles: some View {
        ForEach(0..<6, id: \.self) { index in
            Image(systemName: "sparkle")
                .font(DesignSystem.Font.system(size: CGFloat.random(in: 8...14), weight: .bold))
                .foregroundStyle(DesignSystem.Color.warning)
                .offset(
                    x: sparkleOffset(for: index).x,
                    y: sparkleOffset(for: index).y
                )
                .opacity(sparkleVisible ? 1 : 0)
                .scaleEffect(sparkleVisible ? 1 : 0.3)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.6)
                        .delay(Double(index) * 0.08),
                    value: sparkleVisible
                )
        }
    }

    var infoSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            tagBadge

            Text(pack.formattedCoins)
                .font(DesignSystem.Font.roundedXL)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("coins")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .offset(y: -DesignSystem.Spacing.xs)

            Text(pack.detailDescription)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)

            HStack(spacing: DesignSystem.Spacing.xl) {
                statItem(value: pack.price, label: "Price")
                statItem(value: "\(pack.coinsPerDollar)", label: "Coins per $")
                if pack.bonusPercentage > 0 {
                    statItem(value: "+\(pack.bonusPercentage)%", label: "Bonus")
                }
            }
            .padding(.top, DesignSystem.Spacing.xs)
        }
    }

    @ViewBuilder
    var tagBadge: some View {
        if let tagText = pack.tagText {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                if !pack.badgeIcon.isEmpty {
                    Image(systemName: pack.badgeIcon)
                        .font(DesignSystem.Font.caption2.bold())
                }
                Text(tagText)
            }
            .font(DesignSystem.Font.caption)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(tagColor, in: Capsule())
        }
    }

    func statItem(value: String, label: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(value)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var buyButton: some View {
        Button {
            coinService.earn(pack.coins, reason: .purchase)
            dismiss()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "bag.fill")
                Text("Buy for \(pack.price)")
            }
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(buyButtonGradient, in: Capsule())
        }
        .buttonStyle(.plain)
        .geoShadow(.card)
    }
}

// MARK: - Helpers
private extension CoinPackPreviewSheet {
    var tagColor: Color {
        if pack.isPopular {
            DesignSystem.Color.accent
        } else if pack.isBestValue {
            DesignSystem.Color.success
        } else {
            DesignSystem.Color.orange
        }
    }

    var coinGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.warning, DesignSystem.Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing,
        )
    }

    var buyButtonGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
            startPoint: .leading,
            endPoint: .trailing,
        )
    }

    func sparkleOffset(for index: Int) -> CGPoint {
        let angle = Double(index) * (360.0 / 6.0) * .pi / 180.0
        let radius: CGFloat = 60
        return CGPoint(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }
}
