import SwiftUI

// MARK: - Organizations

extension CountryDetailScreen {
    var memberOrganizations: [Organization] {
        country.organizations.compactMap { Organization.find($0) }
    }

    func organizationsSection(
        appeared: Bool,
        countryDataService: CountryDataService,
        hapticsService: HapticsService
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Member Of", premium: true)
            CardView {
                VStack(spacing: 0) {
                    ForEach(
                        Array(memberOrganizations.enumerated()),
                        id: \.element.id
                    ) { index, org in
                        NavigationLink(value: org) {
                            orgRow(org, countryDataService: countryDataService)
                        }
                        .buttonStyle(PressButtonStyle())
                        .simultaneousGesture(TapGesture().onEnded {
                            hapticsService.impact(.light)
                        })

                        if index < memberOrganizations.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.48), value: appeared)
    }

    func orgRow(
        _ org: Organization,
        countryDataService: CountryDataService
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(org.highlightColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: org.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(org.highlightColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(org.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                if org.fullName != org.displayName {
                    Text(org.fullName)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            let memberCount = countryDataService.countries
                .filter { $0.organizations.contains(org.id) }.count
            if memberCount > 0 {
                Text("\(memberCount) members")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
    }
}
