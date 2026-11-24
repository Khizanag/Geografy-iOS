import Geografy_Core_DesignSystem
import SwiftUI

/// The other player during a match: their name, their score, and what they're doing now, such as "Locked in".
/// Every game shows it the same way, under its prompt.
struct MatchOpponentChip: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let name: String
    let score: String
    let status: String
    let systemImage: String

    // MARK: - Body
    var body: some View {
        Label("\(name) · \(score) · \(status)", systemImage: systemImage)
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .monospacedDigit()
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .glassEffect(.regular, in: .capsule)
            .contentTransition(.numericText())
            .animation(reduceMotion ? nil : .smooth, value: "\(score)\(status)")
    }
}

/// Shown once this player has played every round and the match waits for the other player.
struct MatchWaitingCard: View {
    let opponentName: String

    var body: some View {
        Label(
            String(localized: "Waiting for \(opponentName) to finish…", bundle: .module),
            systemImage: "hourglass"
        )
        .font(DesignSystem.Font.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(DesignSystem.Color.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.large))
    }
}
