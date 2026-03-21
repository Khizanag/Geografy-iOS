import SwiftUI

struct LanguageBarChart: View {
    let languages: [Country.Language]
    let appeared: Bool

    var body: some View {
        GeoCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                headerRow
                ForEach(Array(sortedLanguages.enumerated()), id: \.element.name) { index, language in
                    languageRow(language: language, index: index)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension LanguageBarChart {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "globe")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Languages")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func languageRow(language: Country.Language, index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(language.name)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    Capsule()
                        .fill(barColor(for: index))
                        .frame(width: geo.size.width * min(appeared ? language.percentage / 100 : 0, 1))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(0.3 + Double(index) * 0.08),
                            value: appeared
                        )
                }
            }
            .frame(height: DesignSystem.Spacing.xs)

            Text("\(Int(language.percentage))%")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(width: DesignSystem.Spacing.xl, alignment: .trailing)
        }
    }
}

// MARK: - Helpers

private extension LanguageBarChart {
    var sortedLanguages: [Country.Language] {
        languages.sorted { $0.percentage > $1.percentage }
    }

    func barColor(for index: Int) -> Color {
        let opacity = max(1.0 - Double(index) * 0.2, 0.3)
        return DesignSystem.Color.accent.opacity(opacity)
    }
}
