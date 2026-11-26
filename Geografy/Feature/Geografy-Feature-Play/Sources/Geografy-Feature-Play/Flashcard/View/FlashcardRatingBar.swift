#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

/// The session's controls under the card, in one place and one height whether the card shows its question or its
/// answer, so nothing on screen moves when it turns: Show Answer first, then the four ratings, each with when the
/// card comes back.
struct FlashcardRatingBar: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .caption) private var height: CGFloat = 72

    let isFlipped: Bool
    /// When the card comes back after each rating, such as "3d".
    let nextReview: (FlashcardReviewResult) -> String
    let onShowAnswer: () -> Void
    let onRate: (FlashcardReviewResult) -> Void

    @State private var pressCount = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            showAnswerButton
                .opacity(isFlipped ? 0 : 1)
                .allowsHitTesting(!isFlipped)
                .accessibilityHidden(isFlipped)
            ratings
                .opacity(isFlipped ? 1 : 0)
                .scaleEffect(isFlipped || reduceMotion ? 1 : 0.96)
                .allowsHitTesting(isFlipped)
                .accessibilityHidden(!isFlipped)
        }
        .frame(height: height)
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.3), value: isFlipped)
        .haptic(.impact(weight: .light), trigger: pressCount)
    }
}

// MARK: - Subviews
private extension FlashcardRatingBar {
    var showAnswerButton: some View {
        GlassButton("Show Answer", systemImage: "arrow.trianglehead.2.clockwise.rotate.90", fullWidth: true) {
            onShowAnswer()
        }
    }

    var ratings: some View {
        GlassEffectContainer(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(FlashcardReviewResult.allCases) { result in
                    ratingButton(result)
                }
            }
        }
    }

    func ratingButton(_ result: FlashcardReviewResult) -> some View {
        Button {
            pressCount += 1
            onRate(result)
        } label: {
            VStack(spacing: DesignSystem.Spacing.xxxs) {
                Image(systemName: result.icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(result.color)
                Text(result.displayName)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(nextReview(result))
                    .font(DesignSystem.Font.caption2)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.roundedRectangle(radius: DesignSystem.CornerRadius.card))
        .accessibilityLabel(Text(result.displayName))
        .accessibilityValue(Text("Comes back \(nextReview(result))", bundle: .module))
    }
}
#endif
