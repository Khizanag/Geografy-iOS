import Geografy_Core_DesignSystem
import SwiftUI

/// One level of a pack as a compact tile in the level grid: its number, or a lock, and the stars earned.
/// The level to play next stands out in the pack's color.
struct QuizPackLevelTile: View {
    // MARK: - Properties
    let level: QuizPackLevel
    let stars: Int
    let isLocked: Bool
    let isNext: Bool
    let color: Color

    // MARK: - Body
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            badge
            starRow
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.card)
        )
        .overlay {
            if isNext {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                    .strokeBorder(color, lineWidth: 2)
            }
        }
        .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.card))
        .opacity(isLocked ? 0.55 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Level \(level.levelIndex)"))
        .accessibilityValue(accessibilityValue)
    }
}

// MARK: - Subviews
private extension QuizPackLevelTile {
    var badge: some View {
        ZStack {
            Circle()
                .fill(badgeFill)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            } else {
                Text(verbatim: "\(level.levelIndex)")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(numberColor)
            }
        }
    }

    var starRow: some View {
        HStack(spacing: DesignSystem.Spacing.xxxs) {
            ForEach(1...3, id: \.self) { index in
                Image(systemName: index <= stars ? "star.fill" : "star")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(index <= stars ? DesignSystem.Color.warning : DesignSystem.Color.textTertiary)
            }
        }
    }
}

// MARK: - Helpers
private extension QuizPackLevelTile {
    var isCompleted: Bool { stars > 0 }

    var badgeFill: Color {
        if isLocked { return DesignSystem.Color.cardBackgroundHighlighted }
        if isNext || isCompleted { return color }
        return DesignSystem.Color.cardBackgroundHighlighted
    }

    var numberColor: Color {
        isNext || isCompleted ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary
    }

    var accessibilityValue: Text {
        if isLocked { return Text("Locked") }
        if isCompleted { return Text("\(stars) of 3 stars") }
        return isNext ? Text("Up next") : Text("Not played")
    }
}
