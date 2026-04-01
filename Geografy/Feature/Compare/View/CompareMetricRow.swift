import Geografy_Core_DesignSystem
import SwiftUI

struct CompareMetricRow: View {
    let title: String
    let icon: String
    let leftValue: String
    let rightValue: String
    var match: Bool?
    var footer: String?

    var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                headerRow
                valuesRow
                footerRow
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension CompareMetricRow {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer(minLength: 0)
            matchBadge
        }
    }

    var valuesRow: some View {
        HStack(alignment: .top) {
            Text(leftValue)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(rightValue)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .trailing)
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
            .foregroundStyle(match ? DesignSystem.Color.success : DesignSystem.Color.textTertiary)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 2)
            .background(
                (match ? DesignSystem.Color.success : DesignSystem.Color.textTertiary)
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
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
