import SwiftUI

struct MapCarouselCard: View {
    private let mapName: String
    private let systemImage: String
    private let compact: Bool
    private let onOpenMap: () -> Void

    init(mapName: String, systemImage: String, compact: Bool = false, onOpenMap: @escaping () -> Void) {
        self.mapName = mapName
        self.systemImage = systemImage
        self.compact = compact
        self.onOpenMap = onOpenMap
    }

    var body: some View {
        GeoCard {
            if compact {
                compactLayout
            } else {
                regularLayout
            }
        }
    }
}

// MARK: - Layouts

private extension MapCarouselCard {
    var regularLayout: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            illustrationArea
            mapLabel
            openMapButton
        }
        .padding(DesignSystem.Spacing.lg)
    }

    var compactLayout: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: systemImage)
                .font(DesignSystem.IconSize.xLarge)
                .foregroundStyle(DesignSystem.Color.accent.opacity(0.7))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                mapLabel
                openMapButton
            }
        }
        .padding(DesignSystem.Spacing.md)
    }
}

// MARK: - Subviews

private extension MapCarouselCard {
    var illustrationArea: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.IconSize.hero)
            .foregroundStyle(DesignSystem.Color.accent.opacity(0.7))
            .frame(height: DesignSystem.Size.hero)
            .frame(maxWidth: .infinity)
    }

    var mapLabel: some View {
        Text(mapName)
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var openMapButton: some View {
        Button { onOpenMap() } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("Open map")
                    .font(DesignSystem.Font.headline)
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}
