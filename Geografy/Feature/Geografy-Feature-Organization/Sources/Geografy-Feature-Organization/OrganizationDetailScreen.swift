import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct OrganizationDetailScreen: View {
    // MARK: - Init
    public init(
        organization: Organization
    ) {
        self.organization = organization
    }
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let organization: Organization

    @State private var showLogoZoom = false

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(organization.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .task { trackOrgView() }
            .overlay {
                if showLogoZoom, let urlString = organization.logoURL, let url = URL(string: urlString) {
                    ZoomableOrgLogoView(url: url, organization: organization) {
                        showLogoZoom = false
                    }
                }
            }
    }
}

// MARK: - Content
private extension OrganizationDetailScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                headerCard
                openMapButton
                memberCountriesSection
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var headerCard: some View {
        CardView {
            headerCardContent
                .padding(DesignSystem.Spacing.md)
        }
    }

    var headerCardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                orgLogo
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(organization.displayName)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    if organization.fullName != organization.displayName {
                        Text(organization.fullName)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("\(memberCountries.count) member countries")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(organization.highlightColor)
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, 3)
                        .background(organization.highlightColor.opacity(0.12), in: Capsule())
                        .accessibilityLabel("\(memberCountries.count) member countries")
                }
                Spacer(minLength: 0)
            }

            Divider()

            Text(organization.description)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var orgLogo: some View {
        Group {
            if let urlString = organization.logoURL, let url = URL(string: urlString) {
                Button {
                    showLogoZoom = true
                } label: {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
                        default:
                            orgLogoFallback
                        }
                    }
                }
                .buttonStyle(.plain)
            } else {
                orgLogoFallback
            }
        }
    }

    var orgLogoFallback: some View {
        IconBadge(organization.icon, color: organization.highlightColor, size: .large)
    }

    var openMapButton: some View {
        GlassButton("Open Map", systemImage: "map.fill", fullWidth: true) {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            coordinator.cover(.map(continentFilter: nil))
        }
    }

    var memberCountriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "Member Countries")
                .padding(.horizontal, DesignSystem.Spacing.xxs)

            ForEach(memberCountries) { country in
                memberCountryRow(country)
            }
        }
    }

    func memberCountryRow(_ country: Country) -> some View {
        Button { coordinator.push(.countryDetail(country)) } label: {
            CardView {
                CountryListRow(country: country, subtitle: country.capital) {
                    RowChevron()
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Gamification
private extension OrganizationDetailScreen {
    func trackOrgView() {
        // Achievement tracking handled at app level
    }
}

// MARK: - Helpers
private extension OrganizationDetailScreen {
    var memberCountries: [Country] {
        countryDataService.countries
            .filter { $0.organizations.contains(organization.id) }
            .sorted(by: \.name)
    }
}
