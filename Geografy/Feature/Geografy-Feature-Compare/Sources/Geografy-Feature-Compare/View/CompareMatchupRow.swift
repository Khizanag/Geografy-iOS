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
