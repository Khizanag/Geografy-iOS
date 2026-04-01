import AVFoundation
import GeografyCore
import GeografyDesign
import SwiftUI

struct CountryDetailScreen: View {
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(PronunciationService.self) private var pronunciationService

    let country: Country

    @State private var showFlagFocus = false
    @State private var showOrganizationDetail: Organization?

    var body: some View {
        listContent
            .listStyle(.grouped)
            .navigationTitle(country.name)
            .fullScreenCover(isPresented: $showFlagFocus) {
                FlagFocusView(countryCode: country.code, countryName: country.name)
            }
            .sheet(item: $showOrganizationDetail) { organization in
                OrganizationSheetView(organization: organization)
            }
    }
}

// MARK: - Subviews
private extension CountryDetailScreen {
    var listContent: some View {
        List {
            heroSection
            actionsSection
            statsSection
            economySection
            languagesSection
            governmentSection
            organizationsSection
        }
    }

    var heroSection: some View {
        Section {
            Button { showFlagFocus = true } label: {
                heroLabel
            }
            .accessibilityLabel("View flag of \(country.name) fullscreen")
        }
    }

    var heroLabel: some View {
        HStack(spacing: 40) {
            FlagView(countryCode: country.code, height: 140)

            VStack(alignment: .leading, spacing: 12) {
                Text(country.name)
                    .font(DesignSystem.Font.system(size: 48, weight: .bold))

                heroSubtitle
            }

            Spacer()

            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(DesignSystem.Font.system(size: 24))
                .foregroundStyle(.tertiary)
        }
    }

    var heroSubtitle: some View {
        HStack(spacing: 12) {
            Text(country.flagEmoji)
                .font(DesignSystem.Font.system(size: 36))

            Text(country.continent.displayName)
                .font(DesignSystem.Font.system(size: 26))
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.tertiary)

            Text(country.code.uppercased())
                .font(DesignSystem.Font.system(size: 26, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Actions
private extension CountryDetailScreen {
    var actionsSection: some View {
        Section {
            favoriteButton
            pronounceButton
        }
    }

    var favoriteButton: some View {
        Button {
            favoritesService.toggle(code: country.code)
        } label: {
            Label(
                favoritesService.isFavorite(code: country.code) ? "Remove from Favorites" : "Add to Favorites",
                systemImage: favoritesService.isFavorite(code: country.code) ? "heart.fill" : "heart"
            )
            .foregroundStyle(
                favoritesService.isFavorite(code: country.code) ? DesignSystem.Color.error : .primary
            )
        }
    }

    var pronounceButton: some View {
        Button {
            pronunciationService.speak(
                text: "\(country.name). Capital: \(country.capital).",
                countryCode: country.code
            )
        } label: {
            Label("Pronounce Country & Capital", systemImage: "speaker.wave.2.fill")
        }
    }
}

// MARK: - Stats
private extension CountryDetailScreen {
    var statsSection: some View {
        Section("Overview") {
            detailRow(icon: "building.columns.fill", label: "Capital", value: country.capital)

            if country.allCapitals.count > 1 {
                ForEach(country.allCapitals, id: \.name) { capital in
                    if let role = capital.role {
                        detailRow(icon: "mappin.circle.fill", label: role, value: capital.name)
                    }
                }
            }

            detailRow(icon: "person.3.fill", label: "Population", value: country.population.formatted())
            detailRow(icon: "map.fill", label: "Area", value: "\(country.area.formatted()) km²")
            detailRow(
                icon: "person.2.fill",
                label: "Density",
                value: String(format: "%.1f per km²", country.populationDensity)
            )
        }
    }
}

// MARK: - Economy
private extension CountryDetailScreen {
    var economySection: some View {
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
    }
}

// MARK: - Languages
private extension CountryDetailScreen {
    var languagesSection: some View {
        Section("Languages (\(country.languages.count))") {
            ForEach(country.languages, id: \.name) { language in
                Button {
                    pronunciationService.speak(text: language.name, countryCode: country.code)
                } label: {
                    languageRow(language)
                }
            }
        }
    }

    func languageRow(_ language: Country.Language) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "text.bubble.fill")
                .font(DesignSystem.Font.system(size: 20))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 36)

            Text(language.name)
                .font(DesignSystem.Font.system(size: 22))

            Spacer()

            Image(systemName: "speaker.wave.2")
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Government
private extension CountryDetailScreen {
    var governmentSection: some View {
        Section("Government") {
            detailRow(icon: "building.fill", label: "Form", value: country.formOfGovernment)
        }
    }
}

// MARK: - Organizations
private extension CountryDetailScreen {
    @ViewBuilder
    var organizationsSection: some View {
        if !country.organizations.isEmpty {
            Section("Organizations (\(country.organizations.count))") {
                ForEach(country.organizations, id: \.self) { organizationID in
                    let organization = Organization.all.first { $0.id == organizationID }
                    Button { showOrganizationDetail = organization } label: {
                        organizationRow(organization, id: organizationID)
                    }
                }
            }
        }
    }

    func organizationRow(_ organization: Organization?, id: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: organization?.icon ?? "building.2")
                .font(DesignSystem.Font.system(size: 24))
                .foregroundStyle(organization?.highlightColor ?? DesignSystem.Color.accent)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(organization?.displayName ?? id)
                    .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                if let fullName = organization?.fullName {
                    Text(fullName)
                        .font(DesignSystem.Font.system(size: 22))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Helpers
private extension CountryDetailScreen {
    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(DesignSystem.Font.system(size: 20))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 36)

            Text(label)
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(DesignSystem.Font.system(size: 22, weight: .semibold))
        }
        .focusable()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
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

// MARK: - Organization Sheet
struct OrganizationSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let organization: Organization

    var body: some View {
        sheetContent
            .navigationTitle(organization.displayName)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onExitCommand { dismiss() }
    }
}

// MARK: - Organization Sheet Content
private extension OrganizationSheetView {
    var sheetContent: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        orgHeader
                        orgDescription
                    }
                }
            }
        }
    }

    var orgHeader: some View {
        HStack(spacing: 20) {
            Image(systemName: organization.icon)
                .font(DesignSystem.Font.system(size: 40))
                .foregroundStyle(organization.highlightColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(organization.displayName)
                    .font(DesignSystem.Font.system(size: 32, weight: .bold))

                Text(organization.fullName)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(.secondary)
            }
        }
    }

    var orgDescription: some View {
        Text(organization.description)
            .font(DesignSystem.Font.system(size: 20))
            .foregroundStyle(.secondary)
    }
}
