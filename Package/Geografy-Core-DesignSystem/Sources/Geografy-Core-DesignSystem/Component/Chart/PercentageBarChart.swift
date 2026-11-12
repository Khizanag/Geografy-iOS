import Geografy_Core_Common
import SwiftUI

/// Ranked share bars. Every bar uses one color — length carries the value — and the catch-all "Other" row
/// always comes last in a neutral color.
public struct PercentageBarChart: View {
    // MARK: - Properties
    public let title: String?
    public let icon: String?
    public let items: [PercentageItem]
    public let appeared: Bool

    // MARK: - Init
    public init(
        title: String? = nil,
        icon: String? = nil,
        items: [PercentageItem],
        appeared: Bool
    ) {
        self.title = title
        self.icon = icon
        self.items = items
        self.appeared = appeared
    }

    // MARK: - Body
    public var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if let title, let icon {
                    headerRow(title: title, icon: icon)
                }
                ForEach(Array(rankedItems.enumerated()), id: \.element.name) { index, item in
                    itemRow(item: item, index: index)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension PercentageBarChart {
    func headerRow(title: String, icon: String) -> some View {
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
                        .fill(barColor(for: item))
                        .frame(width: barWidth(for: item, in: geo.size))
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
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: DesignSystem.Spacing.xl, alignment: .trailing)
        }
    }
}

// MARK: - Helpers
private extension PercentageBarChart {
    var rankedItems: [PercentageItem] {
        let ranked = items.sorted(by: \.percentage, descending: true)
        return ranked.filter { !isCatchAll($0) } + ranked.filter(isCatchAll)
    }

    func isCatchAll(_ item: PercentageItem) -> Bool {
        item.name == "Other" || item.name.hasPrefix("Other (")
    }

    func barColor(for item: PercentageItem) -> Color {
        isCatchAll(item) ? DesignSystem.Color.textTertiary : DesignSystem.Color.accent
    }

    // A nonzero share never shrinks below a dot, so 1% rows stay visible.
    func barWidth(for item: PercentageItem, in size: CGSize) -> CGFloat {
        guard appeared, item.percentage > 0 else { return 0 }
        let share = size.width * min(item.percentage / 100, 1)
        return max(share, size.height)
    }
}
