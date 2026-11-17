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
    @Environment(ExplorationService.self) private var explorationService
    @Environment(AchievementService.self) private var achievementService
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
            .zoomableViewer(isPresented: $showLogoZoom, title: organization.displayName) {
                if let urlString = organization.logoURL, let url = URL(string: urlString) {
                    ZoomableOrgLogoView(url: url, organization: organization) { showLogoZoom = false }
                }
            }
    }
}

// MARK: - Content
private extension OrganizationDetailScreen {
    var scrollContent: some View {
        let members = memberCountries
        return ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                headerCard(memberCount: members.count)
                openMapButton
                memberCountriesSection(members)
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    func headerCard(memberCount: Int) -> some View {
        CardView {
            headerCardContent(memberCount: memberCount)
                .padding(DesignSystem.Spacing.md)
        }
    }

    func headerCardContent(memberCount: Int) -> some View {
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
                    InfoPill(
                        "\(memberCount) member countries",
                        style: .tinted(organization.highlightColor)
                    )
                    .accessibilityLabel("\(memberCount) member countries")
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
            coordinator.cover(MapRoute.organizationMap(organization))
        }
    }

    func memberCountriesSection(_ members: [Country]) -> some View {
        LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "Member Countries")
                .padding(.horizontal, DesignSystem.Spacing.xxs)

            ForEach(members) { country in
                memberCountryRow(country)
            }
        }
    }

    func memberCountryRow(_ country: Country) -> some View {
        Button { coordinator.push(CountryRoute.countryDetail(country)) } label: {
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
        guard explorationService.markOpened(organizationID: organization.id) else { return }
        achievementService.checkKnowledgeAchievements(orgsOpened: explorationService.openedOrganizationIDs.count)
    }
}

// MARK: - Helpers
private extension OrganizationDetailScreen {
    var memberCountries: [Country] {
        OrganizationMembership.members(of: organization.id, in: countryDataService.countries)
    }
}
