import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

// MARK: - Organizations
extension CountryDetailScreen {
    func organizationsSection(countryDataService: CountryDataService) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Member Of")
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(content.memberOrganizations) { org in
                    orgCard(org, countryDataService: countryDataService)
                }
            }
        }
    }

    func orgCard(_ org: Organization, countryDataService: CountryDataService) -> some View {
        Button {
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
                coordinator.sheet(MapRoute.organizationMap(org))
            } label: {
                Label("View Map", systemImage: "map")
            }
        } preview: {
            Text(org.displayName)
                .font(DesignSystem.Font.headline)
                .padding()
        }
    }

    func orgCardLabel(
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
                    let memberCount = content.memberCount(of: org, among: countryDataService.countries)
                    if memberCount > 0 {
                        Text("\(memberCount) members")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(org.highlightColor.opacity(DesignSystem.Opacity.heavy))
                    }
                }

                Spacer()

                RowChevron()
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
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous))
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
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(org.highlightColor.opacity(DesignSystem.Opacity.tint))
                .frame(width: 38, height: 38)
            Image(systemName: org.icon)
                .font(DesignSystem.Font.callout.weight(.medium))
                .foregroundStyle(org.highlightColor)
        }
    }
}
