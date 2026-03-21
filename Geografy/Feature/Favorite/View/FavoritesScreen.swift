import SwiftUI

struct FavoritesScreen: View {
    @Environment(FavoritesService.self) private var favoritesService
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
                        .buttonStyle(GeoPressButtonStyle())
                        .simultaneousGesture(TapGesture().onEnded {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        })
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xxl)
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .navigationTitle("Favorites")
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
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("No Favorites Yet")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Tap the heart icon on any country to save it here.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xxl)
        .frame(maxWidth: .infinity)
    }

    func countryCard(for country: Country) -> some View {
        CountryRowView(
            country: country,
            isFavorite: true,
            showContinent: false
        )
    }
}
