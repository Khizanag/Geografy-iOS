import SwiftUI

struct FlashcardCardView: View {
    let card: FlashcardItem
    let isFlipped: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            frontSide
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            backSide
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Subviews

private extension FlashcardCardView {
    var frontSide: some View {
        cardFace {
            VStack(spacing: DesignSystem.Spacing.md) {
                typeLabel
                frontContent
                tapHint
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    var backSide: some View {
        cardFace {
            VStack(spacing: DesignSystem.Spacing.md) {
                answerLabel
                backContent
                swipeHint
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    var typeLabel: some View {
        Text(card.type.promptLabel)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var answerLabel: some View {
        Text("Answer")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var swipeHint: some View {
        Label("Swipe to rate", systemImage: "hand.draw.fill")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }

    @ViewBuilder
    var frontContent: some View {
        if card.showsFlagOnFront {
            FlagView(countryCode: card.countryCode, height: 80)
        } else {
            Text(card.frontText)
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(3)
        }
    }

    @ViewBuilder
    var backContent: some View {
        if card.showsFlagOnBack {
            FlagView(countryCode: card.countryCode, height: 80)
        } else {
            Text(card.backText)
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(3)
        }
    }

    var tapHint: some View {
        Label("Tap to reveal", systemImage: "hand.tap.fill")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }

    func cardFace<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .strokeBorder(
                        DesignSystem.Color.cardBackgroundHighlighted,
                        lineWidth: 1
                    )
            )
            .geoShadow(.elevated)
    }
}
