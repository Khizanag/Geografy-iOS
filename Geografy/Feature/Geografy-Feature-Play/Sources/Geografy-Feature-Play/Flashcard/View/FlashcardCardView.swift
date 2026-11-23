import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct FlashcardCardView: View {
    // MARK: - Properties
    @Environment(PronunciationService.self) private var pronunciationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let card: FlashcardItem
    public let isFlipped: Bool
    public let onTap: () -> Void

    // MARK: - Body
    public var body: some View {
        ZStack {
            frontSide
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(reduceMotion ? 0 : (isFlipped ? 180 : 0)),
                    axis: (x: 0, y: 1, z: 0)
                )
            backSide
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(reduceMotion ? 0 : (isFlipped ? 0 : -180)),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.8),
            value: isFlipped
        )
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Flip card")
        .accessibilityValue(accessibilityFaceDescription)
        .accessibilityHint(isFlipped ? "Shows the question" : "Reveals the answer")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, onTap)
        .accessibilityAction(named: "Pronounce answer") { pronounceAnswer() }
    }
}

// MARK: - Accessibility
private extension FlashcardCardView {
    var accessibilityFaceDescription: String {
        if isFlipped {
            let answer = card.showsFlagOnBack ? "Flag of \(card.countryName)" : card.backText
            return "Answer: \(answer)"
        }
        let prompt = card.showsFlagOnFront ? "a flag" : card.frontText
        return "\(card.type.promptLabel): \(prompt)"
    }

    func pronounceAnswer() {
        let text = isFlipped && !card.backText.isEmpty ? card.backText : card.frontText
        guard !text.isEmpty else { return }
        pronunciationService.speak(text: text, countryCode: card.countryCode)
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
                .foregroundStyle(DesignSystem.Color.textPrimary)
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
            .background(SwipeTintFill())
            .clipShape(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
            )
            .overlay(SwipeTintBorder())
            .geoShadow(.elevated)
    }
}

// MARK: - Equatable
// The swipe tint arrives through the environment, so a drag frame redraws only the tint layers, not the faces.
extension FlashcardCardView: Equatable {
    nonisolated public static func == (lhs: FlashcardCardView, rhs: FlashcardCardView) -> Bool {
        lhs.card == rhs.card && lhs.isFlipped == rhs.isFlipped
    }
}

// MARK: - Swipe Tint
/// How strongly a swipe in progress tints the card: green toward "knew it", red toward "wrong".
struct FlashcardSwipeTint: Equatable {
    var color: Color = .clear
    var opacity: Double = 0
}

extension EnvironmentValues {
    @Entry var flashcardSwipeTint = FlashcardSwipeTint()
}

private struct SwipeTintFill: View {
    @Environment(\.flashcardSwipeTint) private var tint

    var body: some View {
        ZStack {
            DesignSystem.Color.cardBackground
            tint.color.opacity(tint.opacity)
        }
    }
}

private struct SwipeTintBorder: View {
    @Environment(\.flashcardSwipeTint) private var tint

    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
            .strokeBorder(
                tint.opacity > 0
                    ? tint.color.opacity(tint.opacity * 2)
                    : DesignSystem.Color.cardBackgroundHighlighted,
                lineWidth: tint.opacity > 0 ? 2 : 1
            )
            .animation(.interactiveSpring(response: 0.15), value: tint.opacity)
    }
}
