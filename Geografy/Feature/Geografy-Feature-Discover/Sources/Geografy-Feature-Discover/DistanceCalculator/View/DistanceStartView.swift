import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// What the calculator shows until both countries are picked: capitals near and far from the one picked,
/// or popular routes.
struct DistanceStartView: View {
    // MARK: - Properties
    let originCountry: Country?
    let destinationCountry: Country?
    let countries: [Country]
    let onChoose: (Country, PairSide) -> Void
    let onChooseRoute: (CountryRoute) -> Void
    let onShuffle: () -> Void

    private static let popularCodePairs = [
        ("GB", "US"),
        ("JP", "AU"),
        ("FR", "JP"),
        ("BR", "PT"),
        ("EG", "ZA"),
        ("AR", "NZ"),
    ]

    // MARK: - Body
    var body: some View {
        if let picked = originCountry ?? destinationCountry {
            suggestionSections(for: picked, filling: originCountry == nil ? .left : .right)
        } else {
            popularSection
        }
    }
}

// MARK: - Sections
private extension DistanceStartView {
    func suggestionSections(for picked: Country, filling side: PairSide) -> some View {
        let suggestions = DistanceSuggestions(for: picked, among: countries)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            section(title: "Nearby Capitals", action: shuffleAction) {
                suggestionList(suggestions.nearby, filling: side)
            }
            if !suggestions.farAway.isEmpty {
                section(title: "Far Away") {
                    suggestionList(suggestions.farAway, filling: side)
                }
            }
        }
    }

    var popularSection: some View {
        section(title: "Popular Routes", action: shuffleAction) {
            RowListCard(
                popularRoutes,
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagPairWidth)
            ) { route in
                RouteRow(route: route) {
                    onChooseRoute(route)
                }
            }
        }
    }

    func section(
        title: String,
        action: SectionHeaderAction? = nil,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title, action: action)
            content()
        }
    }

    var shuffleAction: SectionHeaderAction {
        SectionHeaderAction("Shuffle", systemImage: "shuffle", accessibilityLabel: "Pick at random", perform: onShuffle)
    }
}

// MARK: - Rows
private extension DistanceStartView {
    func suggestionList(_ suggestions: [DistanceSuggestion], filling side: PairSide) -> some View {
        RowListCard(
            suggestions,
            dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagWidth)
        ) { suggestion in
            Button {
                onChoose(suggestion.country, side)
            } label: {
                CountryListRow(country: suggestion.country, subtitle: subtitle(for: suggestion)) {
                    Text(DistanceFormat.kilometers(suggestion.distanceKm))
                        .font(DesignSystem.Font.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    RowChevron()
                }
                .rowListCardRow()
            }
            .buttonStyle(PressButtonStyle())
            .accessibilityHint(side == .left ? "Sets it as the origin" : "Sets it as the destination")
        }
    }

    func subtitle(for suggestion: DistanceSuggestion) -> String {
        let capital = suggestion.country.capital
        return suggestion.sharesBorder ? "\(capital) · Shares a border" : capital
    }
}

// MARK: - Data
private extension DistanceStartView {
    var popularRoutes: [CountryRoute] {
        Self.popularCodePairs.compactMap { originCode, destinationCode in
            guard let origin = countries.first(where: { $0.code == originCode }),
                  let destination = countries.first(where: { $0.code == destinationCode }) else { return nil }
            return CountryRoute(origin: origin, destination: destination)
        }
    }
}
