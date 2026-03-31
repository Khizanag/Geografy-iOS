import SwiftUI
import GeografyDesign
import GeografyCore

enum OrgSortOption: String, CaseIterable {
    case alphabetical = "Name"
    case memberCount = "Members"
}

struct OrganizationsScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var sortOption: OrgSortOption = .alphabetical

    var body: some View {
        scrollContent
            .navigationTitle("Organizations")
            .toolbar { toolbarContent }
    }
}

// MARK: - Toolbar
private extension OrganizationsScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
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
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Subviews
private extension OrganizationsScreen {
    var scrollContent: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(sortedOrgs) { org in
                    Button {
                        hapticsService.impact(.light)
                        coordinator.push(.organizationDetail(org))
                    } label: {
                        CardView {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                orgLogo(org)
                                orgInfo(org)
                                Spacer(minLength: 0)
                                orgTrailing(org)
                            }
                            .padding(DesignSystem.Spacing.sm)
                        }
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

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
                .lineLimit(nil)
            if org.fullName != org.displayName {
                Text(org.fullName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .layoutPriority(1)
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
                .accessibilityLabel("\(memberCount(for: org)) members")
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .accessibilityHidden(true)
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
