import SwiftUI

struct FavoritesScreen: View {
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(HapticsService.self) private var hapticsService

    @State private var countryDataService = CountryDataService()

    var body: some View {
        ScrollView {
            if favoriteCountries.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(favoriteCountries) { country in
                        NavigationLink(value: country) {
                            countryCard(for: country)
                        }
                        .buttonStyle(PressButtonStyle())
                        .simultaneousGesture(TapGesture().onEnded {
                            hapticsService.impact(.light)
                        })
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xxl)
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .navigationTitle("Favorites")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircleCloseButton()
            }
        }
        .task { countryDataService.loadCountries() }
    }
}

// MARK: - Content

private extension FavoritesScreen {
    var favoriteCountries: [Country] {
        countryDataService.countries
            .filter { favoritesService.isFavorite(code: $0.code) }
            .sorted { $0.name < $1.name }
    }

    var emptyState: some View {
        EmptyStateView(
            icon: "heart.slash",
            title: "No Favorites Yet",
            subtitle: "Tap the heart icon on any country to save it here."
        )
    }

    func countryCard(for country: Country) -> some View {
        CountryRowView(
            country: country,
            isFavorite: true,
            showContinent: false
        )
    }
}
