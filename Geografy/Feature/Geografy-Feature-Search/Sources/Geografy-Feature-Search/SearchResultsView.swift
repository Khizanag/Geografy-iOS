import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Search results: the top hit as a featured card, then each kind in its own card.
struct SearchResultsView: View {
    // MARK: - Properties
    let results: SearchResults
    let query: String
    let onOpen: (SearchRow) -> Void

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if let topHit = results.topHit {
                    topHitCard(topHit)
                }
                ForEach(results.sections) { section in
                    resultSection(section)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Top Hit
private extension SearchResultsView {
    func topHitCard(_ row: SearchRow) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Top Hit")
            Button {
                onOpen(row)
            } label: {
                CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        SearchRowSymbol(row: row, size: .hero)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            EyebrowLabel(row.kindTitle)
                            Text(highlighted(row.title))
                                .font(DesignSystem.Font.title3)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                            Text(row.subtitle)
                                .font(DesignSystem.Font.subheadline)
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                        }
                        Spacer(minLength: 0)
                        RowChevron()
                    }
                    .padding(DesignSystem.Spacing.md)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressButtonStyle())
            .accessibilityElement(children: .combine)
        }
    }
}

// MARK: - Sections
private extension SearchResultsView {
    func resultSection(_ section: SearchResultSection) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: section.title)
            CardView(cornerRadius: DesignSystem.CornerRadius.large) {
                VStack(spacing: 0) {
                    ForEach(section.rows) { row in
                        resultRow(row)
                        if row != section.rows.last {
                            Divider()
                                .padding(.leading, Self.dividerInset)
                        }
                    }
                }
            }
        }
    }

    func resultRow(_ row: SearchRow) -> some View {
        Button {
            onOpen(row)
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SearchRowSymbol(row: row, size: .row)
                VStack(alignment: .leading, spacing: 2) {
                    Text(highlighted(row.title))
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(row.subtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer(minLength: 0)
                RowChevron()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Helpers
private extension SearchResultsView {
    /// Dividers start under the text, not under the flag.
    static let dividerInset = DesignSystem.Spacing.md + SearchRowSymbol.Size.row.width + DesignSystem.Spacing.sm

    /// The part of the name that matches the query, in bold, so it's clear why a result appeared.
    func highlighted(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        if let range = attributed.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) {
            attributed[range].inlinePresentationIntent = .stronglyEmphasized
        }
        return attributed
    }
}
