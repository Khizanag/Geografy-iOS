import SwiftUI
import GeografyDesign

// MARK: - Phrasebook Section
extension CountryDetailScreen {
    @ViewBuilder
    var phrasebookSection: some View {
        let phrases = profileService.profile(for: country.code)?.phrases ?? []
        if !phrases.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "Language Corner", icon: "character.bubble")
                    .accessibilityAddTraits(.isHeader)
                phrasesScrollRow(phrases: phrases)
                learnMoreButton
            }
        }
    }
}

// MARK: - Subviews
private extension CountryDetailScreen {
    func phrasesScrollRow(phrases: [CountryPhrase]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(phrases.prefix(5)) { phrase in
                    PhraseChip(phrase: phrase)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.horizontal, -DesignSystem.Spacing.md)
    }

    var learnMoreButton: some View {
        Button {
            activeSheet = .deepDive
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("See all phrases in Deep Dive")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Phrase Chip
private struct PhraseChip: View {
    let phrase: CountryPhrase

    @State private var flipped = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                flipped.toggle()
            }
        } label: {
            CardView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    if flipped {
                        localSide
                    } else {
                        englishSide
                    }
                }
                .frame(width: 140, alignment: .leading)
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
        .rotation3DEffect(
            .degrees(flipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
    }
}

// MARK: - PhraseChip Subviews
private extension PhraseChip {
    var englishSide: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(phrase.english)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
            Text("Tap to see translation")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .italic()
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap to see translation")
    }

    var localSide: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(phrase.local)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
                .lineLimit(2)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            Text(phrase.pronunciation)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .italic()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(phrase.local), pronounced \(phrase.pronunciation)")
    }
}
