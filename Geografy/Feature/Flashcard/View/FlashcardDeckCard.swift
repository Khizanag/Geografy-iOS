import SwiftUI
import GeografyDesign

struct FlashcardDeckCard: View {
    let deck: FlashcardDeck
    let cardCount: Int
    let masteryPercentage: Double
    let dueCount: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            backgroundIcon
            cardInfo
        }
        .frame(height: 150)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
        .shadow(
            color: deck.gradientColors.0.opacity(0.45),
            radius: 14,
            y: 5
        )
    }
}

// MARK: - Subviews
private extension FlashcardDeckCard {
    var gradient: some View {
        LinearGradient(
            colors: [deck.gradientColors.0, deck.gradientColors.1],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var backgroundIcon: some View {
        Image(systemName: deck.icon)
            .font(DesignSystem.IconSize.hero)
            .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.10))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: 24, y: -12)
            .clipped()
    }

    var cardInfo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Spacer(minLength: 0)

            Text(deck.name)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .lineLimit(1)

            statsRow
        }
        .padding(DesignSystem.Spacing.sm)
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            statPill(
                text: "\(cardCount) cards",
                icon: "rectangle.on.rectangle"
            )
            if dueCount > 0 {
                statPill(
                    text: "\(dueCount) due",
                    icon: "clock.arrow.circlepath"
                )
            }
        }
    }

    func statPill(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
            Text(text)
                .font(DesignSystem.Font.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.9))
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, 4)
        .background(DesignSystem.Color.onAccent.opacity(0.18))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(DesignSystem.Color.onAccent.opacity(0.25), lineWidth: 1))
    }
}
