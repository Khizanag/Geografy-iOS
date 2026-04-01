import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct SearchScreen: View {
    let countryDataService: CountryDataService

    @State private var searchText = ""

    private var results: [SearchResultSection] {
        guard searchText.count >= 2 else { return [] }
        let query = searchText.lowercased()

        var sections: [SearchResultSection] = []

        let matchingCountries = countryDataService.countries
            .filter {
                $0.name.lowercased().contains(query) ||
                $0.code.lowercased().contains(query)
            }
            .prefix(10)
            .map { SearchRow.country($0) }
        if !matchingCountries.isEmpty {
            sections.append(SearchResultSection(
                id: "countries",
                title: "Countries",
                icon: "flag.fill",
                rows: Array(matchingCountries)
            ))
        }

        let matchingCapitals = countryDataService.countries
            .filter { $0.capital.lowercased().contains(query) }
            .prefix(10)
            .map { SearchRow.capital(country: $0, capitalName: $0.capital) }
        if !matchingCapitals.isEmpty {
            sections.append(SearchResultSection(
                id: "capitals",
                title: "Capitals",
                icon: "building.columns.fill",
                rows: Array(matchingCapitals)
            ))
        }

        let matchingOrgs = Organization.all
            .filter {
                $0.displayName.lowercased().contains(query) ||
                $0.fullName.lowercased().contains(query)
            }
            .prefix(10)
            .map { SearchRow.organization($0) }
        if !matchingOrgs.isEmpty {
            sections.append(SearchResultSection(
                id: "organizations",
                title: "Organizations",
                icon: "building.2.fill",
                rows: Array(matchingOrgs)
            ))
        }

        return sections
    }

    var body: some View {
        List {
            if searchText.isEmpty {
                Section {
                    Text("Search for countries, capitals, or organizations")
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(results) { section in
                Section(section.title) {
                    ForEach(section.rows) { row in
                        searchRow(row)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Geografy")
        .navigationTitle("Search")
        .navigationDestination(for: Country.self) { country in
            CountryDetailScreen(country: country)
        }
    }
}

// MARK: - Subviews
private extension SearchScreen {
    @ViewBuilder
    func searchRow(_ row: SearchRow) -> some View {
        switch row {
        case .country(let country):
            NavigationLink(value: country) {
                HStack(spacing: 16) {
                    FlagView(countryCode: country.code, height: 36)

                    Text(country.name)
                        .font(.system(size: 20))

                    Spacer()

                    Text(country.continent.displayName)
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }

        case .capital(let country, let capitalName):
            NavigationLink(value: country) {
                HStack(spacing: 16) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 20))
                        .foregroundStyle(DesignSystem.Color.accent)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(capitalName)
                            .font(.system(size: 20, weight: .semibold))

                        Text(country.name)
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
            }

        case .organization(let organization):
            HStack(spacing: 16) {
                Image(systemName: organization.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(organization.highlightColor)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(organization.displayName)
                        .font(.system(size: 20, weight: .semibold))

                    Text(organization.fullName)
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}
