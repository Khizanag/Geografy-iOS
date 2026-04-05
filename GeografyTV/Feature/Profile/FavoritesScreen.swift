import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

struct FavoritesScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let countryDataService: CountryDataService

    private var favoriteCountries: [Country] {
        countryDataService.countries
            .filter { favoritesService.isFavorite(code: $0.code) }
            .sorted(by: \.name)
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
        .focusSection()
    }
}

// MARK: - Subviews
private extension FavoritesScreen {
    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "heart.slash")
                .font(DesignSystem.Font.system(size: 60))
                .foregroundStyle(DesignSystem.Color.textTertiary)

            Text("No favorites yet")
                .font(DesignSystem.Font.system(size: 28, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text("Browse countries and tap the heart to save them here")
                .font(DesignSystem.Font.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var countryList: some View {
        List(favoriteCountries) { country in
            NavigationLink(value: country) {
                HStack(spacing: DesignSystem.Spacing.lg) {
                    FlagView(countryCode: country.code, height: 44)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(country.name)
                            .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                        Text("\(country.capital) \u{00B7} \(country.continent.displayName)")
                            .font(DesignSystem.Font.system(size: 22))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(country.population.formatted())
                        .font(DesignSystem.Font.system(size: 22))
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
        }
        .navigationDestination(for: Country.self) { country in
            CountryDetailScreen(country: country)
        }
    }
}
