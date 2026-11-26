import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// One flashcard: the question on its front and the answer on its back, turned over in 3D. One angle drives both
/// faces, and each shows only on its own half of the turn, so the flip never shows both or neither.
struct FlashcardCardView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let card: FlashcardItem
    let isFlipped: Bool
    /// How much of the faces' content shows: a card waiting in the stack is blank until it comes forward.
    var contentOpacity: Double = 1
    let onShowDetails: () -> Void

    // MARK: - Body
    var body: some View {
        ZStack {
            FlashcardFace(contentOpacity: contentOpacity) { front }
                .modifier(FlipFace(angle: flipAngle, side: .front, perspective: perspective))
            FlashcardFace(contentOpacity: contentOpacity) { back }
                .modifier(FlipFace(angle: flipAngle, side: .back, perspective: perspective))
        }
    }
}

// MARK: - Faces
private extension FlashcardCardView {
    var front: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            InfoPill(card.type.promptLabel, systemImage: card.type.icon, style: .tinted(FlashcardStyle.color))
            Spacer(minLength: 0)
            prompt
            Spacer(minLength: 0)
            Label("Tap to flip", systemImage: "hand.tap.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var back: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            InfoPill("Answer", systemImage: "checkmark.seal.fill", style: .tinted(DesignSystem.Color.success))
            Spacer(minLength: 0)
            answer
            Spacer(minLength: 0)
            // Not glass: glass draws in its own pass, apart from the card as it turns and tilts.
            Button("Country Details", systemImage: "info.circle", action: onShowDetails)
                .font(DesignSystem.Font.subheadline)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(FlashcardStyle.color)
        }
    }

    @ViewBuilder
    var prompt: some View {
        switch card.type {
        case .countryToCapital:
            VStack(spacing: DesignSystem.Spacing.md) {
                FlagView(countryCode: card.countryCode, height: FlashcardStyle.smallFlagHeight)
                headline(card.countryName)
            }
        case .flagToCountry:
            FlagView(countryCode: card.countryCode, height: FlashcardStyle.largeFlagHeight)
        case .capitalToCountry:
            headline(card.capital)
        case .countryToFlag:
            headline(card.countryName)
        }
    }

    @ViewBuilder
    var answer: some View {
        switch card.type {
        case .countryToCapital:
            VStack(spacing: DesignSystem.Spacing.sm) {
                spokenHeadline(card.capital)
                context(card.countryName)
            }
        case .flagToCountry, .capitalToCountry:
            VStack(spacing: DesignSystem.Spacing.sm) {
                spokenHeadline(card.countryName)
                context(card.capital)
            }
        case .countryToFlag:
            VStack(spacing: DesignSystem.Spacing.md) {
                FlagView(countryCode: card.countryCode, height: FlashcardStyle.largeFlagHeight)
                Text(card.countryName)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    func headline(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .lineLimit(3)
    }

    func spokenHeadline(_ text: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            headline(text)
            #if !os(tvOS)
            SpeakerButton(text: text, countryCode: card.countryCode, backing: .fill)
            #endif
        }
    }

    /// The country around the answer: its flag and the name the answer belongs to.
    func context(_ text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: card.countryCode, height: DesignSystem.Size.Flag.inline)
            Text(text)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Flip
private extension FlashcardCardView {
    var flipAngle: Double { isFlipped ? 180 : 0 }

    /// Under Reduce Motion the card doesn't turn in depth; the faces cross at the halfway mark instead.
    var perspective: CGFloat { reduceMotion ? 0 : FlashcardStyle.perspective }
}

/// One face of a card at a point in its turn: shown only on its own half, so the swap lands exactly edge-on.
private struct FlipFace: ViewModifier, Animatable {
    enum Side { case front, back }

    var angle: Double
    let side: Side
    let perspective: CGFloat

    nonisolated var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        let isShowing = side == .front ? angle < 90 : angle >= 90
        content
            .opacity(isShowing ? 1 : 0)
            .rotation3DEffect(
                .degrees(perspective == 0 ? 0 : (side == .front ? angle : angle - 180)),
                axis: (x: 0, y: 1, z: 0),
                perspective: perspective
            )
            .accessibilityHidden(!isShowing)
    }
}

// MARK: - Face
/// The card itself: an opaque card the content sits on, with the card corner and a lift off the page.
private struct FlashcardFace<Content: View>: View {
    let contentOpacity: Double
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .opacity(contentOpacity)
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: FlashcardStyle.cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: FlashcardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
            }
            .geoShadow(.elevated)
    }
}

// MARK: - Style
/// Flashcards' look, shared by the card, its stack, and the rating bar.
enum FlashcardStyle {
    /// Flashcards' own colour on the Play tab (Geografy's identity marks).
    static let color = DesignSystem.Color.purple
    static let cornerRadius = DesignSystem.CornerRadius.card
    static let perspective: CGFloat = 0.45
    static let smallFlagHeight: CGFloat = 56
    static let largeFlagHeight: CGFloat = 120
}
