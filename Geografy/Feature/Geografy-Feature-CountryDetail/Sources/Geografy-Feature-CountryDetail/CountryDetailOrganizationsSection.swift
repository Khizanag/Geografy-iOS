import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Organizations
extension CountryDetailScreen {
    public var memberOrganizations: [Organization] {
        country.organizations.compactMap { Organization.find($0) }
    }

    public func organizationsSection(
        countryDataService: CountryDataService,
        hapticsService: HapticsService
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Member Of")
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(memberOrganizations) { org in
                    orgCard(org, countryDataService: countryDataService, hapticsService: hapticsService)
                }
            }
        }
    }

    public func orgCard(
        _ org: Organization,
        countryDataService: CountryDataService,
        hapticsService: HapticsService
    ) -> some View {
        Button {
            hapticsService.impact(.light)
            navigateToOrganization(org)
        } label: {
            orgCardLabel(org, countryDataService: countryDataService)
        }
        .buttonStyle(PressButtonStyle())
        .contextMenu {
            Button {
                navigateToOrganization(org)
            } label: {
                Label("View Details", systemImage: "info.circle")
            }
            Button {
                coordinator.sheet(.organizationMap(org))
            } label: {
                Label("View Map", systemImage: "map")
            }
        } preview: {
            Text(org.displayName)
                .font(DesignSystem.Font.headline)
                .padding()
        }
    }

    public func orgCardLabel(
        _ org: Organization,
        countryDataService: CountryDataService
    ) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                orgRowIcon(org)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(org.displayName)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    if org.fullName != org.displayName {
                        Text(org.fullName)
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    let memberCount = countryDataService.countries
                        .filter { $0.organizations.contains(org.id) }.count
                    if memberCount > 0 {
                        Text("\(memberCount) members")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(org.highlightColor.opacity(0.8))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.md)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Org Icon
private extension CountryDetailScreen {
    @ViewBuilder
    func orgRowIcon(_ org: Organization) -> some View {
        if let urlString = org.logoURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                default:
                    orgRowIconFallback(org)
                }
            }
            .frame(width: 38, height: 38)
        } else {
            orgRowIconFallback(org)
        }
    }

    func orgRowIconFallback(_ org: Organization) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(org.highlightColor.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: org.icon)
                .font(DesignSystem.Font.callout.weight(.medium))
                .foregroundStyle(org.highlightColor)
        }
    }
}
