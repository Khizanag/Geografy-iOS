import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public enum OrgSortOption: String, CaseIterable {
    case alphabetical = "Name"
    case memberCount = "Members"

    public var icon: String {
        switch self {
        case .alphabetical: "textformat.abc"
        case .memberCount: "person.2"
        }
    }
}

public struct OrganizationsScreen: View {
    // MARK: - Init
    public init() {}
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService

    @State private var sortOption: OrgSortOption = .alphabetical

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Organizations")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
    }
}

// MARK: - Toolbar
private extension OrganizationsScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Picker(selection: $sortOption) {
                    ForEach(OrgSortOption.allCases, id: \.self) { option in
                        Label(option.rawValue, systemImage: option.icon)
                            .tag(option)
                    }
                } label: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }
                .pickerStyle(.inline)
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
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
                        #if !os(tvOS)
                        hapticsService.impact(.light)
                        #endif
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
        IconBadge(org.icon, color: org.highlightColor)
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
            InfoPill("\(memberCount(for: org))", style: .tinted(org.highlightColor))
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize()
                .accessibilityLabel("\(memberCount(for: org)) members")
            RowChevron()
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
            Organization.all.sorted(by: \.displayName)
        case .memberCount:
            Organization.all.sorted { memberCount(for: $0) > memberCount(for: $1) }
        }
    }
}
