import Geografy_Core_DesignSystem
import SwiftUI

public struct CompareBarChart: View {
    // MARK: - Properties
    public let title: String
    public let icon: String
    public let leftValue: Double
    public let rightValue: Double
    public let leftLabel: String
    public let rightLabel: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false

    // MARK: - Body
    public var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                headerRow
                barsRow
                labelsRow
            }
            .padding(DesignSystem.Spacing.md)
        }
        .onAppear { appeared = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilitySummary)
    }
}

// MARK: - Subviews
private extension CompareBarChart {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .accessibilityHidden(true)
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer(minLength: 0)
            winnerBadge
        }
    }

    var barsRow: some View {
        GeometryReader { geometry in
            HStack(spacing: DesignSystem.Spacing.xs) {
                leftBar(totalWidth: geometry.size.width)
                rightBar(totalWidth: geometry.size.width)
            }
        }
        .frame(height: DesignSystem.Spacing.lg)
    }

    var labelsRow: some View {
        HStack(alignment: .firstTextBaseline) {
            valueLabel(leftLabel, side: .left)
            Spacer(minLength: DesignSystem.Spacing.sm)
            valueLabel(rightLabel, side: .right)
        }
    }

    func valueLabel(_ text: String, side: PairSide) -> some View {
        Text(text)
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(side.color)
            .multilineTextAlignment(side == .left ? .leading : .trailing)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }

    /// How many times larger the leader is, in the leader's color.
    @ViewBuilder
    var winnerBadge: some View {
        if leftValue != rightValue {
            InfoPill(winnerRatio, style: .tinted(leaderSide.color))
        }
    }
}

// MARK: - Bar Views
private extension CompareBarChart {
    func leftBar(totalWidth: CGFloat) -> some View {
        let fraction = barFraction(value: leftValue)
        let barWidth = max(
            totalWidth * 0.5 * (appeared || reduceMotion ? fraction : 0),
            DesignSystem.Spacing.xxs
        )
        return HStack(spacing: 0) {
            Spacer(minLength: 0)
            Capsule()
                .fill(PairSide.left.color)
                .frame(width: barWidth)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7).delay(0.2),
                    value: appeared
                )
        }
        .frame(maxWidth: .infinity)
    }

    func rightBar(totalWidth: CGFloat) -> some View {
        let fraction = barFraction(value: rightValue)
        let barWidth = max(
            totalWidth * 0.5 * (appeared || reduceMotion ? fraction : 0),
            DesignSystem.Spacing.xxs
        )
        return HStack(spacing: 0) {
            Capsule()
                .fill(PairSide.right.color)
                .frame(width: barWidth)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7).delay(0.2),
                    value: appeared
                )
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers
private extension CompareBarChart {
    func barFraction(value: Double) -> Double {
        let maxValue = max(leftValue, rightValue)
        guard maxValue > 0 else { return 0 }
        return value / maxValue
    }

    var leaderSide: PairSide {
        leftValue > rightValue ? .left : .right
    }

    var winnerRatio: String {
        let larger = max(leftValue, rightValue)
        let smaller = min(leftValue, rightValue)
        guard smaller > 0 else { return "N/A" }
        let ratio = larger / smaller
        // Same fixed format as the app's other figures, so decimals never switch to commas.
        return String(format: ratio >= 10 ? "%.0f×" : "%.1f×", ratio)
    }

    var accessibilitySummary: String {
        let summary = "First country \(leftLabel), second country \(rightLabel)"
        guard leftValue != rightValue else { return summary }
        let leader = leftValue > rightValue ? "First" : "Second"
        return "\(summary). \(leader) country is larger by \(winnerRatio)"
    }
}
