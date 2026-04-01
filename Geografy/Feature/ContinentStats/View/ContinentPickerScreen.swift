import GeografyCore
import GeografyDesign
import SwiftUI

struct ContinentPickerScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    var body: some View {
        mainContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Continents")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Subviews
private extension ContinentPickerScreen {
    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.md) {
                subtitleText
                continentGrid
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var subtitleText: some View {
        Text("Explore aggregated statistics for each continent")
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.top, DesignSystem.Spacing.sm)
    }

    var continentGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(visibleContinents, id: \.self) { continent in
                continentCard(continent)
            }
        }
    }

    func continentCard(_ continent: Country.Continent) -> some View {
        let countryCount = countryDataService.countries.filter { $0.continent == continent }.count
        return Button {
            hapticsService.impact(.medium)
            coordinator.push(.continentStats(continent.displayName))
        } label: {
            CardView {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text(continentEmoji(for: continent))
                        .font(DesignSystem.Font.displayXS)
                    VStack(spacing: DesignSystem.Spacing.xxs) {
                        Text(continent.displayName)
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        Text("\(countryCount) countries")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .padding(.horizontal, DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension ContinentPickerScreen {
    var visibleContinents: [Country.Continent] {
        Country.Continent.allCases.filter { $0 != .antarctica }
    }

    func continentEmoji(for continent: Country.Continent) -> String {
        switch continent {
        case .africa: "🌍"
        case .asia: "🌏"
        case .europe: "🗺️"
        case .northAmerica: "🌎"
        case .southAmerica: "🌎"
        case .oceania: "🏝️"
        case .antarctica: "🧊"
        }
    }
}
