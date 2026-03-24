import SwiftUI

struct TVOrganizationsScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List(Organization.all) { organization in
            NavigationLink {
                TVOrganizationDetailScreen(
                    organization: organization,
                    countryDataService: countryDataService
                )
            } label: {
                HStack(spacing: 20) {
                    Image(systemName: organization.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(organization.highlightColor)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(organization.displayName)
                            .font(.system(size: 22, weight: .semibold))

                        Text(organization.fullName)
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .navigationTitle("Organizations")
    }
}

// MARK: - Detail

struct TVOrganizationDetailScreen: View {
    let organization: Organization
    let countryDataService: CountryDataService

    private var memberCountries: [Country] {
        countryDataService.countries
            .filter { $0.organizations.contains(organization.id) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        Image(systemName: organization.icon)
                            .font(.system(size: 36))
                            .foregroundStyle(organization.highlightColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(organization.displayName)
                                .font(.system(size: 28, weight: .bold))

                            Text(organization.fullName)
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(organization.description)
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
            }

            Section("Members (\(memberCountries.count))") {
                ForEach(memberCountries) { country in
                    NavigationLink(value: country) {
                        HStack(spacing: 16) {
                            FlagView(countryCode: country.code, height: 36)

                            Text(country.name)
                                .font(.system(size: 20))

                            Spacer()

                            Text(country.capital)
                                .font(.system(size: 18))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(organization.displayName)
        .navigationDestination(for: Country.self) { country in
            TVCountryDetailScreen(country: country)
        }
    }
}
