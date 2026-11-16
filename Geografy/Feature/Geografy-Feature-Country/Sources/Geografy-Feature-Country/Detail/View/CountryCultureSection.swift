import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Culture Section
extension CountryDetailScreen {
    @ViewBuilder
    var cultureSection: some View {
        if let culture = CountryCulture.data[country.code] {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Culture")
                CardView {
                    cultureRows(culture)
                        .padding(DesignSystem.Spacing.md)
                }
            }
        }
    }
}

// MARK: - Rows
private extension CountryDetailScreen {
    func cultureRows(_ culture: CountryCultureEntry) -> some View {
        let highlights = culture.highlights
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            ForEach(highlights) { highlight in
                cultureRow(highlight)
                if highlight.id != highlights.last?.id || culture.funFact != nil {
                    Divider()
                }
            }
            if let funFact = culture.funFact {
                Label(funFact, systemImage: "lightbulb.fill")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    func cultureRow(_ highlight: CountryCultureEntry.Highlight) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: highlight.icon)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.xl)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(highlight.label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(highlight.value)
                    .font(DesignSystem.Font.callout.weight(.semibold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
