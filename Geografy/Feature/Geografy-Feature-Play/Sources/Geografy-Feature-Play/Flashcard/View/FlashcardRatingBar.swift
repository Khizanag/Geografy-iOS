#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

/// The session's controls under the card, in one place and one height whether the card shows its question or its
/// answer, so nothing on screen moves when it turns: Show Answer first, then Wrong and Got It, on the sides a swipe
/// sends the card.
struct FlashcardRatingBar: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .headline) private var height: CGFloat = 56

    let isFlipped: Bool
    let onShowAnswer: () -> Void
    let onAnswer: (_ knewIt: Bool) -> Void

    // MARK: - Body
    var body: some View {
        ZStack {
            GlassButton("Show Answer", systemImage: "arrow.trianglehead.2.clockwise.rotate.90", fullWidth: true) {
                onShowAnswer()
            }
            .opacity(isFlipped ? 0 : 1)
            .allowsHitTesting(!isFlipped)
            .accessibilityHidden(isFlipped)
            answers
                .opacity(isFlipped ? 1 : 0)
                .scaleEffect(isFlipped || reduceMotion ? 1 : 0.96)
                .allowsHitTesting(isFlipped)
                .accessibilityHidden(!isFlipped)
        }
        .frame(height: height)
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.3), value: isFlipped)
    }
}

// MARK: - Subviews
private extension FlashcardRatingBar {
    var answers: some View {
        GlassEffectContainer(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                GlassButton("Wrong", systemImage: "xmark", role: .destructive, fullWidth: true) {
                    onAnswer(false)
                }
                GlassButton("Got It", systemImage: "checkmark", fullWidth: true) {
                    onAnswer(true)
                }
            }
        }
    }
}
#endif
