import SwiftUI

struct CompareBarChart: View {
    let title: String
    let icon: String
    let leftValue: Double
    let rightValue: Double
    let leftLabel: String
    let rightLabel: String

    @State private var appeared = false

    var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                headerRow
                barsRow
                labelsRow
            }
            .padding(DesignSystem.Spacing.md)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Subviews
private extension CompareBarChart {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
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
        HStack {
            Text(leftLabel)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            Text(rightLabel)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder
    var winnerBadge: some View {
        if leftValue != rightValue {
            let ratio = winnerRatio
            Text(ratio)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, 2)
                .background(DesignSystem.Color.accent, in: Capsule())
        }
    }
}

// MARK: - Bar Views
private extension CompareBarChart {
    func leftBar(totalWidth: CGFloat) -> some View {
        let fraction = barFraction(value: leftValue)
        let barWidth = max(
            totalWidth * 0.5 * (appeared ? fraction : 0),
            DesignSystem.Spacing.xxs
        )
        return HStack(spacing: 0) {
            Spacer(minLength: 0)
            Capsule()
                .fill(DesignSystem.Color.blue)
                .frame(width: barWidth)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7).delay(0.2),
                    value: appeared
                )
        }
        .frame(maxWidth: .infinity)
    }

    func rightBar(totalWidth: CGFloat) -> some View {
        let fraction = barFraction(value: rightValue)
        let barWidth = max(
            totalWidth * 0.5 * (appeared ? fraction : 0),
            DesignSystem.Spacing.xxs
        )
        return HStack(spacing: 0) {
            Capsule()
                .fill(DesignSystem.Color.orange)
                .frame(width: barWidth)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7).delay(0.2),
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

    var winnerRatio: String {
        let larger = max(leftValue, rightValue)
        let smaller = min(leftValue, rightValue)
        guard smaller > 0 else { return "N/A" }
        let ratio = larger / smaller
        return String(format: "%.1fx", ratio)
    }
}
