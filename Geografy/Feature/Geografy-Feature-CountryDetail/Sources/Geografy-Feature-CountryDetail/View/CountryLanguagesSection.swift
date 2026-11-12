import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Languages Section
extension CountryDetailScreen {
    @ViewBuilder
    var languagesSection: some View {
        let languages = LanguageProfiles.official(in: country.code)
        if !languages.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Language Facts")
                ForEach(languages) { language in
                    languageCard(language)
                }
            }
        }
    }
}

// MARK: - Subviews
private extension CountryDetailScreen {
    func languageCard(_ language: LanguageProfile) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(language.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(language.nativeName)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Spacer(minLength: 0)
                    Text("\(language.speakerCount)M speakers")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                Text("\(language.family) · \(language.script)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(language.funFact)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}
