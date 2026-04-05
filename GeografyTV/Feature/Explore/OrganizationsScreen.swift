import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
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
                HStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: organization.icon)
                        .font(DesignSystem.Font.iconMedium)
                        .foregroundStyle(organization.highlightColor)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(organization.displayName)
                            .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                        Text(organization.fullName)
                            .font(DesignSystem.Font.system(size: 22))
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
        // swiftlint:disable:next closure_body_length
        List {
            Section {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: organization.icon)
                            .font(DesignSystem.Font.iconXL)
                            .foregroundStyle(organization.highlightColor)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                            Text(organization.displayName)
                                .font(DesignSystem.Font.system(size: 28, weight: .bold))

                            Text(organization.fullName)
                                .font(DesignSystem.Font.system(size: 20))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(organization.description)
                        .font(DesignSystem.Font.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }

            Section("Members (\(memberCountries.count))") {
                ForEach(memberCountries) { country in
                    NavigationLink(value: country) {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            FlagView(countryCode: country.code, height: 36)

                            Text(country.name)
                                .font(DesignSystem.Font.system(size: 20))

                            Spacer()

                            Text(country.capital)
                                .font(DesignSystem.Font.system(size: 22))
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
