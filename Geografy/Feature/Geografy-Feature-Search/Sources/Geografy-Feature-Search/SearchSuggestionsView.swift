import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// What Search shows before anything is typed: recent searches and popular places, both as glass chips.
struct SearchSuggestionsView: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryService

    let recentService: RecentSearchesService
    let onSearch: (String) -> Void
    let onOpen: (SearchRow) -> Void

    private static let popularCountryCodes = ["US", "CN", "JP", "BR", "FR", "AU", "IN", "EG", "CA"]
    private static let popularOrganizationIDs = ["UN"]
    private static let recentLimit = 8

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if !recentService.queries.isEmpty {
                    recentSection
                }
                popularSection
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Recent
private extension SearchSuggestionsView {
    var recentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(
                title: "Recent",
                action: SectionHeaderAction("Clear", accessibilityLabel: "Clear recent searches") {
                    recentService.clearAll()
                }
            )
            .padding(.horizontal, DesignSystem.Spacing.md)

            // One swipeable line keeps recents compact, so Popular stays in view.
            ScrollView(.horizontal) {
                GlassEffectContainer {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(recentService.queries.prefix(Self.recentLimit), id: \.self) { recentQuery in
                            recentChip(recentQuery)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
        }
    }

    func recentChip(_ recentQuery: String) -> some View {
        let row = resolvedRow(for: recentQuery)
        return SearchChip(title: row?.chipTitle ?? recentQuery, row: row) {
            onSearch(recentQuery)
        }
        .contextMenu {
            Button("Remove", systemImage: "xmark", role: .destructive) {
                recentService.remove(recentQuery)
            }
        }
        .accessibilityHint("Searches again")
        .accessibilityActions {
            Button("Remove") { recentService.remove(recentQuery) }
        }
    }

    /// The place a recent search names exactly, so its chip can show that place's flag.
    func resolvedRow(for recentQuery: String) -> SearchRow? {
        let engine = SearchEngine(countries: countryService.countries, organizations: Organization.all)
        guard let topHit = engine.results(for: recentQuery, scope: .all).topHit else { return nil }
        let isExactName = topHit.title.compare(
            recentQuery,
            options: [.caseInsensitive, .diacriticInsensitive]
        ) == .orderedSame
        return isExactName ? topHit : nil
    }
}

// MARK: - Popular
private extension SearchSuggestionsView {
    var popularSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Popular")
            GlassEffectContainer {
                FlowLayout(spacing: DesignSystem.Spacing.xs) {
                    ForEach(popularRows) { row in
                        SearchChip(title: row.chipTitle, row: row) {
                            onOpen(row)
                        }
                        .accessibilityHint("Opens \(row.kindTitle.lowercased())")
                    }
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var popularRows: [SearchRow] {
        let countries = Self.popularCountryCodes.compactMap { code in
            countryService.countries.first { $0.code == code }.map(SearchRow.country)
        }
        let organizations = Self.popularOrganizationIDs.compactMap(Organization.find).map(SearchRow.organization)
        return countries + organizations
    }
}

// MARK: - Chip
/// A glass capsule with a flag or symbol and a name; the one chip style Search uses.
private struct SearchChip: View {
    let title: String
    let row: SearchRow?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let row {
                    SearchRowSymbol(row: row, size: .chip)
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(DesignSystem.Font.subheadline.weight(.semibold))
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .frame(width: SearchRowSymbol.Size.chip.width)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .fixedSize()
            }
            .padding(.leading, DesignSystem.Spacing.xs)
            .padding(.trailing, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .frame(minHeight: 44)
            .glassEffect(.regular, in: .capsule)
            .contentShape(.contextMenuPreview, Capsule())
            .contentShape(Capsule())
        }
        // Not interactive glass: it swallows the long press that opens a chip's menu.
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel(title)
    }
}
