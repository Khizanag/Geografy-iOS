import Geografy_Core_DesignSystem
import SwiftUI

struct CountryDeepDiveSections: View {
    // MARK: - Properties
    let profile: CountryProfile

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            geographySection
            timelineSection
            economySnapshotSection
        }
    }
}

// MARK: - Geography Deep Dive
private extension CountryDeepDiveSections {
    var geographySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Geography", icon: "mountain.2")
            geographyCards
        }
    }

    var geographyCards: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            geographyInfoCard(
                icon: "cloud.sun",
                title: "Climate",
                value: profile.geography.climate
            )
            geographyInfoCard(
                icon: "map",
                title: "Terrain",
                value: profile.geography.terrain
            )
            if !profile.geography.naturalWonders.isEmpty {
                naturalWondersCard
            }
        }
    }

    func geographyInfoCard(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        CardView {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: DesignSystem.Size.md)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(title)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text(value)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var naturalWondersCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "sparkle")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Natural Wonders")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                wondersFlow
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var wondersFlow: some View {
        FlowLayout(spacing: DesignSystem.Spacing.xs) {
            ForEach(
                profile.geography.naturalWonders,
                id: \.self
            ) { wonder in
                wonderChip(wonder)
            }
        }
    }

    func wonderChip(_ name: String) -> some View {
        InfoPill(name, style: .accent)
    }
}

// MARK: - Timeline
private extension CountryDeepDiveSections {
    var timelineSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(
                title: "Historical Timeline",
                icon: "clock.arrow.circlepath"
            )
            CountryTimelineView(events: profile.timeline)
        }
    }
}

// MARK: - Economy Snapshot
private extension CountryDeepDiveSections {
    var economySnapshotSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Economy Snapshot", icon: "chart.bar")
            economyRankCard
            economyDetailsRow
        }
    }

    var economyRankCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                rankCircle
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Global GDP Rank")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text("Out of ~195 countries")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
            .accessibilityElement(children: .combine)
        }
    }

    var rankCircle: some View {
        Text("#\(profile.economy.gdpRank)")
            .font(DesignSystem.Font.title2)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.accent)
            .padding(DesignSystem.Spacing.xs)
            .frame(
                minWidth: DesignSystem.Size.xxl,
                minHeight: DesignSystem.Size.xxl
            )
            .background(DesignSystem.Color.accent.opacity(0.1))
            .clipShape(Capsule())
            .overlay {
                if colorSchemeContrast == .increased {
                    Capsule().strokeBorder(DesignSystem.Color.dividerSubtle)
                }
            }
    }

    var economyDetailsRow: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return layout {
            economyListTile(
                icon: "building.2",
                title: "Major Industries",
                items: profile.economy.majorIndustries
            )
            economyListTile(
                icon: "shippingbox",
                title: "Top Exports",
                items: profile.economy.topExports
            )
        }
    }

    func economyListTile(
        icon: String,
        title: String,
        items: [String]
    ) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)
                Text(title)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(items, id: \.self) { item in
                        Text("• \(item)")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.sm)
        }
    }
}
