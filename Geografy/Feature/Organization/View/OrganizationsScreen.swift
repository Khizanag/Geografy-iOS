import SwiftUI

enum OrgSortOption: String, CaseIterable {
    case alphabetical = "Name"
    case memberCount = "Members"
}

struct OrganizationsScreen: View {
    @State private var countryDataService = CountryDataService()
    @State private var sortOption: OrgSortOption = .alphabetical

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(sortedOrgs) { org in
                    NavigationLink(value: org) {
                        GeoCard {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                orgLogo(org)
                                orgInfo(org)
                                Spacer(minLength: 0)
                                orgTrailing(org)
                            }
                            .padding(DesignSystem.Spacing.sm)
                        }
                    }
                    .buttonStyle(GeoPressButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    })
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .navigationTitle("Organizations")
        .toolbar { toolbarContent }
        .navigationDestination(for: Organization.self) { org in
            OrganizationDetailScreen(organization: org)
        }
        .task { countryDataService.loadCountries() }
    }
}

// MARK: - Toolbar

private extension OrganizationsScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(OrgSortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        if sortOption == option {
                            Label(option.rawValue, systemImage: "checkmark")
                        } else {
                            Text(option.rawValue)
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
        }
    }
}

// MARK: - Subviews

private extension OrganizationsScreen {
    func orgLogo(_ org: Organization) -> some View {
        Group {
            if let urlString = org.logoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
                    default:
                        orgLogoFallback(org)
                    }
                }
            } else {
                orgLogoFallback(org)
            }
        }
    }

    func orgLogoFallback(_ org: Organization) -> some View {
        ZStack {
            Circle()
                .fill(org.highlightColor.opacity(0.15))
                .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
            Image(systemName: org.icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(org.highlightColor)
        }
    }

    func orgInfo(_ org: Organization) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(org.displayName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if org.fullName != org.displayName {
                Text(org.fullName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    func orgTrailing(_ org: Organization) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(memberCount(for: org))")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(org.highlightColor)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(org.highlightColor.opacity(0.12), in: Capsule())
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}

// MARK: - Helpers

private extension OrganizationsScreen {
    func memberCount(for org: Organization) -> Int {
        countryDataService.countries.filter { $0.organizations.contains(org.id) }.count
    }

    var sortedOrgs: [Organization] {
        switch sortOption {
        case .alphabetical:
            Organization.all.sorted { $0.displayName < $1.displayName }
        case .memberCount:
            Organization.all.sorted { memberCount(for: $0) > memberCount(for: $1) }
        }
    }
}
