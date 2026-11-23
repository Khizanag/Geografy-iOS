import Geografy_Core_DesignSystem
import SwiftUI

/// What a finished puzzle shows above the grid: whether every word was found, and how it went.
struct WordSearchResultCard: View {
    // MARK: - Properties
    let foundAll: Bool
    let foundCount: Int
    let revealedCount: Int
    let time: String

    // MARK: - Body
    var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: foundAll ? "trophy.fill" : "flag.checkered")
                    .font(DesignSystem.Font.iconXL)
                    .foregroundStyle(foundAll ? DesignSystem.Color.warning : DesignSystem.Color.textSecondary)
                    .accessibilityHidden(true)
                Text(foundAll ? "All Words Found" : "Puzzle Complete")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                StatTileRow {
                    StatTile(
                        value: "\(foundCount)",
                        label: "Found",
                        icon: "checkmark.circle.fill",
                        color: DesignSystem.Color.success,
                        style: .plain
                    )
                    StatTile(
                        value: "\(revealedCount)",
                        label: "Revealed",
                        icon: "eye.fill",
                        color: DesignSystem.Color.warning,
                        style: .plain
                    )
                    StatTile(value: time, label: "Time", icon: "timer", color: DesignSystem.Color.indigo, style: .plain)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }
}
