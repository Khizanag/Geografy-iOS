import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Shown after an answer while the game waits for the player: read about the country the question was about, then
/// move on when ready.
struct AnswerReviewBar: View {
    // MARK: - Properties
    let country: Country
    let nextTitle: LocalizedStringKey
    let onShowCountry: () -> Void
    let onNext: () -> Void

    // MARK: - Body
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton(country.name, systemImage: "info.circle", role: .secondary, fullWidth: true) {
                onShowCountry()
            }
            .accessibilityLabel("About \(country.name)")

            GlassButton(nextTitle, systemImage: "arrow.right", fullWidth: true) {
                onNext()
            }
        }
    }
}
