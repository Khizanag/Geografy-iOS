import GeografyCore
import GeografyDesign
import SwiftUI

// MARK: - Organizations
extension CountryDetailScreen {
    var memberOrganizations: [Organization] {
        country.organizations.compactMap { Organization.find($0) }
    }

    func organizationsSection(countryDataService: CountryDataService, hapticsService: HapticsService) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Member Of")
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(memberOrganizations) { org in
                    orgCard(org, countryDataService: countryDataService, hapticsService: hapticsService)
                }
            }
        }
    }

    func orgCard(
        _ org: Organization,
        countryDataService: CountryDataService,
        hapticsService: HapticsService
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

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Button {
                        navigateToOrganization(org)
                        hapticsService.impact(.light)
                    } label: {
                        orgActionButton(icon: "info.circle", label: "Info", color: DesignSystem.Color.accent)
                    }
                    .buttonStyle(.plain)

                    Button {
                        hapticsService.impact(.light)
                        coordinator.sheet(.organizationMap(org))
                    } label: {
                        orgActionButton(icon: "map", label: "Map", color: org.highlightColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Org Action Button
private extension CountryDetailScreen {
    func orgActionButton(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(DesignSystem.Font.iconXS.weight(.medium))
                .foregroundStyle(color)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(color.opacity(0.8))
        }
        .frame(width: 44, height: 40)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
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
