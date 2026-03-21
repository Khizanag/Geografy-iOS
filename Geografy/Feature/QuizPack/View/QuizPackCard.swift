import SwiftUI

struct QuizPackCard: View {
    let pack: QuizPack
    let completedLevels: Int
    let stars: Int
    let maxStars: Int
    let isUnlocked: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            backgroundIcon
            cardInfo

            if !isUnlocked {
                lockedOverlay
            }
        }
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
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topTrailing
            )
            .offset(x: 20, y: -10)
            .clipped()
    }

    var cardInfo: some View {
        VStack(
            alignment: .leading,
            spacing: DesignSystem.Spacing.xxs
        ) {
            Spacer(minLength: 0)

            if pack.isPremium {
                PremiumBadge()
            }

            Text(pack.name)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            statsRow
        }
        .padding(DesignSystem.Spacing.sm)
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

    var lockedOverlay: some View {
        ZStack {
            DesignSystem.Color.background.opacity(0.6)
            Image(systemName: "lock.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
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
