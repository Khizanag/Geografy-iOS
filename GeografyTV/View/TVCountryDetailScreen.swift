import SwiftUI

struct TVCountryDetailScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let country: Country

    var body: some View {
        List {
            heroSection

            quickFactsSection

            demographicsSection

            economySection

            languagesSection

            governmentSection

            organizationsSection
        }
        .navigationTitle(country.name)
    }
}

// MARK: - Hero

private extension TVCountryDetailScreen {
    var heroSection: some View {
        Section {
            HStack(spacing: 48) {
                FlagView(countryCode: country.code, height: 140)

                VStack(alignment: .leading, spacing: 12) {
                    Text(country.name)
                        .font(.system(size: 48, weight: .bold))

                    HStack(spacing: 16) {
                        Text(country.flagEmoji)
                            .font(.system(size: 36))

                        Text(country.continent.displayName)
                            .font(.system(size: 26))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button {
                    favoritesService.toggle(code: country.code)
                } label: {
                    Image(
                        systemName: favoritesService.isFavorite(code: country.code)
                            ? "heart.fill"
                            : "heart"
                    )
                    .font(.system(size: 32))
                    .foregroundStyle(
                        favoritesService.isFavorite(code: country.code)
                            ? DesignSystem.Color.error
                            : .secondary
                    )
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Quick Facts

private extension TVCountryDetailScreen {
    var quickFactsSection: some View {
        Section("Quick Facts") {
            detailRow(icon: "building.columns.fill", label: "Capital", value: country.capital)

            if country.allCapitals.count > 1 {
                ForEach(country.allCapitals, id: \.name) { capital in
                    if let role = capital.role {
                        detailRow(icon: "mappin", label: role, value: capital.name)
                    }
                }
            }

            detailRow(icon: "globe", label: "Country Code", value: country.code.uppercased())
            detailRow(icon: "map.fill", label: "Continent", value: country.continent.displayName)
        }
    }
}

// MARK: - Demographics

private extension TVCountryDetailScreen {
    var demographicsSection: some View {
        Section("Demographics") {
            detailRow(icon: "person.3.fill", label: "Population", value: country.population.formatted())
            detailRow(icon: "square.grid.3x3.fill", label: "Area", value: "\(country.area.formatted()) km²")
            detailRow(
                icon: "person.2.fill",
                label: "Population Density",
                value: String(format: "%.1f/km²", country.populationDensity)
            )
        }
    }
}

// MARK: - Economy

private extension TVCountryDetailScreen {
    @ViewBuilder
    var economySection: some View {
        let hasEconomyData = country.gdp != nil || country.gdpPerCapita != nil

        if hasEconomyData {
            Section("Economy") {
                detailRow(
                    icon: "dollarsign.circle.fill",
                    label: "Currency",
                    value: "\(country.currency.name) (\(country.currency.code))"
                )

                if let gdp = country.gdp, gdp > 0 {
                    detailRow(icon: "chart.bar.fill", label: "GDP", value: formatLargeNumber(gdp))
                }

                if let gdpPerCapita = country.gdpPerCapita, gdpPerCapita > 0 {
                    detailRow(
                        icon: "person.fill",
                        label: "GDP per Capita",
                        value: "$\(Int(gdpPerCapita).formatted())"
                    )
                }

                if let gdpPPP = country.gdpPPP, gdpPPP > 0 {
                    detailRow(icon: "equal.circle.fill", label: "GDP (PPP)", value: formatLargeNumber(gdpPPP))
                }
            }
        } else {
            Section("Economy") {
                detailRow(
                    icon: "dollarsign.circle.fill",
                    label: "Currency",
                    value: "\(country.currency.name) (\(country.currency.code))"
                )
            }
        }
    }
}

// MARK: - Languages

private extension TVCountryDetailScreen {
    var languagesSection: some View {
        Section("Languages") {
            ForEach(country.languages, id: \.name) { language in
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(DesignSystem.Color.accent)
                        .frame(width: 36)

                    Text(language.name)
                        .font(.system(size: 22))
                }
            }
        }
    }
}

// MARK: - Government

private extension TVCountryDetailScreen {
    var governmentSection: some View {
        Section("Government") {
            detailRow(icon: "building.fill", label: "Form of Government", value: country.formOfGovernment)
        }
    }
}

// MARK: - Organizations

private extension TVCountryDetailScreen {
    @ViewBuilder
    var organizationsSection: some View {
        if !country.organizations.isEmpty {
            Section("International Organizations (\(country.organizations.count))") {
                ForEach(country.organizations, id: \.self) { organizationID in
                    if let organization = Organization.all.first(where: { $0.id == organizationID }) {
                        HStack(spacing: 16) {
                            Image(systemName: organization.icon)
                                .font(.system(size: 22))
                                .foregroundStyle(organization.highlightColor)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(organization.displayName)
                                    .font(.system(size: 22, weight: .semibold))

                                Text(organization.fullName)
                                    .font(.system(size: 18))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        Label(organizationID, systemImage: "building.2")
                    }
                }
            }
        }
    }
}

// MARK: - Helpers

private extension TVCountryDetailScreen {
    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 36)

            Text(label)
                .font(.system(size: 22))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 22, weight: .semibold))
        }
    }

    func formatLargeNumber(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        }
        if value >= 1_000_000_000 {
            return String(format: "$%.1fB", value / 1_000_000_000)
        }
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        }
        return "$\(Int(value).formatted())"
    }
}
