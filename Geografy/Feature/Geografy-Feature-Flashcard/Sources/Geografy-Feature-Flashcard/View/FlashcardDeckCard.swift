import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct FlashcardDeckCard: View {
    // MARK: - Properties
    public let deck: FlashcardDeck
    public let cardCount: Int
    public let proficiencyPercentage: Double
    public let dueCount: Int

    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            backgroundIcon
            cardInfo
        }
        .frame(height: 150)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
        )
        .geoShadow(.card)
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
            InfoPill("\(cardCount) cards", systemImage: "rectangle.on.rectangle", style: .onColor)
            if dueCount > 0 {
                InfoPill("\(dueCount) due", systemImage: "clock.arrow.circlepath", style: .onColor)
            }
        }
    }
}
