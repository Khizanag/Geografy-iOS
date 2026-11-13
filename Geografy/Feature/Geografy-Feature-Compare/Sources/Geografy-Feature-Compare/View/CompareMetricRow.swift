import Geografy_Core_DesignSystem
import SwiftUI

public struct CompareMetricRow: View {
    // MARK: - Properties
    public let title: String
    public let icon: String
    public let leftValue: String
    public let rightValue: String
    public var match: Bool?
    public var footer: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    public var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                headerRow
                valuesRow
                footerRow
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(accessibilitySummary)
    }
}

// MARK: - Subviews
private extension CompareMetricRow {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer(minLength: 0)
            matchBadge
        }
    }

    var valuesRow: some View {
        let isStacked = dynamicTypeSize.isAccessibilitySize
        let layout = isStacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.xs))
            : AnyLayout(HStackLayout(alignment: .top))
        return layout {
            Text(leftValue)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(isStacked ? nil : 2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(rightValue)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(isStacked ? .leading : .trailing)
                .lineLimit(isStacked ? nil : 2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: isStacked ? .leading : .trailing)
        }
    }

    @ViewBuilder
    var matchBadge: some View {
        if let match {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: match ? "checkmark" : "xmark")
                    .font(DesignSystem.Font.nano.bold())
                Text(match ? "Match" : "Different")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(match ? DesignSystem.Color.success : DesignSystem.Color.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 2)
            .background(
                (match ? DesignSystem.Color.success : DesignSystem.Color.textSecondary)
                    .opacity(0.12),
                in: Capsule()
            )
        }
    }

    @ViewBuilder
    var footerRow: some View {
        if let footer {
            Text(footer)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Accessibility
private extension CompareMetricRow {
    var accessibilitySummary: String {
        var parts = ["First country \(leftValue)", "second country \(rightValue)"]
        if let match {
            parts.append(match ? "Match" : "Different")
        }
        if let footer {
            parts.append(footer)
        }
        return parts.joined(separator: ", ")
    }
}
