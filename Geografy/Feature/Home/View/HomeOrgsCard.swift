import SwiftUI

struct HomeOrgsCard: View {
    let onOrgTap: (Organization) -> Void
    let onSeeAll: () -> Void

    private let featuredOrgs: [Organization] = {
        ["UN", "EU", "NATO", "ASEAN", "G20", "WTO", "African Union"]
            .compactMap { Organization.find($0) }
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader
            orgsScroll
        }
    }
}

// MARK: - Subviews

private extension HomeOrgsCard {
    var sectionHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Color.accent)
                .frame(width: 3, height: 18)
            Text("Organizations")
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Button { onSeeAll() } label: {
                Text("See All")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var orgsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(featuredOrgs) { org in
                    orgChip(org)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }

    func orgChip(_ org: Organization) -> some View {
        Button { onOrgTap(org) } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(org.highlightColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    if let urlString = org.logoURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                            default:
                                Image(systemName: org.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(org.highlightColor)
                            }
                        }
                    } else {
                        Image(systemName: org.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(org.highlightColor)
                    }
                }
                Text(org.displayName)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 76)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            )
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}
