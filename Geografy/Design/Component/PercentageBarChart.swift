import SwiftUI

struct PercentageBarChart: View {
    let title: String
    let icon: String
    let items: [PercentageItem]
    let appeared: Bool

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                headerRow
                ForEach(Array(items.enumerated()), id: \.element.name) { index, item in
                    itemRow(item: item, index: index)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension PercentageBarChart {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func itemRow(item: PercentageItem, index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(item.name)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: 110, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    Capsule()
                        .fill(barColor(for: index))
                        .frame(width: geo.size.width * min(appeared ? item.percentage / 100 : 0, 1))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(0.3 + Double(index) * 0.08),
                            value: appeared
                        )
                }
            }
            .frame(height: DesignSystem.Spacing.xs)

            Text(String(format: "%.0f%%", item.percentage))
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(width: DesignSystem.Spacing.xl, alignment: .trailing)
        }
    }
}

// MARK: - Helpers
private extension PercentageBarChart {
    func barColor(for index: Int) -> Color {
        let opacity = max(1.0 - Double(index) * 0.15, 0.3)
        return DesignSystem.Color.accent.opacity(opacity)
    }
}
