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
            VStack(spacing: GeoSpacing.md) {
                illustrationArea
                mapLabel
                openMapButton
            }
            .padding(GeoSpacing.lg)
        }
    }
}

// MARK: - Subviews

private extension MapCarouselCard {
    var illustrationArea: some View {
        Image(systemName: systemImage)
            .font(.system(size: 80, weight: .thin))
            .foregroundStyle(GeoColors.accent.opacity(0.7))
            .frame(height: 120)
            .frame(maxWidth: .infinity)
    }

    var mapLabel: some View {
        Text(mapName)
            .font(GeoFont.title2)
            .foregroundStyle(GeoColors.textPrimary)
    }

    var openMapButton: some View {
        Button {
            onOpenMap()
        } label: {
            HStack(spacing: GeoSpacing.xs) {
                Text("Open map")
                    .font(GeoFont.headline)
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GeoSpacing.sm)
            .background(GeoColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: GeoCornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}
