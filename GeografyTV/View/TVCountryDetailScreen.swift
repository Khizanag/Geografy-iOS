import SwiftUI

struct TVCountryDetailScreen: View {
    @Environment(FavoritesService.self) private var favoritesService

    let country: Country

    @State private var showFlagFocus = false

    var body: some View {
        ScrollView {
            VStack(spacing: 48) {
                heroSection

                statsStrip

                infoSections

                organizationsSection
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 40)
        }
        .background { AmbientBlobsView(.tv) }
        .fullScreenCover(isPresented: $showFlagFocus) {
            TVFlagFocusView(countryCode: country.code, countryName: country.name)
        }
    }
}

// MARK: - Hero

private extension TVCountryDetailScreen {
    var heroSection: some View {
        HStack(spacing: 48) {
            Button {
                showFlagFocus = true
            } label: {
                FlagView(countryCode: country.code, height: 180)
            }
            .buttonStyle(.card)

            VStack(alignment: .leading, spacing: 16) {
                Text(country.name)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                HStack(spacing: 12) {
                    Text(country.flagEmoji)
                        .font(.system(size: 40))

                    Text(country.continent.displayName)
                        .font(.system(size: 28))
                        .foregroundStyle(DesignSystem.Color.textSecondary)

                    Text("·")
                        .foregroundStyle(DesignSystem.Color.textTertiary)

                    Text(country.code.uppercased())
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }

                Text(country.formOfGovernment)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Spacer()

            Button {
                favoritesService.toggle(code: country.code)
            } label: {
                VStack(spacing: 8) {
                    Image(
                        systemName: favoritesService.isFavorite(code: country.code)
                            ? "heart.fill"
                            : "heart"
                    )
                    .font(.system(size: 36))

                    Text(
                        favoritesService.isFavorite(code: country.code)
                            ? "Favorited"
                            : "Favorite"
                    )
                    .font(.system(size: 16))
                }
                .foregroundStyle(
                    favoritesService.isFavorite(code: country.code)
                        ? DesignSystem.Color.error
                        : DesignSystem.Color.textSecondary
                )
            }
            .buttonStyle(.bordered)
        }
        .focusable(false)
    }
}

// MARK: - Stats Strip

private extension TVCountryDetailScreen {
    var statsStrip: some View {
        HStack(spacing: 0) {
            statTile(
                icon: "building.columns.fill",
                value: country.capital,
                label: "Capital",
            )

            Divider().frame(height: 60)

            statTile(
                icon: "person.3.fill",
                value: country.population.formatted(),
                label: "Population",
            )

            Divider().frame(height: 60)

            statTile(
                icon: "map.fill",
                value: "\(country.area.formatted()) km²",
                label: "Area",
            )

            Divider().frame(height: 60)

            statTile(
                icon: "person.2.fill",
                value: String(format: "%.1f/km²", country.populationDensity),
                label: "Density",
            )

            if let gdpPerCapita = country.gdpPerCapita, gdpPerCapita > 0 {
                Divider().frame(height: 60)

                statTile(
                    icon: "dollarsign.circle.fill",
                    value: "$\(Int(gdpPerCapita).formatted())",
                    label: "GDP/Capita",
                )
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(DesignSystem.Color.cardBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 20))
        .focusable()
    }

    func statTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(DesignSystem.Color.accent)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Info Sections

private extension TVCountryDetailScreen {
    var infoSections: some View {
        HStack(alignment: .top, spacing: 32) {
            leftColumn
            rightColumn
        }
    }

    var leftColumn: some View {
        VStack(spacing: 24) {
            infoCard(title: "Economy") {
                VStack(alignment: .leading, spacing: 16) {
                    infoRow(
                        label: "Currency",
                        value: "\(country.currency.name) (\(country.currency.code))"
                    )

                    if let gdp = country.gdp, gdp > 0 {
                        infoRow(label: "GDP", value: formatLargeNumber(gdp))
                    }

                    if let gdpPerCapita = country.gdpPerCapita, gdpPerCapita > 0 {
                        infoRow(label: "GDP per Capita", value: "$\(Int(gdpPerCapita).formatted())")
                    }

                    if let gdpPPP = country.gdpPPP, gdpPPP > 0 {
                        infoRow(label: "GDP (PPP)", value: formatLargeNumber(gdpPPP))
                    }
                }
            }

            if country.allCapitals.count > 1 {
                infoCard(title: "Capitals") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(country.allCapitals, id: \.name) { capital in
                            HStack {
                                Text(capital.name)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(DesignSystem.Color.textPrimary)

                                Spacer()

                                if let role = capital.role {
                                    Text(role)
                                        .font(.system(size: 18))
                                        .foregroundStyle(DesignSystem.Color.textTertiary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    var rightColumn: some View {
        VStack(spacing: 24) {
            infoCard(title: "Languages") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(country.languages, id: \.name) { language in
                        HStack(spacing: 12) {
                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(DesignSystem.Color.accent)

                            Text(language.name)
                                .font(.system(size: 22))
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                        }
                    }
                }
            }

            infoCard(title: "Government") {
                Text(country.formOfGovernment)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Organizations

private extension TVCountryDetailScreen {
    @ViewBuilder
    var organizationsSection: some View {
        if !country.organizations.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                Text("International Organizations")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .focusable(false)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 280), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(country.organizations, id: \.self) { organizationID in
                        organizationTile(organizationID)
                    }
                }
            }
        }
    }

    func organizationTile(_ organizationID: String) -> some View {
        let organization = Organization.all.first { $0.id == organizationID }
        return HStack(spacing: 14) {
            Image(systemName: organization?.icon ?? "building.2")
                .font(.system(size: 22))
                .foregroundStyle(organization?.highlightColor ?? DesignSystem.Color.accent)
                .frame(width: 32)

            Text(organization?.displayName ?? organizationID)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)

            Spacer()
        }
        .padding(16)
        .background(DesignSystem.Color.cardBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
        .focusable()
    }
}

// MARK: - Reusable Components

private extension TVCountryDetailScreen {
    func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(28)
        .background(DesignSystem.Color.cardBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 20))
        .focusable()
    }

    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
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
