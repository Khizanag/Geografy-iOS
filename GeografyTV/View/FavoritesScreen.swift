import SwiftUI

struct FavoritesScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let countryDataService: CountryDataService

    private var favoriteCountries: [Country] {
        countryDataService.countries
            .filter { favoritesService.isFavorite(code: $0.code) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        Group {
            if favoriteCountries.isEmpty {
                emptyState
            } else {
                countryList
            }
        }
        .navigationTitle("Favorites")
    }
}

// MARK: - Subviews
private extension FavoritesScreen {
    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Color.textTertiary)

            Text("No favorites yet")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text("Browse countries and tap the heart to save them here")
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var countryList: some View {
        List(favoriteCountries) { country in
            NavigationLink(value: country) {
                HStack(spacing: 20) {
                    FlagView(countryCode: country.code, height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(country.name)
                            .font(.system(size: 22, weight: .semibold))

                        Text("\(country.capital) · \(country.continent.displayName)")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(country.population.formatted())
                        .font(.system(size: 18))
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
        }
        .navigationDestination(for: Country.self) { country in
            CountryDetailScreen(country: country)
        }
    }
}
