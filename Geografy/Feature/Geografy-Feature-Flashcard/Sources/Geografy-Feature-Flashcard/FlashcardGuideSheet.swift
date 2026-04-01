import Geografy_Core_DesignSystem
import SwiftUI

public struct FlashcardGuideSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animating = false

    private let illustrations = FlashcardIllustration.allCases

    public var body: some View {
        GuideSheet(pages: FlashcardGuide.pages) { index in
            illustrationView(for: illustrations[index])
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 2).repeatForever(autoreverses: true), value: animating)
        .onAppear { animating = true }
    }
}

// MARK: - Illustrations
private extension FlashcardGuideSheet {
    @ViewBuilder
    func illustrationView(for type: FlashcardIllustration) -> some View {
        switch type {
        case .tapToFlip: tapToFlipIllustration
        case .swipeToRate: swipeToRateIllustration
        case .ratingButtons: ratingButtonsIllustration
        case .spacedRepetition: spacedRepetitionIllustration
        case .proTips: proTipsIllustration
        }
    }

    var tapToFlipIllustration: some View {
        ZStack {
            cardMock(front: true)
                .rotation3DEffect(.degrees(animating ? 0 : 8), axis: (x: 0, y: 1, z: 0))
            handIcon
                .offset(y: animating ? 10 : -10)
        }
        .frame(height: 200)
    }

    var swipeToRateIllustration: some View {
        ZStack {
            cardMock(front: false)
                .offset(x: animating ? 40 : -40)
                .rotationEffect(.degrees(animating ? 4 : -4))
            HStack(spacing: DesignSystem.Spacing.xxl) {
                swipeArrow(direction: .left, color: DesignSystem.Color.error)
                swipeArrow(direction: .right, color: DesignSystem.Color.success)
            }
        }
        .frame(height: 200)
    }

    var ratingButtonsIllustration: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ratingMock(label: "Wrong", color: DesignSystem.Color.error, icon: "xmark.circle.fill")
            ratingMock(label: "Struggled", color: DesignSystem.Color.orange, icon: "exclamationmark.triangle.fill")
            ratingMock(label: "Correct", color: DesignSystem.Color.accent, icon: "checkmark.circle.fill")
            ratingMock(label: "Knew It", color: DesignSystem.Color.success, icon: "bolt.circle.fill")
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .frame(height: 200, alignment: .center)
    }

    var spacedRepetitionIllustration: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(["1d", "3d", "7d", "14d"].enumerated()), id: \.offset) { index, label in
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(DesignSystem.Color.accent.opacity(0.15 + Double(index) * 0.2))
                        .frame(width: 50, height: CGFloat(40 + index * 25))
                    Text(label)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .scaleEffect(animating ? 1.0 : 0.9)
                .animation(
                    reduceMotion
                        ? .default
                        : .easeInOut(duration: 2).repeatForever(autoreverses: true).delay(Double(index) * 0.2),
                    value: animating
                )
            }
        }
        .frame(height: 200, alignment: .center)
    }

    var proTipsIllustration: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.08))
                .frame(width: 160, height: 160)
                .scaleEffect(animating ? 1.1 : 0.9)
            Image(systemName: "lightbulb.fill")
                .font(DesignSystem.Font.display)
                .foregroundStyle(DesignSystem.Color.accent)
                .scaleEffect(animating ? 1.05 : 0.95)
        }
        .frame(height: 200)
    }
}

// MARK: - Illustration Helpers
private extension FlashcardGuideSheet {
    func cardMock(front: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(DesignSystem.Color.cardBackgroundHighlighted, lineWidth: 1)
            )
            .overlay {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(front ? "🇵🇹" : "Lisbon")
                        .font(front ? .system(size: 40) : DesignSystem.Font.title2)
                    Text(front ? "What is the capital?" : "Tap to flip")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .frame(width: 160, height: 120)
    }

    var handIcon: some View {
        Image(systemName: "hand.tap.fill")
            .font(DesignSystem.Font.iconLarge)
            .foregroundStyle(DesignSystem.Color.accent.opacity(0.6))
            .offset(x: 50, y: 40)
    }

    enum SwipeDirection { case left, right }

    func swipeArrow(direction: SwipeDirection, color: Color) -> some View {
        Image(systemName: direction == .left ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
            .font(DesignSystem.Font.iconXL)
            .foregroundStyle(color.opacity(animating ? 0.8 : 0.3))
    }

    func ratingMock(label: String, color: Color, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(color.opacity(0.25), lineWidth: 1)
        )
    }
}
