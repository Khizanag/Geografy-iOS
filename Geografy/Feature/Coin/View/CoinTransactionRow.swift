import SwiftUI
import GeografyCore
import GeografyDesign

struct CoinTransactionRow: View {
    let transaction: CoinTransaction

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            iconCircle
            details
            Spacer()
            amountLabel
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Subviews
private extension CoinTransactionRow {
    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor.opacity(0.15))
                .frame(
                    width: DesignSystem.Size.lg,
                    height: DesignSystem.Size.lg
                )
            Image(systemName: transaction.reason.icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(iconBackgroundColor)
        }
    }

    var details: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(transaction.reason.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(formattedDate)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var amountLabel: some View {
        Text(formattedAmount)
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(amountColor)
    }
}

// MARK: - Helpers
private extension CoinTransactionRow {
    var isEarning: Bool { transaction.amount > 0 }

    var iconBackgroundColor: Color {
        isEarning ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    var amountColor: Color {
        isEarning ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let absolute = abs(transaction.amount)
        let formatted = formatter.string(from: NSNumber(value: absolute)) ?? "\(absolute)"
        return isEarning ? "+\(formatted)" : "-\(formatted)"
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: transaction.date, relativeTo: Date())
    }
}
