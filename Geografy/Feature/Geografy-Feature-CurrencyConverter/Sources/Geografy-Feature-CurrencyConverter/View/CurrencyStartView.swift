import Geografy_Core_DesignSystem
import SwiftUI

/// What the converter shows until both currencies are picked: major currencies for the empty side, or popular pairs.
struct CurrencyStartView: View {
    // MARK: - Properties
    let fromCurrency: CurrencyEntry?
    let toCurrency: CurrencyEntry?
    let currencies: [CurrencyEntry]
    let onChoose: (CurrencyEntry, PairSide) -> Void
    let onChoosePair: (CurrencyEntryPair) -> Void
    let onShuffle: () -> Void

    // MARK: - Body
    var body: some View {
        if let picked = fromCurrency ?? toCurrency {
            suggestionsSection(for: picked, filling: fromCurrency == nil ? .left : .right)
        } else {
            popularSection
        }
    }
}

// MARK: - Sections
private extension CurrencyStartView {
    func suggestionsSection(for picked: CurrencyEntry, filling side: PairSide) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header(title: side == .right ? "Convert To" : "Convert From")
            RowListCard(
                CurrencyCatalog.major(in: currencies, excluding: picked.code),
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagWidth)
            ) { currency in
                Button {
                    onChoose(currency, side)
                } label: {
                    FlagListRow(
                        flagCode: currency.flagCode,
                        title: currency.name,
                        subtitle: "\(currency.code) · \(currency.usageSummary)"
                    ) {
                        RowChevron()
                    }
                    .rowListCardRow()
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }

    var popularSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header(title: "Popular Pairs")
            CurrencyPairList(
                pairs: CurrencyEntryPair.resolve(CurrencyPair.popular, in: currencies),
                onSelect: onChoosePair
            )
        }
    }

    func header(title: String) -> some View {
        HStack {
            SectionHeaderView(title: title)
            Spacer(minLength: DesignSystem.Spacing.sm)
            Button("Shuffle", systemImage: "shuffle", action: onShuffle)
                .buttonStyle(.glass)
                .controlSize(.small)
                .accessibilityLabel("Pick at random")
        }
    }
}
