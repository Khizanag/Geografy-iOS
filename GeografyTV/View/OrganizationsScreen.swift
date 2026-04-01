import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct OrganizationsScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List(Organization.all) { organization in
            NavigationLink {
                OrganizationDetailScreen(
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
                            .font(.system(size: 22))
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
struct OrganizationDetailScreen: View {
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
                        .font(.system(size: 22))
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
                                .font(.system(size: 22))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(organization.displayName)
        .navigationDestination(for: Country.self) { country in
            CountryDetailScreen(country: country)
        }
    }
}
