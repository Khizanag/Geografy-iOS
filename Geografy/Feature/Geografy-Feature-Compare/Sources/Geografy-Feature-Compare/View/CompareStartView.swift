import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// What Compare shows until both countries are picked: opponents for the one picked, or popular matchups.
struct CompareStartView: View {
    // MARK: - Properties
    let leftCountry: Country?
    let rightCountry: Country?
    let countries: [Country]
    let onChoose: (Country, CompareSide) -> Void
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
    func suggestionsSection(for picked: Country, filling side: CompareSide) -> some View {
        let suggestions = CompareSuggestions.suggestions(for: picked, among: countries)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header(title: "Compare With")
            CompareRowList(items: suggestions, leadingWidth: CompareRowLayout.flagWidth) { suggestion in
                CompareSuggestionRow(suggestion: suggestion) {
                    onChoose(suggestion.country, side)
                }
            }
        }
    }

    var popularSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header(title: "Popular Matchups")
            CompareRowList(items: popularPairs, leadingWidth: CompareRowLayout.pairWidth) { pair in
                CompareMatchupRow(pair: pair) {
                    onChoosePair(pair)
                }
            }
        }
    }

    func header(title: String) -> some View {
        HStack {
            SectionHeaderView(title: title)
            Spacer(minLength: DesignSystem.Spacing.sm)
            Button("Shuffle", systemImage: "shuffle", action: onShuffle)
                .buttonStyle(.glass)
                .controlSize(.small)
                .accessibilityLabel("Pick at random")
        }
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
