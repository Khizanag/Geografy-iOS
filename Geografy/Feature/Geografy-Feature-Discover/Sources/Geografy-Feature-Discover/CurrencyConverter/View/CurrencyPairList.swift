import Geografy_Core_DesignSystem
import SwiftUI

/// Ready-made pairs to open, such as popular or recent ones: "USD → EUR" with both flags.
struct CurrencyPairList: View {
    // MARK: - Properties
    let pairs: [CurrencyEntryPair]
    let onSelect: (CurrencyEntryPair) -> Void

    // MARK: - Body
    var body: some View {
        RowListCard(
            pairs,
            dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagPairWidth)
        ) { pair in
            FlagPairRow(
                leftFlagCode: pair.from.flagCode,
                rightFlagCode: pair.to.flagCode,
                title: "\(pair.from.code) → \(pair.to.code)",
                subtitle: "\(pair.from.name) to \(pair.to.name)",
                accessibilityLabel: "\(pair.from.name) to \(pair.to.name)"
            ) {
                onSelect(pair)
            }
        }
    }
}
