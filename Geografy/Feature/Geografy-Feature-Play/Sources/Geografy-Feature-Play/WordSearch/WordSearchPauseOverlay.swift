import Geografy_Core_DesignSystem
import SwiftUI

/// Covers the letter grid while the puzzle is paused, with a button to carry on.
struct WordSearchPauseOverlay: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let onContinue: () -> Void

    // MARK: - Body
    var body: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            .fill(DesignSystem.Color.background.opacity(reduceTransparency ? 1 : 0.6))
            .overlay {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "pause.circle.fill")
                        .font(DesignSystem.Font.displaySmall)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .accessibilityHidden(true)
                    Text("Paused")
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    GlassButton("Continue", systemImage: "play.fill", action: onContinue)
                }
            }
    }
}
