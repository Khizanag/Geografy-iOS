import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI
import Geografy_Core_Service

public struct FlashcardCardView: View {
    @Environment(PronunciationService.self) private var pronunciationService

    public let card: FlashcardItem
    public let isFlipped: Bool
    public let onTap: () -> Void
    public var swipeColor: Color = .clear
    public var swipeOpacity: Double = 0

    public var body: some View {
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
                #if !os(tvOS)
                if !card.backText.isEmpty {
                    SpeakerButton(text: card.backText, countryCode: card.countryCode)
                }
                #endif
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
            .background(
                ZStack {
                    DesignSystem.Color.cardBackground
                    swipeColor.opacity(swipeOpacity)
                }
            )
            .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .strokeBorder(
                        swipeOpacity > 0
                            ? swipeColor.opacity(swipeOpacity * 2)
                            : DesignSystem.Color.cardBackgroundHighlighted,
                        lineWidth: swipeOpacity > 0 ? 2 : 1
                    )
                    .animation(.interactiveSpring(response: 0.15), value: swipeOpacity)
            )
            .geoShadow(.elevated)
    }
}
