import Geografy_Core_DesignSystem
import SwiftUI

/// A ready reckoner: round amounts and what they convert to. Tapping one puts it in the amount field.
struct CurrencyQuickAmountsView: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let from: CurrencyEntry
    let to: CurrencyEntry
    let rate: Double
    let onSelect: (Double) -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quick Amounts")
            RowListCard(QuickAmounts.rows(rate: rate), dividerInset: DesignSystem.Spacing.md) { row in
                Button {
                    onSelect(row.amount)
                } label: {
                    rowContent(row)
                }
                .buttonStyle(PressButtonStyle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityText(for: row))
                .accessibilityHint("Converts this amount")
            }
        }
    }
}

// MARK: - Subviews
private extension CurrencyQuickAmountsView {
    func rowContent(_ row: QuickAmount) -> some View {
        let isStacked = dynamicTypeSize.isAccessibilitySize
        let layout = isStacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.xxs))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.sm))
        return layout {
            amountText(CurrencyAmountFormatter.inputString(for: row.amount), code: from.code, side: .left)
            if !isStacked {
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
                Spacer(minLength: DesignSystem.Spacing.sm)
            }
            amountText(CurrencyAmountFormatter.string(for: row.converted), code: to.code, side: .right)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rowListCardRow()
    }

    func amountText(_ value: String, code: String, side: PairSide) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xxs) {
            Text(value)
                .font(DesignSystem.Font.monoSmall)
                .foregroundStyle(side == .left ? DesignSystem.Color.textPrimary : side.color)
            Text(code)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    func accessibilityText(for row: QuickAmount) -> String {
        let amount = CurrencyAmountFormatter.inputString(for: row.amount)
        let converted = CurrencyAmountFormatter.string(for: row.converted)
        return "\(amount) \(from.name) is \(converted) \(to.name)"
    }
}
