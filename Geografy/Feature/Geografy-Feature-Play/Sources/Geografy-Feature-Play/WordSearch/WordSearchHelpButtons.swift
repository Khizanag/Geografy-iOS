import Geografy_Core_DesignSystem
import SwiftUI

/// Help while solving alone: reveal the next unfound word, or every word at once.
struct WordSearchHelpButtons: View {
    let nextHintWord: WordSearchWord?
    let onReveal: (WordSearchWord) -> Void
    let onRevealAll: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if let nextHintWord {
                GlassButton(
                    "Reveal \"\(nextHintWord.word)\"",
                    systemImage: "eye",
                    role: .secondary,
                    fullWidth: true
                ) {
                    onReveal(nextHintWord)
                }
            }
            GlassButton("Reveal All", systemImage: "eye.slash", role: .secondary, fullWidth: true, action: onRevealAll)
        }
    }
}
