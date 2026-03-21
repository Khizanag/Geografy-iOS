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
        if compact {
            compactCard
        } else {
            regularCard
        }
    }
}

// MARK: - Layouts

private extension MapCarouselCard {
    var regularCard: some View {
        Button { onOpenMap() } label: {
            ZStack(alignment: .bottomLeading) {
                gradientBackground
                backgroundIcon
                cardContent
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge))
            .shadow(color: gradientColors.0.opacity(0.4), radius: 20, y: 8)
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    var compactCard: some View {
        Button { onOpenMap() } label: {
            ZStack(alignment: .leading) {
                gradientBackground
                HStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: systemImage)
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.9))
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(mapName)
                            .font(DesignSystem.Font.title2)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                        openMapLabel
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge))
            .shadow(color: gradientColors.0.opacity(0.35), radius: 16, y: 6)
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    var gradientBackground: some View {
        LinearGradient(
            colors: [gradientColors.0, gradientColors.1],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var backgroundIcon: some View {
        Image(systemName: systemImage)
            .font(.system(size: 180))
            .foregroundStyle(.white.opacity(0.08))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: 40, y: -20)
            .clipped()
    }

    var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Spacer()
            Text(mapName)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            openMapLabel
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Non-interactive label styled to look like a button — the whole card is the tap target
    var openMapLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "arrow.right.circle.fill")
                .font(DesignSystem.Font.headline)
            Text("Open Map")
                .font(DesignSystem.Font.headline)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1))
    }

    var gradientColors: (Color, Color) {
        switch mapName {
        case "World map":
            (Color(hex: "1A237E"), Color(hex: "3949AB"))
        case "Europe":
            (Color(hex: "1B5E20"), Color(hex: "388E3C"))
        case "Asia":
            (Color(hex: "B71C1C"), Color(hex: "D32F2F"))
        case "Africa":
            (Color(hex: "E65100"), Color(hex: "FF8F00"))
        case "North America":
            (Color(hex: "004D40"), Color(hex: "00695C"))
        case "South America":
            (Color(hex: "33691E"), Color(hex: "558B2F"))
        case "Oceania":
            (Color(hex: "01579B"), Color(hex: "0277BD"))
        default:
            (Color(hex: "1A237E"), Color(hex: "3949AB"))
        }
    }
}
