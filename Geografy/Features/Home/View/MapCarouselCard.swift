import SwiftUI

struct MapCarouselCard: View {
    private let mapName: String
    private let systemImage: String
    private let onOpenMap: () -> Void

    init(mapName: String, systemImage: String, onOpenMap: @escaping () -> Void) {
        self.mapName = mapName
        self.systemImage = systemImage
        self.onOpenMap = onOpenMap
    }

    var body: some View {
        GeoCard {
            VStack(spacing: DesignSystem.Spacing.md) {
                illustrationArea
                mapLabel
                openMapButton
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Subviews

private extension MapCarouselCard {
    var illustrationArea: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.IconSize.hero)
            .foregroundStyle(DesignSystem.Color.accent.opacity(0.7))
            .frame(height: 120)
            .frame(maxWidth: .infinity)
    }

    var mapLabel: some View {
        Text(mapName)
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var openMapButton: some View {
        Button {
            onOpenMap()
        } label: {
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
