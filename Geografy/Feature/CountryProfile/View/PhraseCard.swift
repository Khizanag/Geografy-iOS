import SwiftUI

struct PhraseCard: View {
    let phrase: CountryPhrase

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                englishLabel
                localText
                pronunciationLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension PhraseCard {
    var englishLabel: some View {
        Text(phrase.english)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var localText: some View {
        Text(phrase.local)
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var pronunciationLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "speaker.wave.2.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(phrase.pronunciation)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .italic()
        }
    }
}
