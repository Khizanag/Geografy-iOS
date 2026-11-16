import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Neighbors Section
extension CountryDetailScreen {
    func neighborsSection(countryDataService: CountryDataService) -> some View {
        let neighborCodes = CountryNeighbors.neighbors(for: country.code)
        let isIsland = CountryNeighbors.isIslandNation(countryCode: country.code)
        let neighborCountries = neighborCodes.compactMap { countryDataService.country(for: $0) }

        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Neighbors")
            if isIsland {
                islandNationCard
            } else if neighborCountries.isEmpty {
                noNeighborDataCard
            } else {
                neighborScrollView(countries: neighborCountries)
                exploreNeighborsButton
            }
        }
    }
}

// MARK: - Subviews
private extension CountryDetailScreen {
    var islandNationCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                IconBadge("water.waves", color: DesignSystem.Color.blue)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Island Nation")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(country.name) has no land borders — surrounded entirely by water.")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.md)
            .accessibilityElement(children: .combine)
        }
    }

    var noNeighborDataCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                IconBadge("map")
                Text("Neighbor data not available.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.md)
            .accessibilityElement(children: .combine)
        }
    }

    func neighborScrollView(countries: [Country]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(countries) { neighbor in
                    Button { navigateToCountry(neighbor) } label: {
                        neighborChip(country: neighbor)
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .scrollClipDisabled()
    }

    func neighborChip(country: Country) -> some View {
        CountryFlagTile(country: country)
    }

    var exploreNeighborsButton: some View {
        Button {
            hapticsService.impact(.light)
            coordinator.sheet(.neighborExplorer(country))
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                    .font(DesignSystem.Font.subheadline)
                Text("Explore Neighbor Chain")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }
}
