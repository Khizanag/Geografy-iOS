import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// What Compare shows until both countries are picked: opponents for the one picked, or popular matchups.
struct CompareStartView: View {
    // MARK: - Properties
    let leftCountry: Country?
    let rightCountry: Country?
    let countries: [Country]
    let onChoose: (Country, PairSide) -> Void
    let onChoosePair: (ComparisonPair) -> Void
    let onShuffle: () -> Void

    private static let popularCodePairs = [
        ("US", "CN"),
        ("IN", "CN"),
        ("FR", "DE"),
        ("BR", "AR"),
        ("JP", "KR"),
    ]

    // MARK: - Body
    var body: some View {
        if let picked = leftCountry ?? rightCountry {
            suggestionsSection(for: picked, filling: leftCountry == nil ? .left : .right)
        } else {
            popularSection
        }
    }
}

// MARK: - Sections
private extension CompareStartView {
    func suggestionsSection(for picked: Country, filling side: PairSide) -> some View {
        let suggestions = CompareSuggestions.suggestions(for: picked, among: countries)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header(title: "Compare With")
            RowListCard(
                suggestions,
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagWidth)
            ) { suggestion in
                Button {
                    onChoose(suggestion.country, side)
                } label: {
                    CountryListRow(country: suggestion.country, subtitle: suggestion.reason.title) {
                        RowChevron()
                    }
                    .rowListCardRow()
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }

    var popularSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header(title: "Popular Matchups")
            RowListCard(
                popularPairs,
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagPairWidth)
            ) { pair in
                CompareMatchupRow(pair: pair) {
                    onChoosePair(pair)
                }
            }
        }
    }

    func header(title: String) -> some View {
        SectionHeaderView(
            title: title,
            action: SectionHeaderAction(
                "Shuffle",
                systemImage: "shuffle",
                accessibilityLabel: "Pick at random",
                perform: onShuffle
            )
        )
    }
}

// MARK: - Data
private extension CompareStartView {
    var popularPairs: [ComparisonPair] {
        Self.popularCodePairs.compactMap { leftCode, rightCode in
            guard let left = countries.first(where: { $0.code == leftCode }),
                  let right = countries.first(where: { $0.code == rightCode }) else { return nil }
            return ComparisonPair(left: left, right: right)
        }
    }
}
