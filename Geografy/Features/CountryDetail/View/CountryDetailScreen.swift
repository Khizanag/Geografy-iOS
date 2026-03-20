import SwiftUI

struct CountryDetailScreen: View {
    private let country: Country

    @State private var selectedInfo: InfoItem?
    @State private var showFlagFullScreen = false

    init(country: Country) {
        self.country = country
    }

    var body: some View {
        ScrollView {
            VStack(spacing: GeoSpacing.lg) {
                flagSection
                infoGrid
            }
            .padding(GeoSpacing.md)
        }
        .background(GeoColors.background)
        .navigationTitle(country.name)
        .overlay {
            if let selectedInfo {
                InfoCardPopup(
                    title: selectedInfo.title,
                    value: selectedInfo.value,
                    showMapButton: selectedInfo.supportsMap,
                    onClose: { self.selectedInfo = nil }
                )
            }
        }
        .fullScreenCover(isPresented: $showFlagFullScreen) {
            FlagFullScreenView(flagEmoji: country.flagEmoji, countryName: country.name)
        }
    }
}

// MARK: - Info Item

private extension CountryDetailScreen {
    struct InfoItem: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let icon: String
        let supportsMap: Bool
    }
}

// MARK: - Subviews

private extension CountryDetailScreen {
    var flagSection: some View {
        Button { showFlagFullScreen = true } label: {
            Text(country.flagEmoji)
                .font(GeoIconSize.hero)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.vertical, GeoSpacing.md)
    }

    var infoGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 160), spacing: GeoSpacing.sm)],
            spacing: GeoSpacing.sm
        ) {
            ForEach(infoItems) { item in
                GeoInfoTile(
                    icon: item.icon,
                    title: item.title,
                    value: item.value
                ) {
                    selectedInfo = item
                }
            }
        }
    }
}

// MARK: - Info Items

private extension CountryDetailScreen {
    var infoItems: [InfoItem] {
        var items: [InfoItem] = [
            InfoItem(
                title: "Capital",
                value: country.capital,
                icon: "mappin",
                supportsMap: false
            ),
            InfoItem(
                title: "Form of Government",
                value: country.formOfGovernment,
                icon: "building.columns",
                supportsMap: false
            ),
            InfoItem(
                title: "Area",
                value: country.area.formatArea(),
                icon: "map",
                supportsMap: true
            ),
            InfoItem(
                title: "Currency",
                value: "\(country.currency.name) (\(country.currency.code))",
                icon: "dollarsign.circle",
                supportsMap: true
            ),
        ]

        for organization in country.organizations {
            items.append(
                InfoItem(
                    title: organization,
                    value: organization,
                    icon: organizationIcon(for: organization),
                    supportsMap: false
                )
            )
        }

        for language in country.languages {
            items.append(
                InfoItem(
                    title: language.name,
                    value: "\(language.name) \(String(format: "%.0f", language.percentage))%",
                    icon: "globe",
                    supportsMap: false
                )
            )
        }

        items.append(contentsOf: [
            InfoItem(
                title: "Population",
                value: country.population.formatPopulation(),
                icon: "person.3",
                supportsMap: false
            ),
            InfoItem(
                title: "Population Density",
                value: "\(String(format: "%.1f", country.populationDensity))/km²",
                icon: "person.crop.rectangle",
                supportsMap: false
            ),
        ])

        if let gdp = country.gdp {
            items.append(
                InfoItem(
                    title: "GDP",
                    value: gdp.formatGDP(),
                    icon: "chart.bar",
                    supportsMap: false
                )
            )
        }

        if let gdpPerCapita = country.gdpPerCapita {
            items.append(
                InfoItem(
                    title: "GDP per Capita",
                    value: gdpPerCapita.formatCurrency(),
                    icon: "chart.line.uptrend.xyaxis",
                    supportsMap: false
                )
            )
        }

        if let gdpPPP = country.gdpPPP {
            items.append(
                InfoItem(
                    title: "GDP PPP",
                    value: gdpPPP.formatGDP(),
                    icon: "chart.bar.fill",
                    supportsMap: false
                )
            )
        }

        return items
    }
}

// MARK: - Helpers

private extension CountryDetailScreen {
    func organizationIcon(for organization: String) -> String {
        switch organization.uppercased() {
        case "UN": "globe.americas"
        case "NATO": "shield"
        case "EU": "flag"
        case "ASEAN": "globe.asia.australia"
        case "AU", "AFRICAN UNION": "globe.europe.africa"
        default: "building.2"
        }
    }
}
