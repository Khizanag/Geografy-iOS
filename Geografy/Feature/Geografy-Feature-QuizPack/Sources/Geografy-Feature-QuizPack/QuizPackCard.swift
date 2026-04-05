import Geografy_Core_DesignSystem
import SwiftUI

public struct QuizPackCard: View {
    // MARK: - Properties
    public let pack: QuizPack
    public let completedLevels: Int
    public let stars: Int
    public let maxStars: Int
    public let isUnlocked: Bool

    // MARK: - Init
    public init(
        pack: QuizPack,
        completedLevels: Int,
        stars: Int,
        maxStars: Int,
        isUnlocked: Bool
    ) {
        self.pack = pack
        self.completedLevels = completedLevels
        self.stars = stars
        self.maxStars = maxStars
        self.isUnlocked = isUnlocked
    }

    // MARK: - Body
    public var body: some View {
        cardContent
            .frame(height: 160)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.large
                )
            )
            .shadow(
                color: pack.gradientColors.0.opacity(0.35),
                radius: 10,
                y: 4
            )
    }
}

// MARK: - Subviews
private extension QuizPackCard {
    var cardContent: some View {
        ZStack(alignment: .bottomLeading) {
            gradient

            backgroundIcon

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                premiumBadgeIfNeeded
                Spacer(minLength: 0)
                packTitle
                statsRow
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .overlay { lockedOverlayIfNeeded }
    }

    var gradient: some View {
        LinearGradient(
            colors: [
                pack.gradientColors.0,
                pack.gradientColors.1,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var backgroundIcon: some View {
        Image(systemName: pack.icon)
            .font(DesignSystem.IconSize.hero)
            .foregroundStyle(
                DesignSystem.Color.onAccent.opacity(0.08)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: 20, y: -10)
            .clipped()
    }

    @ViewBuilder
    var premiumBadgeIfNeeded: some View {
        if pack.isPremium {
            PremiumBadge()
        }
    }

    var packTitle: some View {
        Text(pack.name)
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            statPill(
                text: "\(completedLevels)/\(pack.levelCount)",
                icon: "checkmark.circle"
            )
            statPill(
                text: "\(stars)/\(maxStars)",
                icon: "star.fill"
            )
        }
    }

    @ViewBuilder
    var lockedOverlayIfNeeded: some View {
        if !isUnlocked {
            ZStack {
                DesignSystem.Color.background.opacity(0.6)
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }
}

// MARK: - Helpers
private extension QuizPackCard {
    func statPill(text: String, icon: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
            Text(text)
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(
            DesignSystem.Color.onAccent.opacity(0.9)
        )
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(
            DesignSystem.Color.onAccent.opacity(0.18)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                DesignSystem.Color.onAccent.opacity(0.25),
                lineWidth: 1
            )
        )
    }
}
