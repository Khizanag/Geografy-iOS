import Geografy_Core_DesignSystem
import SwiftUI

/// A saved or popular comparison: "France vs Germany" with both flags.
struct CompareMatchupRow: View {
    let pair: ComparisonPair
    let action: () -> Void

    var body: some View {
        FlagPairRow(
            leftFlagCode: pair.leftCode,
            rightFlagCode: pair.rightCode,
            title: "\(pair.leftName) vs \(pair.rightName)",
            accessibilityLabel: "\(pair.leftName) versus \(pair.rightName)",
            action: action
        )
    }
}

// MARK: - Menu
extension RowListMenu where Item == ComparisonPair {
    /// A comparison's long press: both countries, then Open, Copy, Share, and Remove.
    static func comparisons(
        open: @escaping (ComparisonPair) -> Void,
        remove: ((ComparisonPair) -> Void)? = nil
    ) -> Self {
        RowListMenu(open: open, text: shareText, remove: remove) { pair in
            FlagPairPreview(
                leftFlagCode: pair.leftCode,
                rightFlagCode: pair.rightCode,
                title: "\(pair.leftName) vs \(pair.rightName)",
                subtitle: String(localized: "Side by side, fact by fact", bundle: .module)
            )
        }
    }

    private static func shareText(_ pair: ComparisonPair) -> String {
        "\(pair.leftName) vs \(pair.rightName)"
    }
}
