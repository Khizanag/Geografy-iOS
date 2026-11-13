import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Search Results
extension TravelTrackerScreen {
    var searchResultsList: some View {
        let results = searchResults
        return Group {
            if results.isEmpty {
                noResultsState
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    searchResultsHeader(count: results.count)
                    ForEach(results) { country in
                        searchResultRow(country)
                    }
                }
            }
        }
    }

    func searchResultsHeader(count: Int) -> some View {
        HStack {
            Text("\(count) countries found")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Spacer()
        }
        .padding(.bottom, DesignSystem.Spacing.xxs)
    }

    func searchResultRow(_ country: Country) -> some View {
        let status = travelService.status(for: country.code)
        return Button {
            hapticsService.impact(.light)
            selectedCountry = country
        } label: {
            CardView {
                CountryListRow(country: country, subtitle: country.continent.displayName) {
                    searchRowTrailing(status)
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    @ViewBuilder
    func searchRowTrailing(_ status: TravelStatus?) -> some View {
        if let status {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: status.icon)
                    .font(DesignSystem.Font.nano)
                Text(status.shortLabel)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(status.color)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(status.color.opacity(0.15), in: Capsule())
        } else {
            Image(systemName: "plus.circle")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent.opacity(0.7))
        }
    }
}

// MARK: - Empty States
extension TravelTrackerScreen {
    var emptyState: some View {
        ContentUnavailableView {
            Label(emptyStateTitle, systemImage: selectedFilter?.icon ?? "airplane.departure")
        } description: {
            Text(emptyStateSubtitle)
        } actions: {
            GlassButton("Add Country", systemImage: "plus") {
                hapticsService.impact(.medium)
                showCountryPicker = true
            }
        }
        .padding(.top, DesignSystem.Spacing.xxl)
    }

    var noResultsState: some View {
        ContentUnavailableView(
            "No countries found",
            systemImage: "magnifyingglass",
            description: Text("Try a different spelling or search term")
        )
        .padding(.top, DesignSystem.Spacing.xl)
    }
}

// MARK: - Helpers
extension TravelTrackerScreen {
    var currentTravelMapFilter: TravelMapFilter {
        if let filter = selectedFilter {
            switch filter {
            case .visited: .visited
            case .wantToVisit: .wantToVisit
            }
        } else {
            .all
        }
    }

    var currentFilterLabel: String {
        if let filter = selectedFilter {
            "Show \(filter.label.lowercased()) countries on map"
        } else {
            "Show all travel countries on map"
        }
    }

    var isSearching: Bool { !searchText.isEmpty }

    var emptyStateTitle: String {
        switch selectedFilter {
        case .visited: "No visited countries yet"
        case .wantToVisit: "No wishlist yet"
        case nil: "Start tracking your journey"
        }
    }

    var emptyStateSubtitle: String {
        switch selectedFilter {
        case .visited: "Search above or tap + to add countries you've visited"
        case .wantToVisit: "Search above or tap + to build your travel wishlist"
        case nil: "Search for a country above, or tap + to browse all countries"
        }
    }

    var searchResults: [Country] {
        countryDataService.countries
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted(by: \.name)
    }

    var filteredCountries: [Country] {
        let codes: Set<String>
        switch selectedFilter {
        case .visited: codes = travelService.visitedCodes
        case .wantToVisit: codes = travelService.wantToVisitCodes
        case nil: codes = Set(travelService.entries.keys)
        }
        return countryDataService.countries
            .filter { codes.contains($0.code) }
            .sorted(by: \.name)
    }

    var continentBreakdown: [(name: String, visited: Int, total: Int)] {
        let allContinents = Country.Continent.allCases
        let visitedCodes = travelService.visitedCodes
        return allContinents
            .map { continent in
                let total = countryDataService.countries.filter { $0.continent == continent }.count
                let visited = countryDataService.countries.filter {
                    $0.continent == continent && visitedCodes.contains($0.code)
                }.count
                return (name: continent.displayName, visited: visited, total: total)
            }
            .filter { $0.total > 0 }
    }
}
