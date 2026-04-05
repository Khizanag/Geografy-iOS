import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct HomeExploreCarousel: View {
    // MARK: - Properties
    let onItemTap: (ExploreItem) -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader
            itemsScroll
        }
    }
}

// MARK: - ExploreItem
extension HomeExploreCarousel {
    enum ExploreItem: CaseIterable {
        case countries
        case compare
        case travel
        case organizations
        case timeline
        case continentStats

        var name: String {
            switch self {
            case .countries: "Countries"
            case .compare: "Compare"
            case .travel: "Travel"
            case .organizations: "Organizations"
            case .timeline: "Timeline"
            case .continentStats: "Continent Stats"
            }
        }

        var icon: String {
            switch self {
            case .countries: "globe.americas.fill"
            case .compare: "arrow.left.arrow.right"
            case .travel: "airplane"
            case .organizations: "building.2.fill"
            case .timeline: "calendar.badge.clock"
            case .continentStats: "chart.bar.xaxis.ascending"
            }
        }

        var gradientColors: (Color, Color) {
            switch self {
            case .countries: (Color(hex: "00C9A7"), Color(hex: "008C72"))
            case .compare: (Color(hex: "6C63FF"), Color(hex: "4A42DB"))
            case .travel: (Color(hex: "4DABF7"), Color(hex: "1A73E8"))
            case .organizations: (Color(hex: "8944AB"), Color(hex: "6A1B9A"))
            case .timeline: (Color(hex: "FF8F00"), Color(hex: "E65100"))
            case .continentStats: (Color(hex: "43A047"), Color(hex: "2E7D32"))
            }
        }
    }
}

// MARK: - Subviews
private extension HomeExploreCarousel {
    var sectionHeader: some View {
        SectionHeaderView(title: "Explore")
            .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var itemsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(ExploreItem.allCases, id: \.self) { item in
                    exploreCard(item)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .scrollClipDisabled()
    }

    func exploreCard(_ item: ExploreItem) -> some View {
        let (primary, secondary) = item.gradientColors

        return Button { onItemTap(item) } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [primary, secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: item.icon)
                    .font(DesignSystem.IconSize.xxLarge)
                    .foregroundStyle(.white.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: 8, y: -8)
                    .clipped()

                Text(item.name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .lineLimit(2)
                    .padding(DesignSystem.Spacing.sm)
            }
            .frame(width: 140, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .shadow(color: primary.opacity(0.3), radius: 6, y: 4)
        }
        .buttonStyle(PressButtonStyle())
    }
}
