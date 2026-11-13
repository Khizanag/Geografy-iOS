import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// What Search shows before anything is typed: recent searches, then popular places as glass chips.
struct SearchSuggestionsView: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryService

    let recentService: RecentSearchesService
    let onSearch: (String) -> Void
    let onOpen: (SearchRow) -> Void

    private static let popularCountryCodes = ["US", "CN", "JP", "BR", "FR", "AU", "IN", "EG", "CA"]
    private static let popularOrganizationIDs = ["UN"]
    private static let recentLimit = 5

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if !recentService.queries.isEmpty {
                    recentSection
                }
                popularSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Recent
private extension SearchSuggestionsView {
    var recentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title: "Recent")
                Spacer()
                Button("Clear") {
                    recentService.clearAll()
                }
                .buttonStyle(.glass)
                .controlSize(.small)
                .accessibilityLabel("Clear recent searches")
            }
            CardView(cornerRadius: DesignSystem.CornerRadius.large) {
                VStack(spacing: 0) {
                    let recents = Array(recentService.queries.prefix(Self.recentLimit))
                    ForEach(recents, id: \.self) { recentQuery in
                        recentRow(recentQuery)
                        if recentQuery != recents.last {
                            Divider()
                                .padding(.leading, DesignSystem.Spacing.md + DesignSystem.Size.lg)
                        }
                    }
                }
            }
        }
    }

    func recentRow(_ recentQuery: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Button {
                onSearch(recentQuery)
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .frame(width: DesignSystem.Size.lg)
                        .accessibilityHidden(true)
                    Text(recentQuery)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressButtonStyle())
            .accessibilityHint("Searches again")

            Button {
                recentService.remove(recentQuery)
            } label: {
                Image(systemName: "xmark")
                    .font(DesignSystem.Font.caption.weight(.semibold))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(recentQuery)")
        }
        .padding(.leading, DesignSystem.Spacing.md)
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
                        popularChip(row)
                    }
                }
            }
        }
    }

    func popularChip(_ row: SearchRow) -> some View {
        Button {
            onOpen(row)
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                SearchRowSymbol(row: row, size: .chip)
                Text(row.title)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .padding(.leading, DesignSystem.Spacing.xs)
            .padding(.trailing, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .frame(minHeight: 44)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityLabel(row.title)
        .accessibilityHint("Opens \(row.kindTitle.lowercased())")
    }

    var popularRows: [SearchRow] {
        let countries = Self.popularCountryCodes.compactMap { code in
            countryService.countries.first { $0.code == code }.map(SearchRow.country)
        }
        let organizations = Self.popularOrganizationIDs.compactMap(Organization.find).map(SearchRow.organization)
        return countries + organizations
    }
}
