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
        GeoCard {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: DesignSystem.Size.md)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(country.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    Label(country.capital, systemImage: "star.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .labelStyle(SpacedLabelStyle())

                    HStack(spacing: DesignSystem.Spacing.xxs) {
                        Label(country.area.formatArea(), systemImage: "map")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                            .labelStyle(SpacedLabelStyle())
                        Text("·")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                        Label(country.population.formatPopulation(), systemImage: "person.2")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                            .labelStyle(SpacedLabelStyle())
                    }
                }

                Spacer()

                Image(systemName: "heart.fill")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.error)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }
}

// MARK: - Label Style

private struct SpacedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
    }
}
