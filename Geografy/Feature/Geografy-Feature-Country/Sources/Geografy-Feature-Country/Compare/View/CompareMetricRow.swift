import Geografy_Core_DesignSystem
import SwiftUI

public struct CompareMetricRow: View {
    // MARK: - Properties
    public let title: String
    public let icon: String
    public let leftValue: String
    public let rightValue: String
    public var match: Bool?
    /// What both countries have, such as shared memberships, listed as pills under the values.
    public var sharedItems: [String]?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    public var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                headerRow
                valuesRow
                sharedItemsRow
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
                .foregroundStyle(DesignSystem.Color.textSecondary)
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
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(isStacked ? nil : 2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(rightValue)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(isStacked ? .leading : .trailing)
                .lineLimit(isStacked ? nil : 2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: isStacked ? .leading : .trailing)
        }
    }

    /// Only a shared value is worth a badge; "Different" on every other row is noise.
    @ViewBuilder
    var matchBadge: some View {
        if match == true {
            InfoPill("Same", systemImage: "equal")
        } else if let sharedItems, !sharedItems.isEmpty {
            InfoPill("\(sharedItems.count) shared")
        }
    }

    @ViewBuilder
    var sharedItemsRow: some View {
        if let sharedItems {
            Group {
                if sharedItems.isEmpty {
                    Text("None in common")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                } else {
                    FlowLayout(spacing: DesignSystem.Spacing.xs) {
                        ForEach(sharedItems, id: \.self) { item in
                            InfoPill(item)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, DesignSystem.Spacing.xs)
        }
    }
}

// MARK: - Accessibility
private extension CompareMetricRow {
    var accessibilitySummary: String {
        var parts = ["First country \(leftValue)", "second country \(rightValue)"]
        if match == true {
            parts.append("Same")
        }
        if let sharedItems {
            parts.append(sharedItems.isEmpty ? "None in common" : "Shared: \(sharedItems.joined(separator: ", "))")
        }
        return parts.joined(separator: ", ")
    }
}
