import Geografy_Core_DesignSystem
import SwiftUI

/// The words to find, each crossed out once found or shown, with a VoiceOver action to reveal one.
struct WordSearchWordList: View {
    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var contrast

    let words: [WordSearchWord]
    let foundIDs: Set<UUID>
    let hintRevealedIDs: Set<UUID>
    /// Every word is shown, as after the player gives up.
    let showsAll: Bool
    let canReveal: Bool
    let onReveal: (WordSearchWord) -> Void

    // MARK: - Body
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "Find These Words")
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.top, DesignSystem.Spacing.sm)
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: DesignSystem.Spacing.xs
                ) {
                    ForEach(words) { wordItem in
                        wordChip(wordItem)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.bottom, DesignSystem.Spacing.sm)
            }
        }
    }
}

// MARK: - Subviews
private extension WordSearchWordList {
    func wordChip(_ wordItem: WordSearchWord) -> some View {
        let isUserFound = foundIDs.contains(wordItem.id)
        let isHintRevealed = hintRevealedIDs.contains(wordItem.id)
        let isRevealedOnly = (showsAll || isHintRevealed) && !isUserFound

        return HStack(spacing: DesignSystem.Spacing.xxs) {
            if isUserFound {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.success)
                    .accessibilityHidden(true)
            } else if isRevealedOnly {
                Image(systemName: "eye.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .accessibilityHidden(true)
            }
            Text(wordItem.word)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isUserFound
                        ? DesignSystem.Color.success
                        : (isRevealedOnly ? DesignSystem.Color.warning : DesignSystem.Color.textPrimary)
                )
                .strikethrough(isUserFound || isRevealedOnly)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isUserFound
                ? DesignSystem.Color.success.opacity(DesignSystem.Opacity.tint)
                : (isRevealedOnly
                    ? DesignSystem.Color.warning.opacity(DesignSystem.Opacity.tint)
                    : DesignSystem.Color.cardBackground),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
        )
        .overlay {
            if contrast == .increased {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(wordItem.word)
        .accessibilityValue(
            isUserFound
                ? "Found, \(wordItem.spokenLocation)"
                : (isRevealedOnly ? "Revealed, \(wordItem.spokenLocation)" : "Not found")
        )
        .accessibilityAction(named: "Reveal location") {
            guard !isUserFound, canReveal else { return }
            onReveal(wordItem)
        }
    }
}
